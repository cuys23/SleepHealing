<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Verification>
 */
class VerificationFactory extends Factory
{
    public function definition()
    {
        return [
            'email' => fake()->unique()->safeEmail(),
            'otp' => fake()->unique()->numberBetween(123400, 999999),
            'token' => hash('sha256', fake()->unique()->uuid()),
            'expires_at' => now()->addMinutes(15),
        ];
    }

    public function expired()
    {
        return $this->state(fn () => [
            'expires_at' => now()->subMinute(),
        ]);
    }
}
