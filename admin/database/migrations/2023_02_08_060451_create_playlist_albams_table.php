<?php

use App\Models\Albam;
use App\Models\PlayList;
use App\Models\PlaylistAlbam;
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
        Schema::create((new PlaylistAlbam())->getTable(), function (Blueprint $table) {
            $table->id();
            $table->foreignId('play_list_id')->constrained((new PlayList())->getTable());
            $table->foreignId('albam_id')->constrained((new Albam())->getTable());
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists((new PlaylistAlbam())->getTable());
    }
};
