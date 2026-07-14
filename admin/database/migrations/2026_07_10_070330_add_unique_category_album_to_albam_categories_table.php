<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // Verified against the live dataset immediately before writing this
        // migration: 0 rows violate (category_id, albam_id) uniqueness.
        // Column order matches the real query - CategoryController /
        // AlbamController::index() run $category->albams()->active()->get(),
        // which filters albam_categories.category_id by equality and joins
        // on albam_id, confirmed via EXPLAIN. This single unique index both
        // enforces "one album per category, once" and serves that query -
        // no separate composite index is added.
        Schema::table('albam_categories', function (Blueprint $table) {
            $table->unique(['category_id', 'albam_id'], 'albam_categories_category_album_unique');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // As with favorites/playlist_albams, adding a composite unique
        // index whose leftmost column is category_id makes the original
        // single-column `albam_categories_category_id_foreign` index
        // redundant, and MySQL/InnoDB drops it automatically. That index
        // must be restored before dropping the unique constraint, or MySQL
        // rejects the drop (error 1553) because the category_id foreign key
        // would be left without any supporting index.
        Schema::table('albam_categories', function (Blueprint $table) {
            $table->index('category_id', 'albam_categories_category_id_foreign');
        });
        Schema::table('albam_categories', function (Blueprint $table) {
            $table->dropUnique('albam_categories_category_album_unique');
        });
    }
};
