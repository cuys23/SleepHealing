<?php

namespace App\Http\Resources;

use Carbon\Carbon;
use App\Models\Subscription;
use Illuminate\Http\Resources\Json\JsonResource;

class SubscriptionResouorce extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {

        $user = auth()->user();
        $hasSubs = Subscription::hasSubscribed($user);

        $hasSubs = $user->subscriptions->where('is_paid', 1)->first();  // Get the first paid subscription

        $active = $hasSubs && $hasSubs->id == $this->id;

        return [
            'id' => $this->id,
            'active' => $active,
            'expired_at' => Carbon::parse($this->expired_at)->format('M d, Y H:i'),
            'amount' => $this->amount,
            'subscriptionPlan' => SubscriptionPlanResource::make($this->subscriptionPlan),
        ];
    }
}
