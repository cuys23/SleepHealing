<?php

use App\Models\Media;
use App\Models\WebSetting;
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
        Schema::table((new WebSetting())->getTable(), function (Blueprint $table) {
            $table->foreignId('logo_id')->nullable()->constrained((new Media())->getTable());
            $table->foreignId('favicon_id')->nullable()->constrained((new Media())->getTable());
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table((new WebSetting())->getTable(), function (Blueprint $table) {
            $table->dropColumn('logo_id', 'favicon_id');
        });
    }
};
