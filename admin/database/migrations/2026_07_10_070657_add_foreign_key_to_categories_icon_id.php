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
        // migration: 0 rows have a non-null icon_id that doesn't reference
        // an existing media row. categories.icon_id had no FK at all (it
        // was added via `$table->foreignId('icon_id')->nullable();` without
        // `->constrained()`), unlike categories.media_id which already has
        // one. nullOnDelete (not cascade): deleting an icon Media row must
        // clear the category's icon, not delete the category itself.
        Schema::table('categories', function (Blueprint $table) {
            $table->foreign('icon_id', 'categories_icon_id_foreign')
                ->references('id')
                ->on('media')
                ->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('categories', function (Blueprint $table) {
            $table->dropForeign('categories_icon_id_foreign');
        });
    }
};
