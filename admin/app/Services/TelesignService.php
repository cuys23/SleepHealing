<?php 
namespace App\Services;

use App\Interfaces\SmsGatewayInterface;
use Telesign;


class TelesignService implements SmsGatewayInterface
{
    protected $messaging;
    public function __construct(array $config)
    {
        $this->messaging = new Telesign($config['customer_id'], $config['api_key']);
    }

    public function sendSms($phoneNumber, $message)
    {
        $this->messaging->sms($phoneNumber, $message);
    }

}