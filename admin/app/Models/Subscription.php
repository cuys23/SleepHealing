<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    use HasFactory;
    protected $guarded = ['id'];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function subscriptionPlan()
    {
        return $this->belongsTo(SubscriptionPlan::class, 'subscription_plan_id');
    }

    // ========================== proxy
    public static function hasSubscribed($user): bool|int
    {
        $subscriptions = $user->subscriptions;
        $is_able = false;
        $date_at = now()->format('Y-m-d H:i');

        foreach($subscriptions as $subscription){
            $expiredAt = Carbon::parse($subscription->expired_at)->format('Y-m-d H:i');
            if($expiredAt >= $date_at){
                $is_able = $subscription->id;
            }
        }
        return $is_able;
    }
}
