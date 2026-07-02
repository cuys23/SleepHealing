<?php

namespace App\Http\Controllers;

use App\Models\SMSConfig;
use App\Services\NotificationServices;
use Illuminate\Http\Request;

class SMSConfigurationController extends Controller
{
    public function index()
    {
        $twilio = SMSConfig::where('provider', 'twilio')->first();
        $nexmo = SMSConfig::where('provider', 'nexmo')->first();
        $telesign = SMSConfig::where('provider', 'telesign')->first();
        $messageBird = SMSConfig::where('provider', 'message_bird')->first();
        $telnyx = SMSConfig::where('provider', 'telnyx')->first();

        return view('smsConfig.index', compact('twilio', 'nexmo', 'telesign', 'messageBird', 'telnyx'));
    }

    public function update(Request $request)
    {
        SMSConfig::query()->update(['status' => 0]);

        if ($request->has('provider')) {
            $successMessage = 'SMS Configuration Updated Successfully';
            switch ($request->provider) {
                case 'twilio':
                    $this->twilioConfig($request);
                    $successMessage = 'Twilio account activated successfully';
                    break;
                case 'telesign':
                    $this->telesignConfig($request);
                    $successMessage = 'Telesign account activated successfully';
                    break;
                case 'nexmo':
                    $this->nexmoConfig($request);
                    $successMessage = 'Nexmo account activated successfully';
                    break;
                case 'message_bird':
                    $this->messageBirdConfig($request);
                    $successMessage = 'MessageBird account activated successfully';
                    break;
                case 'telnyx':
                    $this->telnyxConfig($request);
                    $successMessage = 'Telnyx account activated successfully';
                    break;
                default:
                    SMSConfig::query()->where('provider', $request->provider)->update(['status' => 1]);
                    $successMessage = 'Unrecognized provider. No changes made.';
                    break;
            }
            if (isset($request->status) && $request->status == 1) {
                SMSConfig::where('provider', $request->provider)->update(['status' => 1]);
            }

            return to_route('smsConfig.index')->with('success', $successMessage);
        }

        return to_route('smsConfig.index')->with('error', 'No provider specified');
    }


    // Twilio Config
    private function twilioConfig($request)
    {
        $request->validate([
            'twilio_sid' => 'required',
            'twilio_token' => 'required',
            'twilio_from' => 'required',
        ]);


        $data = [
            'twilio_sid' => $request->twilio_sid,
            'twilio_token' => $request->twilio_token,
            'twilio_from' => $request->twilio_from,
        ];

        $jsonData = json_encode($data);
        SMSConfig::updateOrCreate(
            ['provider' => 'twilio'],
            [
                'data' => $jsonData,
                'status' => $request->status,
            ]
        );
    }

    // Telesign Config
    private function telesignConfig($request)
    {
        $request->validate([
            'customer_id' => 'required',
            'api_key' => 'required',
        ]);

        $data = [
            'customer_id' => $request->customer_id,
            'api_key' => $request->api_key,
        ];

        $jsonData = json_encode($data);
        SMSConfig::updateOrCreate(
            ['provider' => 'telesign'],
            [
                'data' => $jsonData,
                'status' => $request->status,
            ]
        );
    }

    // Nexmo Config
    private function nexmoConfig($request)
    {
        $request->validate([
            'nexmo_key' => 'required',
            'nexmo_secret' => 'required',
        ]);

        $data = [
            'nexmo_key' => $request->nexmo_key,
            'nexmo_secret' => $request->nexmo_secret,
        ];

        $jsonData = json_encode($data);
        SMSConfig::updateOrCreate(
            ['provider' => 'nexmo'],
            [
                'data' => $jsonData,
                'status' => $request->status,
            ]
        );
    }

    // MessageBird Config
    private function messageBirdConfig($request)
    {
        $request->validate([
            'api_key' => 'required',
            'from' => 'required',
        ]);

        $data = [
            'api_key' => $request->api_key,
            'from' => $request->from,
        ];

        $jsonData = json_encode($data);
        SMSConfig::updateOrCreate(
            ['provider' => 'message_bird'],
            [
                'data' => $jsonData,
                'status' => $request->status,
            ]
        );
    }

    // Telnyx Config
    private function telnyxConfig($request)
    {
        $request->validate([
            'api_key' => 'required',
            'from' => 'required',
        ]);

        $data = [
            'api_key' => $request->api_key,
            'from' => $request->from,
        ];

        $jsonData = json_encode($data);
        SMSConfig::updateOrCreate(
            ['provider' => 'telnyx'],
            [
                'data' => $jsonData,
                'status' => $request->status,
            ]
        );
    }

    public function test()
    {
        $phoneNumber = '+919876543210';
        $message = 'Test Message';
        NotificationServices::sendSmsNotification($phoneNumber, $message);
    }
}
