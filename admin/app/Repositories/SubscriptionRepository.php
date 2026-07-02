<?php

namespace App\Repositories;

use App\Http\Requests\SubscribeRequest;
use App\Models\Subscription;

class SubscriptionRepository extends Repository {

    /**
     * base method
     *
     * @method model()
     */
    public function model()
    {
        return Subscription::class;
    }

    public function storeByRequest(SubscribeRequest $request): Subscription
    {
        $plan = (new SubscriptionPlanRepository())->find($request->plan_id);
        $expiredAt = now()->addMonths($plan->duration);

        return $this->create([
            'user_id' => auth()->id(),
            'subscription_plan_id' => $plan->id,
            'expired_at' => $expiredAt,
            'amount' => $plan->amount
        ]);
    }

    public function updateByPlan($plan)
    {

    }
}
