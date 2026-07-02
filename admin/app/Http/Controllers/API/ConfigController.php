<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\PaymentMethodResource;
use App\Http\Resources\WebSettingResource;
use App\Models\PaymentGateway;
use App\Models\WebSetting;
use Illuminate\Http\Request;

class ConfigController extends Controller
{
    public function index()
    {
        $webData = WebSetting::first();

        $payment_gateway = PaymentGateway::where('is_active', 1)->get();
        return response()->json([
            'status' => true,
            'message' => 'Config data fetched successfully!',
            'data' => [
                'web_setting' => WebSettingResource::make($webData),
                'payment_gateway' => PaymentMethodResource::collection($payment_gateway),
            ]
        ]);
    }
}
