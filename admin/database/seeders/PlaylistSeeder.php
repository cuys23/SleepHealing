<?php

namespace Database\Seeders;

use App\Models\PlayList;
use App\Repositories\AlbamRepository;
use Illuminate\Database\Seeder;

class PlaylistSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $albams = (new AlbamRepository())->getAll();
        $totalTracks = $albams->count() * 3;

        $playlists = collect();
        for($i = 0; $i < $totalTracks; $i++){
            $albam = $albams->random();
            $playlist = PlayList::factory()->create([
                'category_id' => $albam->category_id,
                'albam_id' => $albam->id,
            ]);
            $playlist->albams()->attach($albam->id);
            $playlists->push($playlist);
        }

        // Guarantee every album has at least one track, reusing existing tracks.
        foreach ($albams as $albam) {
            if (!$albam->playlists()->exists()) {
                $playlists->random()->albams()->attach($albam->id);
            }
        }
    }
}
