<?php

use App\Models\Albam;
use App\Models\AlbamShift;
use App\Models\Shift;
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
        Schema::create((new AlbamShift())->getTable(), function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(Albam::class)->constrained();
            $table->foreignIdFor(Shift::class)->constrained();
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
        Schema::dropIfExists((new AlbamShift())->getTable());
    }
};
