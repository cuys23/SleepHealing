<?php

namespace Database\Seeders;

use App\Models\Albam;
use App\Models\AlbamShift;
use App\Models\Category;
use App\Models\Shift;
use Illuminate\Database\Seeder;

class AlbamSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $cetegories = Category::all();
        $shiftIds = Shift::pluck('id');

        $totalAlbums = 20;
        $categoryCount = max($cetegories->count(), 1);
        $base = intdiv($totalAlbums, $categoryCount);
        $remainder = $totalAlbums % $categoryCount;

        foreach ($cetegories as $index => $cetegory) {
            $count = $base + ($index < $remainder ? 1 : 0);

            for ($i = 0; $i < $count; $i++) {
                $albam = Albam::factory()->create([
                    'category_id' => $cetegory->id
                ]);
                $albam->categories()->attach($cetegory->id);

                if ($shiftIds->isNotEmpty()) {
                    AlbamShift::create([
                        'albam_id' => $albam->id,
                        'shift_id' => $shiftIds->random(),
                    ]);
                }
            }
        }
    }
}
