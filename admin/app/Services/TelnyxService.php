<?php 
namespace App\Services;

use App\Interfaces\SmsGatewayInterface;

class TelnyxService implements SmsGatewayInterface
{
    public function __construct(array $config)
    {

    }

    public function sendSms($phoneNumber, $message)
    {
        // 
    }

}