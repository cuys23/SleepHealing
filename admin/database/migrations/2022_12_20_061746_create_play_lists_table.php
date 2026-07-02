<?php

use App\Models\Albam;
use App\Models\Media;
use App\Models\Category;
use App\Models\PlayList;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create((new PlayList())->getTable(), function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->longText('description')->nullable();
            $table->longText('duration')->nullable();
            $table->boolean('status')->default(true);
            $table->foreignIdFor(Category::class)->constrained();
            $table->foreignIdFor(Albam::class)->constrained();
            $table->foreignIdFor(Media::class)->nullable()->constrained();
            $table->foreignId('audio_id')->nullable()->constrained((new Media())->getTable());
            $table->softDeletes();
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
        Schema::dropIfExists((new PlayList())->getTable());
    }
};
