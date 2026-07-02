<?php 
namespace App\Interfaces;

interface SmsGatewayInterface
{
    public function sendSms($phoneNumber, $message);
}