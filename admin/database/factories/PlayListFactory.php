<?php

namespace Database\Factories;

use App\Models\Media;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\PlayList>
 */
class PlayListFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    private static array $tracks = [
        ['name' => '10-Minute Body Scan', 'description' => 'A short guided practice to release tension from head to toe.'],
        ['name' => 'Breathing for Sleep', 'description' => 'Slow breathing patterns to prepare your body for rest.'],
        ['name' => 'Letting Go of the Day', 'description' => 'A gentle wind-down session to release the stress of the day.'],
        ['name' => 'A Walk in the Forest', 'description' => 'An imagined walk through a quiet, peaceful forest.'],
        ['name' => 'Counting Sheep', 'description' => 'A classic, calming way to guide your mind toward sleep.'],
        ['name' => 'Soft Rain on Leaves', 'description' => 'Rainfall recorded gently falling through forest leaves.'],
        ['name' => 'Waves on the Shore', 'description' => 'The steady rhythm of ocean waves reaching the sand.'],
        ['name' => 'Quiet Candlelight', 'description' => 'A slow, soothing session for late-evening relaxation.'],
        ['name' => 'Releasing Tension', 'description' => 'A short practice to relax the shoulders, neck, and jaw.'],
        ['name' => 'Drifting Off', 'description' => 'Soft narration designed to ease you gently into sleep.'],
        ['name' => 'Morning Calm', 'description' => 'A gentle start to the day with slow, mindful breathing.'],
        ['name' => 'Deep Rest', 'description' => 'A long-form track designed for uninterrupted deep sleep.'],
        ['name' => 'Quiet Mind', 'description' => 'A short meditation to settle a busy, wandering mind.'],
        ['name' => 'Evening Unwind', 'description' => 'A slow transition from a busy day into restful evening.'],
        ['name' => 'Gentle Reset', 'description' => 'A brief practice to reset focus and ease stress.'],
        ['name' => 'Falling Leaves', 'description' => 'The soft sound of leaves falling in a quiet autumn breeze.'],
        ['name' => 'Warm Firelight', 'description' => 'The gentle crackle of a fire on a quiet evening.'],
        ['name' => 'Slow River', 'description' => 'The calm, steady flow of a river through the countryside.'],
        ['name' => 'Night Sky Meditation', 'description' => 'A guided journey beneath a calm, starlit sky.'],
        ['name' => 'Soothing Piano', 'description' => 'Slow, gentle piano notes for quiet reflection.'],
        ['name' => 'Peaceful Breathing', 'description' => 'A steady breathing exercise to calm the nervous system.'],
        ['name' => 'Winding Down', 'description' => 'A relaxed narration to help you settle in for the night.'],
        ['name' => 'Rain on the Window', 'description' => 'The steady patter of rain against glass.'],
        ['name' => 'Stillness Within', 'description' => 'A quiet meditation focused on inner calm.'],
        ['name' => 'Gentle Morning Light', 'description' => 'A soft, uplifting track to start the morning slowly.'],
        ['name' => 'Letting the Mind Rest', 'description' => 'A calming session to quiet racing thoughts before sleep.'],
        ['name' => 'Soft Ocean Breeze', 'description' => 'A light coastal breeze paired with distant waves.'],
        ['name' => 'Slow Descent to Sleep', 'description' => 'A gradual, guided path toward deep, restful sleep.'],
        ['name' => 'Quiet Reflection', 'description' => 'A short mindful pause to reflect on the day.'],
        ['name' => 'Quieting the Storm', 'description' => 'A calming session to ease anxious or racing thoughts.'],
    ];

    public function definition()
    {
        $track = $this->faker->randomElement(self::$tracks);

        return [
            'name' => $track['name'],
            'description' => $track['description'],
            'status' => $this->faker->boolean(),
            'duration' => rand(5, 20) . ':' . rand(1, 59),
            'media_id' => null,
            'category_id' => 1, // update when run seeder
            'albam_id' => 1, // update when run seeder
            'audio_id' => Media::factory()->create([
                'src' => 'audio/dummy-audio.mp3'
            ])
        ];
    }
}
