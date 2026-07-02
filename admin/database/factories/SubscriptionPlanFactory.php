<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\SubscriptionPlan>
 */
class SubscriptionPlanFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition()
    {
        return [
            'name' => 'Maditam Premium',
            'feature_1' => 'Unlimited access to all sleep stories and meditations',
            'feature_2' => 'Ad-free listening',
            'feature_3' => 'New content added every week',
            'feature_4' => 'Offline downloads for any track',
            'duration' => 1,
            'amount' => $this->faker->randomFloat(2, 100, 500)
        ];
    }
}
