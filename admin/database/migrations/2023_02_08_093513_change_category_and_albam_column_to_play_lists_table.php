<?php

use App\Models\Albam;
use App\Models\Category;
use App\Models\PlayList;
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
        Schema::table((new PlayList())->getTable(), function (Blueprint $table) {
            $table->foreignIdFor(Category::class)->nullable()->change();
            $table->foreignIdFor(Albam::class)->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table((new PlayList())->getTable(), function (Blueprint $table) {
            $table->dropColumn('category_id');
            $table->dropColumn('albam_id');
        });
    }
};
