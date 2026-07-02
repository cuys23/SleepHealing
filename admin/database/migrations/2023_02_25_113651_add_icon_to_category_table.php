<?php

use App\Models\Category;
use App\Models\Media;
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
        Schema::table((new Category())->getTable(), function (Blueprint $table) {
            $table->foreignId('icon_id')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table((new Category())->getTable(), function (Blueprint $table) {
           $table->dropColumn('icon_id');
        });
    }
};
