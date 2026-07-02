<?php

namespace App\Services;
use App\Factories\SmsGatewayFactory;

use App\Models\Notification;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;

class NotificationServices
{
    public function __construct(
        public string $message,
        public array $tokens,
        public $title = 'Maditam',
        public $body = null
    ) {
         $this->sendNotification();
    }

    public function sendNotification()
    {
        $notification = Notification::create($title, $body);

        $firebaseCredentials = storage_path('app/public/firebase_credentials.json');

        if (!file_exists($firebaseCredentials)) {
            return false;
        }

        $messaging = (new Factory)->withServiceAccount($firebaseCredentials)->createMessaging();

        $message = CloudMessage::new()->withNotification($notification);

        try {
            $messaging->sendMulticast($message, $tokens);
        } catch (\Exception $e) {
            logger()->error($e->getMessage());
        }
    }

    public static function sendSmsNotification($phoneNumber, $message)
    {
        $smsService = SmsGatewayFactory::make();
        $smsService->sendSms($phoneNumber, $message);
    }
}
