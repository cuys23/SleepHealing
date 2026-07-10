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

    /**
     * A real, short, decodable MP3 fixture - not UploadedFile::fake(), whose
     * generated content is junk bytes that ffprobe correctly refuses to
     * treat as audio, since AudioDurationService needs genuine audio data
     * to detect a duration from.
     */
    private function realAudioFile(string $name = 'track.mp3'): UploadedFile
    {
        return new UploadedFile(
            base_path('tests/Fixtures/audio/tiny-track.mp3'),
            $name,
            'audio/mpeg',
            null,
            true
        );
    }

    public function test_creating_a_song_stores_thumbnail_and_audio_on_the_public_disk(): void
    {
        Storage::fake('public');

        $response = $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'QA Song',
            'thumbnail' => UploadedFile::fake()->image('cover.png'),
            'audio' => $this->realAudioFile(),
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
            'audio' => $this->realAudioFile(),
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
            'audio' => $this->realAudioFile(),
            'active' => '1',
        ]);

        $response->assertRedirect(route('playlist.index'));

        $listResponse = $this->actingAs($this->admin())->get(route('playlist.index'));
        $listResponse->assertSee('QA First Page Song');
    }

    /**
     * Root cause: the Audio File / Thumbnail inputs on playlist/create.blade.php were
     * plain <input type="file"> tags with no @error() block, unlike every other field
     * (which uses the x-input/x-select components that already render @error messages).
     * A missing/invalid audio file failed validation exactly as intended, but the admin
     * saw only the layout's generic "Something went wrong" toast with no indication of
     * which field, or why - a false-negative-feeling failure for a correctly-rejected
     * submission.
     */
    public function test_creating_a_song_without_audio_shows_a_specific_inline_error_not_just_a_generic_toast(): void
    {
        Storage::fake('public');
        $admin = $this->admin();

        $response = $this->actingAs($admin)->post(route('playlist.store'), [
            'name' => 'No Audio Attempt',
            'active' => '1',
        ]);

        $response->assertSessionHasErrors(['audio']);
        $this->assertNull(
            PlayList::where('name', 'No Audio Attempt')->first(),
            'A song must not be created when the required audio file is missing.'
        );

        $createPage = $this->actingAs($admin)->get(route('playlist.create'));
        $createPage->assertSee('The audio field is required.');
    }

    /**
     * Root cause: components/input.blade.php built its old-input fallback as
     * old('name') - a literal string, not the dynamic $name variable - so every
     * x-input field except the one actually named "name" echoed the *name*
     * field's old value after a failed submission instead of its own (or
     * nothing). components/textarea.blade.php had the companion defect: no
     * old() call at all, so it always reset to blank instead of preserving
     * input. The audio-required validation failure below exercises both.
     */
    public function test_a_failed_song_submission_preserves_each_fields_own_old_value(): void
    {
        Storage::fake('public');
        $admin = $this->admin();

        $this->actingAs($admin)->post(route('playlist.store'), [
            'name' => 'Echo Regression Name',
            'description' => 'Echo Regression Description',
            'active' => '1',
        ]);

        $createPage = $this->actingAs($admin)->get(route('playlist.create'));
        $content = $createPage->getContent();

        preg_match('/id="name"[^>]*value="([^"]*)"/', $content, $nameMatch);
        $this->assertSame('Echo Regression Name', $nameMatch[1] ?? null);

        preg_match('/name="description"[^>]*>(.*?)<\/textarea>/s', $content, $descriptionMatch);
        $this->assertSame(
            'Echo Regression Description',
            trim($descriptionMatch[1] ?? ''),
            'The description textarea must preserve its own old value, not reset to blank.'
        );
    }
}
