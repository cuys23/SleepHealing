<?php

namespace Tests\Feature\Admin;

use App\Http\Middleware\VerifyCsrfToken;
use App\Models\Albam;
use App\Models\Media;
use App\Models\PlayList;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

/**
 * Regression tests for the Admin song (PlayList) and image (Albam) upload flow.
 *
 * Uses DatabaseTransactions (not RefreshDatabase): this project's phpunit.xml
 * points at the real dev database, so tests must never migrate/wipe it. Every
 * write here is rolled back at the end of each test.
 */
class SongMediaFlowTest extends TestCase
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

    public function test_creating_a_song_stores_thumbnail_and_audio_on_the_public_disk(): void
    {
        Storage::fake('public');

        $response = $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'QA Song',
            'duration' => '3',
            'thumbnail' => UploadedFile::fake()->image('cover.png'),
            'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);

        $response->assertRedirect(route('playlist.index'));

        $playlist = PlayList::latest('id')->first();
        $this->assertNotNull($playlist, 'Song was not persisted to the database.');
        $this->assertSame('QA Song', $playlist->name);

        $thumbnail = Media::find($playlist->media_id);
        $audio = Media::find($playlist->audio_id);

        $this->assertNotNull($thumbnail);
        $this->assertNotNull($audio);
        Storage::disk('public')->assertExists($thumbnail->src);
        Storage::disk('public')->assertExists($audio->src);
    }

    public function test_updating_a_song_with_no_prior_audio_does_not_delete_the_newly_uploaded_file(): void
    {
        Storage::fake('public');

        $playlist = PlayList::factory()->create([
            'media_id' => null,
            'audio_id' => null,
        ]);

        $response = $this->actingAs($this->admin())->post(route('playlist.update', $playlist), [
            'name' => $playlist->name,
            'duration' => '3',
            'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);

        $response->assertRedirect(route('playlist.index'));

        $playlist->refresh();
        $this->assertNotNull($playlist->audio_id, 'audio_id was not set on update.');

        $audio = Media::find($playlist->audio_id);
        $this->assertNotNull($audio);

        Storage::disk('public')->assertExists($audio->src);
    }

    public function test_creating_an_album_stores_thumbnail_on_the_public_disk(): void
    {
        Storage::fake('public');

        $response = $this->actingAs($this->admin())->post(route('albam.store'), [
            'name' => 'QA Album',
            'thumbnail' => UploadedFile::fake()->image('cover.png'),
            'active' => '1',
        ]);

        $response->assertRedirect(route('albam.index'));

        $albam = Albam::latest('id')->first();
        $this->assertNotNull($albam);

        $thumbnail = Media::find($albam->media_id);
        $this->assertNotNull($thumbnail);
        Storage::disk('public')->assertExists($thumbnail->src);
    }

    public function test_updating_an_album_with_no_prior_thumbnail_does_not_delete_the_newly_uploaded_file(): void
    {
        Storage::fake('public');

        $albam = Albam::factory()->create([
            'media_id' => null,
        ]);

        $response = $this->actingAs($this->admin())->post(route('albam.update', $albam), [
            'name' => $albam->name,
            'thumbnail' => UploadedFile::fake()->image('cover.png'),
            'active' => '1',
        ]);

        $response->assertRedirect(route('albam.index'));

        $albam->refresh();
        $this->assertNotNull($albam->media_id, 'media_id was not set on update.');

        $thumbnail = Media::find($albam->media_id);
        $this->assertNotNull($thumbnail);

        Storage::disk('public')->assertExists($thumbnail->src);
    }

    public function test_newly_created_song_appears_on_the_first_admin_list_page(): void
    {
        Storage::fake('public');

        $response = $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'QA First Page Song',
            'duration' => '3',
            'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);

        $response->assertRedirect(route('playlist.index'));

        $listResponse = $this->actingAs($this->admin())->get(route('playlist.index'));
        $listResponse->assertSee('QA First Page Song');
    }
}
