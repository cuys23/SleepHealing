<?php

namespace Tests\Feature\Admin;

use App\Http\Middleware\VerifyCsrfToken;
use App\Models\Albam;
use App\Models\PlayList;
use App\Models\PlaylistAlbam;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

/**
 * Regression tests for the playlist_albams database-audit finding: the
 * pivot table (song-in-album) had no composite index and no unique
 * constraint, so nothing prevented the same track from being linked to the
 * same album more than once. Business rule confirmed: one track must not be
 * linked more than once to the same album.
 *
 * Fix: UNIQUE(albam_id, play_list_id) as playlist_albams_album_playlist_unique,
 * matching the column order the public API's album -> track query filters
 * and joins on (confirmed via EXPLAIN).
 */
class PlaylistAlbamTest extends TestCase
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

    private function track(): PlayList
    {
        // status forced true: PlayListController::index() filters via
        // ->active(), and the factory default is a random boolean.
        return PlayList::factory()->create(['media_id' => null, 'audio_id' => null, 'status' => true]);
    }

    private function album(): Albam
    {
        return Albam::factory()->create(['media_id' => null]);
    }

    public function test_the_same_track_cannot_be_linked_twice_to_the_same_album_at_the_database_level(): void
    {
        $track = $this->track();
        $albam = $this->album();

        DB::table('playlist_albams')->insert([
            'play_list_id' => $track->id,
            'albam_id' => $albam->id,
        ]);

        $this->expectException(QueryException::class);
        try {
            DB::table('playlist_albams')->insert([
                'play_list_id' => $track->id,
                'albam_id' => $albam->id,
            ]);
        } catch (QueryException $e) {
            $this->assertSame('23000', $e->getCode());
            throw $e;
        }
    }

    public function test_playlist_repository_firstorcreate_is_idempotent_for_the_same_track_and_album(): void
    {
        $track = $this->track();
        $albam = $this->album();

        // Mirrors PlayListRepository::storeByRequest()'s write path.
        PlaylistAlbam::firstOrCreate(['play_list_id' => $track->id, 'albam_id' => $albam->id]);
        PlaylistAlbam::firstOrCreate(['play_list_id' => $track->id, 'albam_id' => $albam->id]);

        $this->assertSame(
            1,
            DB::table('playlist_albams')->where('play_list_id', $track->id)->where('albam_id', $albam->id)->count()
        );
    }

    public function test_the_same_track_can_belong_to_multiple_different_albums(): void
    {
        $track = $this->track();
        $albamOne = $this->album();
        $albamTwo = $this->album();

        PlaylistAlbam::firstOrCreate(['play_list_id' => $track->id, 'albam_id' => $albamOne->id]);
        PlaylistAlbam::firstOrCreate(['play_list_id' => $track->id, 'albam_id' => $albamTwo->id]);

        $this->assertSame(2, DB::table('playlist_albams')->where('play_list_id', $track->id)->count());
    }

    public function test_one_album_can_contain_multiple_tracks(): void
    {
        $albam = $this->album();
        $trackOne = $this->track();
        $trackTwo = $this->track();

        PlaylistAlbam::firstOrCreate(['play_list_id' => $trackOne->id, 'albam_id' => $albam->id]);
        PlaylistAlbam::firstOrCreate(['play_list_id' => $trackTwo->id, 'albam_id' => $albam->id]);

        $this->assertSame(2, DB::table('playlist_albams')->where('albam_id', $albam->id)->count());

        $api = $this->getJson('/api/play-lists?albam='.$albam->id);
        $api->assertOk();
        $this->assertCount(2, $api->json('data.albams'));
    }

    /**
     * Admin "Album Playlist tree" screen (AlbamController::updatePlaylist)
     * writes via $albam->playlists()->sync(...), which is already
     * duplicate-safe by construction - this proves the unique constraint
     * doesn't break that existing, already-correct admin flow.
     */
    public function test_admin_album_playlist_tree_sync_remains_compatible_with_the_unique_constraint(): void
    {
        $albam = $this->album();
        $trackOne = $this->track();
        $trackTwo = $this->track();

        $response = $this->actingAs($this->admin())->post(route('albam.tree.update', $albam), [
            'playlists' => [$trackOne->id, $trackTwo->id],
        ]);

        $response->assertRedirect(route('albam.index'));
        $this->assertSame(2, DB::table('playlist_albams')->where('albam_id', $albam->id)->count());
    }
}
