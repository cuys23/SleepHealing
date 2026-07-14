<?php

namespace Tests\Feature\Admin;

use App\Http\Middleware\VerifyCsrfToken;
use App\Models\Albam;
use App\Models\AlbamCategory;
use App\Models\Category;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

/**
 * Regression tests for the albam_categories database-audit finding: the
 * pivot table (album-in-category) had no composite index and no unique
 * constraint. Business rule confirmed: one album must not be linked more
 * than once to the same category.
 *
 * Fix: UNIQUE(category_id, albam_id) as albam_categories_category_album_unique,
 * matching the column order the public API's category -> album query
 * filters and joins on (confirmed via EXPLAIN).
 */
class AlbamCategoryTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();
        $this->withoutMiddleware(VerifyCsrfToken::class);
    }

    private function admin(): User
    {
        $user = User::factory()->create();
        $user->assignRole(\Spatie\Permission\Models\Role::findOrCreate('admin', 'web'));

        return $user;
    }

    private function albam(): Albam
    {
        // status forced true: AlbamController/CategoryController::index()
        // filter via ->active(), and the factory default is a random
        // boolean.
        return Albam::factory()->create(['media_id' => null, 'status' => true]);
    }

    private function category(): Category
    {
        return Category::factory()->create(['media_id' => null]);
    }

    public function test_the_same_album_cannot_be_linked_twice_to_the_same_category_at_the_database_level(): void
    {
        $albam = $this->albam();
        $category = $this->category();

        DB::table('albam_categories')->insert([
            'albam_id' => $albam->id,
            'category_id' => $category->id,
        ]);

        $this->expectException(QueryException::class);
        try {
            DB::table('albam_categories')->insert([
                'albam_id' => $albam->id,
                'category_id' => $category->id,
            ]);
        } catch (QueryException $e) {
            $this->assertSame('23000', $e->getCode());
            throw $e;
        }
    }

    public function test_albam_repository_firstorcreate_is_idempotent_for_the_same_album_and_category(): void
    {
        $albam = $this->albam();
        $category = $this->category();

        // Mirrors AlbamRepository::storeByRequest()'s write path.
        AlbamCategory::firstOrCreate(['albam_id' => $albam->id, 'category_id' => $category->id]);
        AlbamCategory::firstOrCreate(['albam_id' => $albam->id, 'category_id' => $category->id]);

        $this->assertSame(
            1,
            DB::table('albam_categories')->where('albam_id', $albam->id)->where('category_id', $category->id)->count()
        );
    }

    public function test_one_album_can_still_belong_to_multiple_categories(): void
    {
        $albam = $this->albam();
        $categoryOne = $this->category();
        $categoryTwo = $this->category();

        AlbamCategory::firstOrCreate(['albam_id' => $albam->id, 'category_id' => $categoryOne->id]);
        AlbamCategory::firstOrCreate(['albam_id' => $albam->id, 'category_id' => $categoryTwo->id]);

        $this->assertSame(2, DB::table('albam_categories')->where('albam_id', $albam->id)->count());
    }

    public function test_one_category_can_still_contain_multiple_albums(): void
    {
        $category = $this->category();
        $albamOne = $this->albam();
        $albamTwo = $this->albam();

        AlbamCategory::firstOrCreate(['albam_id' => $albamOne->id, 'category_id' => $category->id]);
        AlbamCategory::firstOrCreate(['albam_id' => $albamTwo->id, 'category_id' => $category->id]);

        $this->assertSame(2, DB::table('albam_categories')->where('category_id', $category->id)->count());

        $api = $this->getJson('/api/albams?category='.$category->id);
        $api->assertOk();
        $this->assertCount(2, $api->json('data.albams'));
    }

    /**
     * Admin "Category Album tree" screen (CategoryController::updateAlbum)
     * writes via $category->albams()->sync(...), which is already
     * duplicate-safe by construction - this proves the unique constraint
     * doesn't break that existing, already-correct admin flow.
     */
    public function test_admin_category_album_tree_sync_remains_compatible_with_the_unique_constraint(): void
    {
        $category = $this->category();
        $albamOne = $this->albam();
        $albamTwo = $this->albam();

        $response = $this->actingAs($this->admin())->post(route('category.tree.update', $category), [
            'albams' => [$albamOne->id, $albamTwo->id],
        ]);

        $response->assertRedirect(route('category.index'));
        $this->assertSame(2, DB::table('albam_categories')->where('category_id', $category->id)->count());
    }
}
