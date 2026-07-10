<?php

namespace Tests\Feature\Admin;

use App\Http\Middleware\VerifyCsrfToken;
use App\Models\Albam;
use App\Models\AlbamCategory;
use App\Models\Category;
use App\Models\PlayList;
use App\Models\PlaylistAlbam;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

/**
 * Regression tests for the Admin -> API visibility handoff.
 *
 * Root cause under test: PlayListController@index (API) and AlbamController@index
 * (API) query through the playlist_albams / albam_categories pivot tables, not the
 * direct albam_id / category_id columns the Admin repositories also write. A song
 * or album created without an explicit album/category selection was previously
 * invisible via the public API forever, even though Admin reported success.
 *
 * Uses DatabaseTransactions against the real dev database (see SongMediaFlowTest
 * for why RefreshDatabase is not used here).
 */
class ApiVisibilityTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();
        $this->withoutMiddleware(VerifyCsrfToken::class);
    }

    private function admin(): User
    {
        return User::factory()->create();
    }

    public function test_a_song_created_and_attached_to_an_album_appears_in_the_api(): void
    {
        Storage::fake('public');

        $albam = Albam::factory()->create(['media_id' => null]);

        $response = $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'API Visible Song',
            'duration' => '3:30',
            'albam' => $albam->id,
            'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);
        $response->assertRedirect(route('playlist.index'));

        $playlist = PlayList::where('name', 'API Visible Song')->firstOrFail();
        $this->assertTrue(
            PlaylistAlbam::where('play_list_id', $playlist->id)->where('albam_id', $albam->id)->exists(),
            'Song was not attached to the album pivot table.'
        );

        // An attached song is fully visible - no "not attached" warning should fire.
        $response->assertSessionMissing('warning');

        $api = $this->getJson('/api/play-lists?albam='.$albam->id);
        $api->assertOk();
        $api->assertJsonFragment(['name' => 'API Visible Song']);
    }

    /**
     * Standalone songs are an intentional part of the workflow: AlbamController@getPlaylist
     * ("tree" screen) lists every PlayList, attached or not, so operators can create songs
     * first and organize them into (potentially several) albums afterward via
     * Albam::playlists()->sync(). Blocking creation without an album would break that screen.
     * So creation must still succeed - the fix is making the resulting "invisible until
     * attached" state impossible to miss, via a flash warning and an Admin list indicator,
     * rather than a hard validation error.
     */
    public function test_a_song_created_without_an_album_selection_is_not_silently_broken(): void
    {
        Storage::fake('public');

        // No 'albam' field submitted - a valid, supported input shape (see class docblock).
        $response = $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'Unattached Song',
            'duration' => '1:00',
            'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);
        $response->assertRedirect(route('playlist.index'));

        $playlist = PlayList::where('name', 'Unattached Song')->first();
        $this->assertNotNull($playlist, 'Admin must still report a real success and create the row.');
        $this->assertFalse(
            PlaylistAlbam::where('play_list_id', $playlist->id)->exists(),
            'Sanity check: an unattached song has no pivot row until attached via the tree screen.'
        );

        // The operator must be told this song will not appear in the app yet.
        $response->assertSessionHas('warning');
    }

    public function test_the_admin_song_list_flags_a_song_with_no_album_as_not_attached(): void
    {
        Storage::fake('public');

        $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'List Flag Unattached Song',
            'duration' => '1:00',
            'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);
        $playlist = PlayList::where('name', 'List Flag Unattached Song')->firstOrFail();

        $listResponse = $this->actingAs($this->admin())->get(route('playlist.index'));
        $listResponse->assertOk();

        $this->assertStringContainsString(
            'No Album',
            $this->extractAlbumsButton($listResponse->getContent(), $playlist->id),
            'The Admin song list must visibly flag a song that has no album attached.'
        );
    }

    public function test_the_admin_song_list_does_not_flag_a_song_with_an_album_attached(): void
    {
        Storage::fake('public');
        $albam = Albam::factory()->create(['media_id' => null]);

        $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'List Flag Attached Song',
            'duration' => '1:00',
            'albam' => $albam->id,
            'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);
        $playlist = PlayList::where('name', 'List Flag Attached Song')->firstOrFail();

        $listResponse = $this->actingAs($this->admin())->get(route('playlist.index'));
        $listResponse->assertOk();

        $button = $this->extractAlbumsButton($listResponse->getContent(), $playlist->id);
        $this->assertStringContainsString('Albums', $button);
        $this->assertStringNotContainsString('No Album', $button);
    }

    private function extractAlbumsButton(string $html, int $playlistId): string
    {
        preg_match(
            '/id="albamsBtn'.$playlistId.'"[^>]*>(.*?)<\/button>/s',
            $html,
            $matches
        );
        $this->assertNotEmpty($matches, "Could not locate the Albums button for playlist {$playlistId}.");

        return $matches[0];
    }

    public function test_an_album_created_and_attached_to_a_category_appears_in_the_api(): void
    {
        Storage::fake('public');

        $category = Category::factory()->create(['status' => true]);

        $response = $this->actingAs($this->admin())->post(route('albam.store'), [
            'name' => 'API Visible Album',
            'category' => $category->id,
            'thumbnail' => UploadedFile::fake()->image('cover.png'),
            'active' => '1',
        ]);
        $response->assertRedirect(route('albam.index'));

        $albam = Albam::where('name', 'API Visible Album')->firstOrFail();
        $this->assertTrue(
            AlbamCategory::where('albam_id', $albam->id)->where('category_id', $category->id)->exists(),
            'Album was not attached to the category pivot table.'
        );

        $api = $this->getJson('/api/albams?category='.$category->id);
        $api->assertOk();
        $api->assertJsonFragment(['name' => 'API Visible Album']);
    }

    public function test_song_media_urls_are_absolute_and_use_the_configured_app_url(): void
    {
        // Storage::fake() does not inherit the real 'public' disk's 'url'
        // config, so it must be passed explicitly to exercise the same
        // Storage::url() behavior the running app uses.
        Storage::fake('public', [
            'url' => rtrim(config('app.url'), '/').'/storage',
        ]);

        $albam = Albam::factory()->create(['media_id' => null]);

        $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'Media URL Song',
            'duration' => '2:00',
            'albam' => $albam->id,
            'thumbnail' => UploadedFile::fake()->image('cover.png'),
            'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);

        $api = $this->getJson('/api/play-lists?albam='.$albam->id);
        $api->assertOk();

        $body = $api->json('data.albams.0');
        $expectedHost = rtrim(config('app.url'), '/');

        $this->assertStringStartsWith($expectedHost, $body['thumbnail']);
        $this->assertStringStartsWith($expectedHost, $body['audio']);
    }

    public function test_a_song_with_no_media_returns_a_valid_response_not_a_broken_one(): void
    {
        Storage::fake('public');

        $albam = Albam::factory()->create(['media_id' => null]);

        $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'No Media Song',
            'duration' => '1:00',
            'albam' => $albam->id,
            'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);

        $api = $this->getJson('/api/play-lists?albam='.$albam->id);
        $api->assertOk();
        $body = $api->json('data.albams.0');

        // No thumbnail was uploaded - accessor must fall back to the dummy asset,
        // not emit a null/broken field that would crash Flutter's non-nullable UI.
        $this->assertNotNull($body['thumbnail']);
        $this->assertIsString($body['thumbnail']);
    }

    public function test_new_songs_are_ordered_deterministically_in_the_album_listing(): void
    {
        Storage::fake('public');
        $albam = Albam::factory()->create(['media_id' => null]);

        foreach (['First', 'Second', 'Third'] as $name) {
            $this->actingAs($this->admin())->post(route('playlist.store'), [
                'name' => "Order Test $name",
                'duration' => '1:00',
                'albam' => $albam->id,
                'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
                'active' => '1',
            ]);
        }

        $api = $this->getJson('/api/play-lists?albam='.$albam->id);
        $api->assertOk();
        $names = collect($api->json('data.albams'))->pluck('name')->values()->all();

        // Same three names, in a stable (creation) order every time this test runs.
        $this->assertEquals(
            ['Order Test First', 'Order Test Second', 'Order Test Third'],
            $names
        );
    }
}
