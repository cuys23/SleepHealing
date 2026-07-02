<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\WebSettingResource;
use App\Models\WebSetting;
use Illuminate\Http\Request;

class ConfigController extends Controller
{
    public function index()
    {
        $webData = WebSetting::first();

        return response()->json([
            'status' => true,
            'message' => 'Config data fetched successfully!',
            'data' => [
                'web_setting' => WebSettingResource::make($webData),
            ]
        ]);
    }
}
