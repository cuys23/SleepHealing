<?php

namespace Database\Seeders;

use App\Enums\Shift as EnumsShift;
use App\Models\AlbamShift;
use App\Models\Shift;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Storage;

class ShiftSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        AlbamShift::query()->delete();
        $shift = Shift::query();
        foreach ($shift->get() as $category) {
            if ($category->media && Storage::exists($category->media->src)) {
                Storage::delete($category->media->src);
            }
        }
        $shift->delete();

        $shifts = EnumsShift::cases();
        foreach ($shifts as $shift) {
            Shift::create([
                'type' => $shift->value,
            ]);
        }
    }
}
