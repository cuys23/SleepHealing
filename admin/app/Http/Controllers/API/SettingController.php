<?php

namespace App\Http\Controllers\API;

use App\Models\Setting;
use File;
use App\Http\Controllers\Controller;
use App\Http\Resources\SettingResource;
use App\Http\Resources\TranslateResource;
use App\Models\WebSetting;

class SettingController extends Controller
{
    public function show($page)
    {
        $setting = Setting::where('slug', $page)->firstOrFail();
        return $this->json($setting->title, [
            'setting' => new SettingResource($setting)
        ]);
    }

    public function switchLang($local)
    {
        return $this->json('Translated', [
            'local' => (new TranslateResource())->toArray($local)
        ]);
    }

    public function generalSettings()
    {
        return $this->json('General Settings', [
            'ads_show' => (bool) WebSetting::first()?->ads_show ?? true,
        ]);
    }
}
