<?php
namespace App\Services;

use App\Interfaces\SmsGatewayInterface;
use App\Models\SMSConfig;

class NexmoService implements SmsGatewayInterface
{
    private $apiKey;
    private $apiSecret;

    public function __construct(array $config)
    {
        $this->apiKey = $config['nexmo_key'];
        $this->apiSecret = $config['nexmo_secret'];
        // Initialize Nexmo client or any setup needed
    }

    public function sendSms($phoneNumber, $message)
    {
        $configData = json_decode(SMSConfig::where('status', true)->where('provider', 'nexmo')->firstOrFail()->data, true);
        $send = Nexmo::message()->send([
            'to' => $phoneNumber,
            'from' => $configData['from'],
            'text' => $message
        ]);
        if ($send) {
            return response()->json([
                'success' => true,
                'message' => 'Message sent successfully',
            ]);
        }
        return response()->json([
            'success' => false,
            'message' => 'Failed to send message',
        ]);
    }
}
