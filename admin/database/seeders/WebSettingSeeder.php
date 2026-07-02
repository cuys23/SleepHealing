<?php

namespace Database\Seeders;

use App\Models\WebSetting;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class WebSettingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        WebSetting::truncate();
        WebSetting::create([
            'name' => 'Maditam Podcasts',
            'title' => 'Maditam Podcasts | Engage, Inspire, Entertain',
            'subtitle' => 'Dive deep into the world of ideas with Maditam Podcasts. Explore, learn, and be entertained.',
            'address' => '123 Podcast Avenue, Audio City, Soundwave State 78910',
            'mobile' => '+123-456-7890',
            'email' => 'listen@maditampodcasts.com',
        ]);
    }
}
