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
        // migration: 0 rows violate (albam_id, play_list_id) uniqueness.
        // Column order matches the real query - PlayListController::index()
        // runs $albam->playlists()->active()->get(), which filters
        // playlist_albams.albam_id by equality and joins on play_list_id,
        // confirmed via EXPLAIN. This single unique index both enforces
        // "one track per album, once" and serves that query - no separate
        // composite index is added.
        Schema::table('playlist_albams', function (Blueprint $table) {
            $table->unique(['albam_id', 'play_list_id'], 'playlist_albams_album_playlist_unique');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // As with the favorites migration, adding a composite unique index
        // whose leftmost column is albam_id makes the original
        // single-column `playlist_albams_albam_id_foreign` index redundant,
        // and MySQL/InnoDB drops it automatically. That index must be
        // restored before dropping the unique constraint, or MySQL rejects
        // the drop (error 1553) because the albam_id foreign key would be
        // left without any supporting index.
        Schema::table('playlist_albams', function (Blueprint $table) {
            $table->index('albam_id', 'playlist_albams_albam_id_foreign');
        });
        Schema::table('playlist_albams', function (Blueprint $table) {
            $table->dropUnique('playlist_albams_album_playlist_unique');
        });
    }
};
