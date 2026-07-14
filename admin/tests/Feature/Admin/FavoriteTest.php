<?php

namespace Tests\Feature\Admin;

use App\Models\PlayList;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

/**
 * Regression tests for the favorites database-audit findings:
 *
 * - `favorites` had no PK and no unique constraint on (user_id, play_list_id),
 *   so a race between concurrent toggle requests could create duplicate rows.
 * - FavoriteConstroller::store() used a read-then-write (in_array then
 *   attach/detach) toggle with no protection against that race.
 *
 * Fix: a DB-level UNIQUE(user_id, play_list_id) constraint
 * (favorites_user_playlist_unique) is now the final source of truth, and
 * the controller catches the resulting duplicate-key QueryException
 * (SQLSTATE 23000) instead of letting it surface as a 500.
 */
class FavoriteTest extends TestCase
{
    use DatabaseTransactions;

    private function user(): User
    {
        return User::factory()->create();
    }

    private function track(): PlayList
    {
        return PlayList::factory()->create([
            'media_id' => null,
            'audio_id' => null,
        ]);
    }

    public function test_favoriting_a_track_creates_exactly_one_pivot_row(): void
    {
        $user = $this->user();
        $track = $this->track();

        $response = $this->actingAs($user, 'api')->postJson('/api/favorites', [
            'play_list_id' => $track->id,
        ]);

        $response->assertOk();
        $response->assertJsonStructure(['message', 'data' => ['playList']]);
        $response->assertJsonPath('message', 'Audio is addedd successfully.');

        $this->assertSame(
            1,
            DB::table('favorites')->where('user_id', $user->id)->where('play_list_id', $track->id)->count()
        );
    }

    public function test_toggling_an_already_favorited_track_removes_it(): void
    {
        $user = $this->user();
        $track = $this->track();

        $this->actingAs($user, 'api')->postJson('/api/favorites', ['play_list_id' => $track->id]);
        $response = $this->actingAs($user, 'api')->postJson('/api/favorites', ['play_list_id' => $track->id]);

        $response->assertOk();
        $response->assertJsonPath('message', 'Audio is removed successfully from favorites');
        $response->assertJsonMissingPath('data.playList');

        $this->assertSame(
            0,
            DB::table('favorites')->where('user_id', $user->id)->where('play_list_id', $track->id)->count()
        );
    }

    public function test_repeated_toggle_requests_alternate_between_favorited_and_not(): void
    {
        $user = $this->user();
        $track = $this->track();

        $add1 = $this->actingAs($user, 'api')->postJson('/api/favorites', ['play_list_id' => $track->id]);
        $remove1 = $this->actingAs($user, 'api')->postJson('/api/favorites', ['play_list_id' => $track->id]);
        $add2 = $this->actingAs($user, 'api')->postJson('/api/favorites', ['play_list_id' => $track->id]);

        $add1->assertJsonPath('message', 'Audio is addedd successfully.');
        $remove1->assertJsonPath('message', 'Audio is removed successfully from favorites');
        $add2->assertJsonPath('message', 'Audio is addedd successfully.');

        $this->assertSame(
            1,
            DB::table('favorites')->where('user_id', $user->id)->where('play_list_id', $track->id)->count()
        );
    }

    public function test_database_unique_constraint_rejects_a_duplicate_favorite_row(): void
    {
        $user = $this->user();
        $track = $this->track();

        DB::table('favorites')->insert(['user_id' => $user->id, 'play_list_id' => $track->id]);

        $this->expectException(QueryException::class);
        try {
            DB::table('favorites')->insert(['user_id' => $user->id, 'play_list_id' => $track->id]);
        } catch (QueryException $e) {
            $this->assertSame('23000', $e->getCode(), 'Expected an integrity-constraint-violation SQLSTATE.');
            throw $e;
        }
    }

    /**
     * True concurrent HTTP requests can't be reproduced in a synchronous
     * PHPUnit process - FavoriteConstroller::store()'s own exists()-then-act
     * check always sees a consistent view within a single request. This
     * test instead proves the exact failure mode a genuine race would hit
     * (attach() colliding with the unique constraint) and that it is a
     * QueryException with SQLSTATE 23000 - precisely what the controller's
     * catch block is built to absorb rather than let become a 500.
     */
    public function test_a_duplicate_key_violation_from_a_second_attach_is_the_shape_the_controller_absorbs(): void
    {
        $user = $this->user();
        $track = $this->track();

        $user->favorites()->attach($track->id);

        try {
            $user->favorites()->attach($track->id);
            $this->fail('Expected a duplicate-key QueryException from the second attach().');
        } catch (QueryException $e) {
            $this->assertSame('23000', $e->getCode());
        }

        $this->assertSame(
            1,
            DB::table('favorites')->where('user_id', $user->id)->where('play_list_id', $track->id)->count(),
            'Exactly one row must exist after the collision - the second attach must not have partially applied.'
        );
    }
}
