<?php

use App\Models\PlayList;
use App\Models\Readmore;
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
        Schema::create((new Readmore())->getTable(), function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->foreignIdFor(PlayList::class)->constrained();
            $table->string('sub_title')->nullable();
            $table->longText('content')->nullable();
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
        Schema::dropIfExists((new Readmore())->getTable());
    }
};
