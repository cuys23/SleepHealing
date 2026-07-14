<?php

namespace Tests\Feature\Admin;

use App\Models\Category;
use App\Models\Media;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

/**
 * Regression tests for the database-audit finding: categories.icon_id was
 * added via `$table->foreignId('icon_id')->nullable();` without
 * `->constrained()`, so unlike categories.media_id it had no real foreign
 * key. 0 orphan rows were confirmed before adding
 * categories_icon_id_foreign (ON DELETE SET NULL, matching the existing
 * media_id convention's intent of preserving the parent row).
 */
class CategoryIconForeignKeyTest extends TestCase
{
    use DatabaseTransactions;

    public function test_a_category_can_reference_an_existing_media_icon(): void
    {
        $icon = Media::factory()->create();
        $category = Category::factory()->create(['media_id' => null, 'icon_id' => $icon->id]);

        $this->assertSame($icon->id, $category->fresh()->icon_id);
        $this->assertSame($icon->id, $category->icon->id);
    }

    public function test_an_invalid_icon_id_is_rejected_by_the_database(): void
    {
        $this->expectException(QueryException::class);
        Category::factory()->create(['media_id' => null, 'icon_id' => 999999999]);
    }

    public function test_deleting_icon_media_sets_category_icon_id_to_null_and_preserves_the_category(): void
    {
        $icon = Media::factory()->create();
        $category = Category::factory()->create(['media_id' => null, 'icon_id' => $icon->id]);

        $icon->delete();

        $category->refresh();
        $this->assertNull($category->icon_id);
        $this->assertNotNull(Category::find($category->id), 'Deleting the icon media must not delete the category.');
    }

    public function test_category_api_json_shape_is_unchanged_with_and_without_an_icon(): void
    {
        $withIcon = Category::factory()->create(['media_id' => null, 'icon_id' => Media::factory()->create()->id, 'status' => true]);
        $withoutIcon = Category::factory()->create(['media_id' => null, 'icon_id' => null, 'status' => true]);

        $response = $this->getJson('/api/categories');
        $response->assertOk();

        foreach (['category'] as $key) {
            $response->assertJsonStructure(['message', 'data' => [$key => [['id', 'name', 'description', 'thumbnail', 'icon']]]]);
        }

        $body = collect($response->json('data.category'));
        $withIconEntry = $body->firstWhere('id', $withIcon->id);
        $withoutIconEntry = $body->firstWhere('id', $withoutIcon->id);

        $this->assertNotNull($withIconEntry);
        $this->assertNotNull($withoutIconEntry);
        $this->assertIsString($withIconEntry['icon']);
        $this->assertIsString($withoutIconEntry['icon'], 'A category without an icon must still return a valid fallback icon URL string.');
    }
}
