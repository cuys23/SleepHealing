<?php
namespace App\Factories;

use App\Interfaces\SmsGatewayInterface;
use App\Models\SMSConfig;
use App\Services\{
    TwilioService,
    NexmoService,
    TelesignService,
    MessageBirdService,
    TelnyxService
};

class SmsGatewayFactory
{
    public static function make(): SmsGatewayInterface
    {
        $activeConfig = SMSConfig::where('status', true)->firstOrFail();
        $configData = json_decode($activeConfig->data, true);

        switch ($activeConfig->provider) {
            case 'twilio':
                return new TwilioService($configData);
            case 'nexmo':
                return new NexmoService($configData);
            case 'telesign':
                return new TelesignService($configData);
            case 'message_bird':
                return new MessageBirdService($configData);
            case 'telnyx':
                return new TelnyxService($configData);
            default:
                throw new \Exception("Unsupported SMS gateway: {$activeConfig->provider}");
        }
    }
}
