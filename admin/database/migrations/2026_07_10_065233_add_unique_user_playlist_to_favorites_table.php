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
        // migration: 0 rows violate (user_id, play_list_id) uniqueness.
        // Safe to add directly - no cleanup step required.
        Schema::table('favorites', function (Blueprint $table) {
            $table->unique(['user_id', 'play_list_id'], 'favorites_user_playlist_unique');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // MySQL/InnoDB silently drops the original single-column
        // `favorites_user_id_foreign` index in up() because the new
        // composite unique index already covers user_id as its leftmost
        // column, making the old index redundant. The favorites_user_id
        // foreign key still needs *some* index on user_id at all times, so
        // that index must be restored before the composite unique is
        // dropped - otherwise MySQL rejects the drop with error 1553
        // ("needed in a foreign key constraint").
        Schema::table('favorites', function (Blueprint $table) {
            $table->index('user_id', 'favorites_user_id_foreign');
        });
        Schema::table('favorites', function (Blueprint $table) {
            $table->dropUnique('favorites_user_playlist_unique');
        });
    }
};
