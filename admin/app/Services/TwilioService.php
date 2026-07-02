<?php
namespace App\Services;

use App\Interfaces\SmsGatewayInterface;
use Twilio\Rest\Client;

class TwilioService implements SmsGatewayInterface
{
    private $client;
    private $from;

    public function __construct(array $config)
    {
        $this->client = new Client($config['twilio_sid'], $config['twilio_token']);
        $this->from = $config['twilio_from'];
    }

    public function sendSms($phoneNumber, $message)
    {
        $this->client->messages->create($phoneNumber, [
            'from' => $this->from,
            'body' => $message
        ]);
    }
}
