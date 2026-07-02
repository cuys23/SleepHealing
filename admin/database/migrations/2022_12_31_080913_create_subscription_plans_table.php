<?php

use App\Models\Media;
use App\Models\SubscriptionPlan;
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
        Schema::create((new SubscriptionPlan())->getTable(), function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->foreignIdFor(Media::class)->nullable()->constrained();
            $table->longText('feature_1');
            $table->longText('feature_2');
            $table->longText('feature_3');
            $table->longText('feature_4');
            $table->integer('duration');
            $table->float('amount');
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
        Schema::dropIfExists((new SubscriptionPlan())->getTable());
    }
};
