<?php

namespace Database\Factories;

use App\Models\Media;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Albam>
 */
class AlbamFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    private static array $albams = [
        ['name' => 'Ocean Waves', 'description' => 'The rhythmic sound of waves rolling onto a quiet shore.'],
        ['name' => 'Rainy Night', 'description' => 'Steady rainfall to help you drift off to sleep.'],
        ['name' => 'Forest Whispers', 'description' => 'Birdsong and rustling leaves from a peaceful forest.'],
        ['name' => 'Mountain Air', 'description' => 'A cool mountain breeze with distant echoes.'],
        ['name' => 'Midnight Calm', 'description' => 'A quiet soundscape for late-night relaxation.'],
        ['name' => 'Gentle Rain', 'description' => 'Soft rain falling steadily on a rooftop.'],
        ['name' => 'Starlit Sky', 'description' => 'Ambient tones inspired by a clear night sky.'],
        ['name' => 'Moonlight Meditation', 'description' => 'A guided journey through moonlit stillness.'],
        ['name' => 'Peaceful Mind', 'description' => 'Calming tones to quiet a busy mind.'],
        ['name' => 'Tranquil Waters', 'description' => 'The sound of a slow-moving stream.'],
        ['name' => 'Quiet Morning', 'description' => 'Soft ambience to ease gently into the day.'],
        ['name' => 'Autumn Breeze', 'description' => 'Leaves rustling in a cool autumn wind.'],
        ['name' => 'Winter Hush', 'description' => 'The stillness of freshly fallen snow.'],
        ['name' => 'Summer Night', 'description' => 'Crickets chirping in the warm night air.'],
        ['name' => 'Desert Wind', 'description' => 'Wind moving softly across open desert sand.'],
        ['name' => 'Cozy Fireplace', 'description' => 'The gentle crackle of a warm fire.'],
        ['name' => 'Distant Thunderstorm', 'description' => 'Rolling thunder and steady rain in the distance.'],
        ['name' => 'Lavender Fields', 'description' => 'Soft music inspired by open countryside.'],
        ['name' => 'Floating Clouds', 'description' => 'Airy, weightless ambient tones for deep relaxation.'],
        ['name' => 'Silent Lake', 'description' => 'Still water and a gentle breeze at dusk.'],
        ['name' => 'Morning Birdsong', 'description' => 'A chorus of birds welcoming a new day.'],
        ['name' => 'Deep Sleep Journey', 'description' => 'A long, slow descent into restful sleep.'],
        ['name' => 'Candlelight Calm', 'description' => 'Soft, warm tones for a quiet evening.'],
        ['name' => 'Gentle Piano Sleep', 'description' => 'Slow piano melodies to unwind before bed.'],
        ['name' => 'Cabin in the Woods', 'description' => 'The quiet creak of wood and a soft breeze outside.'],
        ['name' => 'Rooftop Rain', 'description' => 'Rain tapping gently against a tin roof.'],
        ['name' => 'Northern Lights', 'description' => 'Ethereal ambient tones inspired by the night sky.'],
        ['name' => 'Slow Breathing', 'description' => 'A guided session focused on slow, steady breathing.'],
        ['name' => 'Evening Stillness', 'description' => 'A calm close to the day, perfect for winding down.'],
        ['name' => 'Waves at Dusk', 'description' => 'Soft waves as the sun sets over the horizon.'],
    ];

    public function definition()
    {
        $albam = $this->faker->randomElement(self::$albams);

        return [
            'name' => $albam['name'],
            'description' => $albam['description'],
            'status' => $this->faker->boolean(),
            'media_id' => null,
            'category_id' => 1, // update when run seeder
        ];
    }
}
