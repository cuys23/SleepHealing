<?php


namespace App\Repositories;

use App\Models\Setting;
use Illuminate\Http\Request;

class SettingRepository extends Repository
{
    public function model()
    {
        return Setting::class;
    }

    public function findBySlug($slug)
    {
       return $this->model()::where('slug', $slug)->first();
    }

    public function updateByRequest(Request $request, Setting $setting): Setting
    {
        $setting->update([
            'title' => $request->title,
            'content' => $request->content,
        ]);
        return $setting;
    }

}
