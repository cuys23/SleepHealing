<?php
namespace App\Services;

use App\Interfaces\SmsGatewayInterface;
use App\Models\SMSConfig;
use MessageBird\Client;
use MessageBird\Objects\Message;

class MessageBirdService implements SmsGatewayInterface
{
    public function __construct(array $config)
    {
        // Initialize Nexmo client or any setup needed
    }

    public function sendSms($phoneNumber, $text)
    {
        try {
            $configData = json_decode(SMSConfig::where('status', true)->where('provider', 'message_bird')->firstOrFail()->data, true);
            $messagebird = new Client($configData['api_key']);
            $smsMessage = new Message();
            $smsMessage->originator = $configData['from'];
            $smsMessage->recipients = [$phoneNumber];
            $smsMessage->body = $text;
    
            $response = $messagebird->messages->create($smsMessage);
            return response()->json([
                'success' => true,
                'status' => 200,
                'message' => 'Message sent successfully.',
                'data' => $response
            ]);
        } catch (\Exception $e) {

            return response()->json([
                'success' => false,
                'status' => $e->getCode() ? $e->getCode() : 500,
                'message' => 'Failed to send message. Error: ' . $e->getMessage()
            ]);
        }
    }

}