<?php

namespace Database\Factories;

use App\Models\Media;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Category>
 */
class CategoryFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    private static array $categories = [
        ['name' => 'Sleep Stories', 'description' => "Gentle bedtime stories designed to ease you into a restful night's sleep."],
        ['name' => 'Meditation', 'description' => 'Guided meditations to calm the mind and reduce daily stress.'],
        ['name' => 'Nature Sounds', 'description' => 'Immersive soundscapes from forests, oceans, and rainfall.'],
        ['name' => 'Calm Music', 'description' => 'Soft instrumental music to help you relax and unwind.'],
        ['name' => 'White Noise', 'description' => 'Steady ambient sounds that mask distractions and aid deep sleep.'],
        ['name' => 'Breathing Exercises', 'description' => 'Simple breathing techniques to relieve anxiety and tension.'],
        ['name' => 'Kids Sleep', 'description' => "Soothing audio made especially for children's bedtime routines."],
        ['name' => 'Focus & Study', 'description' => 'Background audio to help you concentrate and stay productive.'],
        ['name' => 'Anxiety Relief', 'description' => 'Calming sessions to ease worry and promote emotional balance.'],
        ['name' => 'Morning Motivation', 'description' => 'Uplifting audio to start your day with clarity and energy.'],
        ['name' => 'Self-Care', 'description' => 'Short practices for mindfulness and everyday well-being.'],
        ['name' => 'Deep Sleep', 'description' => 'Long-form audio crafted to support uninterrupted, deep sleep.'],
        ['name' => 'Relaxing Piano', 'description' => 'Soft piano melodies for quiet, unwinding moments.'],
        ['name' => 'Ocean & Rain', 'description' => 'Coastal waves and rainfall recorded for deep relaxation.'],
        ['name' => 'Yoga & Stretching', 'description' => 'Calming audio to accompany gentle movement and stretching.'],
        ['name' => 'Stress Relief', 'description' => 'Short guided sessions to release tension after a long day.'],
        ['name' => 'Mindful Moments', 'description' => 'Brief mindfulness exercises for busy schedules.'],
        ['name' => 'Bedtime for Adults', 'description' => 'Slow, soothing narration designed to help adults fall asleep.'],
        ['name' => 'Travel Relaxation', 'description' => 'Calming audio for flights, trains, and long commutes.'],
        ['name' => 'Evening Wind Down', 'description' => 'A gentle transition from your busy day into restful sleep.'],
    ];

    public function definition()
    {
        $category = $this->faker->randomElement(self::$categories);

        return [
            'name' => $category['name'],
            'description' => $category['description'],
            'status' => $this->faker->boolean(),
            'media_id' => null,
        ];
    }
}
