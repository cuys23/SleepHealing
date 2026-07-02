<?php


namespace App\Repositories;

use App\Models\Notification;

class NotificationRepository extends Repository
{
    public function model()
    {
        return Notification::class;
    }

    public function notificationListByStatus($read = null)
    {
        $user = auth()->user();
        $notifications = $this->query()->where('user_id', $user->id);

        if ($read) {
            $notifications = $notifications->where('isRead', $read);
        }

        return $notifications->latest()->get();
    }

    public function store($userId, $message, $title): Notification
    {
        return $this->create([
            'user_id' => $userId,
            'title' => $title,
            'message' => $message,
            'isRead' => (int)0
        ]);
    }

    public function read(Notification $notification): Notification
    {
        $notification->update([
            'isRead' => 1
        ]);
        return $notification;
    }
}
