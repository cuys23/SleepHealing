<?php

namespace Database\Seeders;

use App\Models\SubscriptionPlan;
use Illuminate\Database\Seeder;

class SubscriptionPlanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $plans = [
            [
                'duration' => 6,
                'name' => 'Maditam Plus',
                'feature_1' => 'Unlimited access to all sleep stories and meditations',
                'feature_2' => 'Ad-free listening',
                'feature_3' => 'New content added every week',
                'feature_4' => 'Offline downloads for up to 10 tracks',
                'amount' => 29.99,
            ],
            [
                'duration' => 12,
                'name' => 'Maditam Premium',
                'feature_1' => 'Everything in Maditam Plus',
                'feature_2' => 'Unlimited offline downloads',
                'feature_3' => 'Early access to new releases',
                'feature_4' => 'Priority customer support',
                'amount' => 49.99,
            ],
            [
                'duration' => 24,
                'name' => 'Maditam Premium+',
                'feature_1' => 'Everything in Maditam Premium',
                'feature_2' => 'Exclusive premium-only content',
                'feature_3' => 'Family sharing for up to 4 members',
                'feature_4' => 'Best value, billed once every 2 years',
                'amount' => 79.99,
            ],
        ];

        foreach($plans as $plan){
            SubscriptionPlan::factory()->create($plan);
        }
    }
}
