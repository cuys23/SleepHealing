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
 * Regression tests for automatic audio-duration detection (replaces the
 * manually entered Playlist "Duration (min)" field). Root cause under test:
 * the Admin duration field was free text with no relationship to the
 * uploaded file, so it could be wrong, missing, or in any unit the operator
 * felt like typing. Duration is now detected from the uploaded audio via
 * ffprobe (AudioDurationService), stored as whole seconds (DurationFormatter),
 * and formatted for display rather than edited directly.
 *
 * Uses DatabaseTransactions against the real dev database (see
 * SongMediaFlowTest for why RefreshDatabase is not used here).
 */
class AudioDurationTest extends TestCase
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

    private function longerRealAudioFile(string $name = 'track-longer.mp3'): UploadedFile
    {
        return new UploadedFile(
            base_path('tests/Fixtures/audio/tiny-track-longer.mp3'),
            $name,
            'audio/mpeg',
            null,
            true
        );
    }

    public function test_creating_a_song_with_real_audio_detects_and_stores_the_duration_in_seconds(): void
    {
        Storage::fake('public');

        $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'Auto Duration Song',
            'audio' => $this->realAudioFile(),
            'active' => '1',
        ]);

        $playlist = PlayList::where('name', 'Auto Duration Song')->firstOrFail();

        // The fixture is a real 2-second MP3; ffprobe should detect ~2s.
        $this->assertSame('2', $playlist->duration);
        $this->assertSame('00:02', $playlist->formatted_duration);
    }

    public function test_the_admin_playlist_create_form_no_longer_has_a_manual_duration_input(): void
    {
        $response = $this->actingAs($this->admin())->get(route('playlist.create'));
        $response->assertOk();
        $response->assertDontSee('name="duration"', false);
    }

    public function test_the_admin_song_list_shows_the_formatted_duration_not_a_raw_value(): void
    {
        Storage::fake('public');

        $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'List Duration Display Song',
            'audio' => $this->realAudioFile(),
            'active' => '1',
        ]);

        $listResponse = $this->actingAs($this->admin())->get(route('playlist.index'));
        $listResponse->assertOk();
        $listResponse->assertSee('00:02');
    }

    public function test_updating_a_song_without_new_audio_preserves_the_previously_detected_duration(): void
    {
        Storage::fake('public');

        $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'Preserve Duration Song',
            'audio' => $this->realAudioFile(),
            'active' => '1',
        ]);
        $playlist = PlayList::where('name', 'Preserve Duration Song')->firstOrFail();
        $this->assertSame('2', $playlist->duration);

        $this->actingAs($this->admin())->post(route('playlist.update', $playlist), [
            'name' => 'Preserve Duration Song Renamed',
            'active' => '1',
        ]);

        $playlist->refresh();
        $this->assertSame('Preserve Duration Song Renamed', $playlist->name);
        $this->assertSame(
            '2',
            $playlist->duration,
            'Duration must not be wiped out when no new audio file is uploaded on update.'
        );
    }

    public function test_updating_a_song_with_new_audio_recomputes_the_duration(): void
    {
        Storage::fake('public');

        $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'Recompute Duration Song',
            'audio' => $this->realAudioFile(),
            'active' => '1',
        ]);
        $playlist = PlayList::where('name', 'Recompute Duration Song')->firstOrFail();
        $this->assertSame('2', $playlist->duration);

        $this->actingAs($this->admin())->post(route('playlist.update', $playlist), [
            'name' => $playlist->name,
            'audio' => $this->longerRealAudioFile(),
            'active' => '1',
        ]);

        $playlist->refresh();
        $this->assertSame('5', $playlist->duration);
    }

    /**
     * UploadedFile::fake()->create() produces junk bytes with an explicitly
     * asserted MIME type, which passes Laravel's mimes: validation (it is
     * designed to for testing) but is not real, decodable audio - so
     * ffprobe correctly cannot detect a duration from it. Gap 2: this must
     * now fail atomically - a duration-extraction failure is a hard audio
     * validation error, never a "created with a warning" success.
     */
    public function test_a_song_whose_duration_cannot_be_detected_fails_validation_and_creates_nothing(): void
    {
        Storage::fake('public');
        $mediaCountBefore = Media::count();

        $response = $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'Undetectable Duration Song',
            'thumbnail' => UploadedFile::fake()->image('cover.png'),
            'audio' => UploadedFile::fake()->create('track.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);

        $response->assertSessionHasErrors(['audio']);
        $response->assertSessionMissing('success');
        $response->assertSessionMissing('warning');

        $this->assertNull(
            PlayList::where('name', 'Undetectable Duration Song')->first(),
            'A song must not be created when its audio duration cannot be detected.'
        );
        $this->assertSame(
            $mediaCountBefore,
            Media::count(),
            'Neither the thumbnail nor the audio file may be persisted as Media when the audio is rejected.'
        );
        Storage::disk('public')->assertDirectoryEmpty('audio/playlist');
        Storage::disk('public')->assertDirectoryEmpty('images/playlist');
    }

    /**
     * Gap 2, update path: replacing a valid audio file with an undetectable
     * one must preserve the old file, old Media row, and old duration -
     * never delete/overwrite them on a failed re-upload.
     */
    public function test_replacing_a_songs_audio_with_an_undetectable_file_preserves_the_old_audio_and_duration(): void
    {
        Storage::fake('public');

        $this->actingAs($this->admin())->post(route('playlist.store'), [
            'name' => 'Protected Duration Song',
            'audio' => $this->realAudioFile(),
            'active' => '1',
        ]);
        $playlist = PlayList::where('name', 'Protected Duration Song')->firstOrFail();
        $this->assertSame('2', $playlist->duration);
        $originalAudioId = $playlist->audio_id;
        $originalSrc = $playlist->audio->src;
        Storage::disk('public')->assertExists($originalSrc);

        $response = $this->actingAs($this->admin())->post(route('playlist.update', $playlist), [
            'name' => $playlist->name,
            'audio' => UploadedFile::fake()->create('replacement.mp3', 100, 'audio/mpeg'),
            'active' => '1',
        ]);

        $response->assertSessionHasErrors(['audio']);
        $response->assertSessionMissing('success');

        $playlist->refresh();
        $this->assertSame('2', $playlist->duration, 'The old duration must survive a failed re-upload.');
        $this->assertSame($originalAudioId, $playlist->audio_id, 'The old Media row must still be referenced.');
        Storage::disk('public')->assertExists($originalSrc);
    }

    public function test_the_api_normalizes_a_legacy_colon_separated_duration_to_seconds(): void
    {
        Storage::fake('public');

        $albam = Albam::factory()->create(['media_id' => null]);
        $playlist = PlayList::factory()->create([
            'media_id' => null,
            'audio_id' => null,
            'duration' => '3:30',
            'status' => true,
        ]);
        $playlist->albams()->attach($albam->id);

        $api = $this->getJson('/api/play-lists?albam='.$albam->id);
        $api->assertOk();

        $body = collect($api->json('data.albams'))->firstWhere('id', $playlist->id);
        $this->assertNotNull($body);
        $this->assertIsInt($body['duration'], 'API duration must be a real JSON integer, not a numeric string.');
        $this->assertSame(210, $body['duration']);
    }

    public function test_the_api_returns_null_duration_rather_than_a_broken_value_when_absent(): void
    {
        Storage::fake('public');

        $albam = Albam::factory()->create(['media_id' => null]);
        $playlist = PlayList::factory()->create([
            'media_id' => null,
            'audio_id' => null,
            'duration' => null,
            'status' => true,
        ]);
        $playlist->albams()->attach($albam->id);

        $api = $this->getJson('/api/play-lists?albam='.$albam->id);
        $api->assertOk();

        $body = collect($api->json('data.albams'))->firstWhere('id', $playlist->id);
        $this->assertNotNull($body);
        $this->assertNull($body['duration']);
    }
}
