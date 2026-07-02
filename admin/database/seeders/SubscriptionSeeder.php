<?php

namespace Database\Seeders;

use App\Models\Subscription;
use Illuminate\Database\Seeder;
use App\Models\SubscriptionPlan;
use App\Repositories\UserRepository;
use App\Repositories\SubscriptionPlanRepository;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;

class SubscriptionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $users = (new UserRepository())->getAll();

        foreach($users as $user){
            $plan = fake()->randomElement((new SubscriptionPlanRepository())->getAll());
            Subscription::factory()->create([
                'user_id' => $user->id,
                'subscription_plan_id' => $plan->id,
                'expired_at' => now()->addMonths($plan->duration)
            ]);
        }
    }
}
