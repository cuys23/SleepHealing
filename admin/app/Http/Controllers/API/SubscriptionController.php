<?php

namespace App\Http\Controllers\API;

use App\Models\Subscription;
use App\Http\Controllers\Controller;
use App\Http\Requests\SubscribeRequest;
use App\Repositories\SubscriptionRepository;
use App\Http\Resources\SubscriptionResouorce;
use App\Http\Resources\SubscriptionPlanResource;
use App\Repositories\SubscriptionPlanRepository;

class SubscriptionController extends Controller
{
    public function index()
    {
        $subscriptionPlans = (new SubscriptionPlanRepository())->getAll();

        return $this->json('Subscription plan list', [
            'plans' => SubscriptionPlanResource::collection($subscriptionPlans)
        ]);
    }

    public function myPlans()
    {
        $user = auth()->user();
        $subscriptions = $user->subscriptions()->where('is_paid', '=', 1)->get();

        return $this->json('My subscription plan list', [
            'subscriptions' => SubscriptionResouorce::collection($subscriptions)
        ]);
    }

    public function store(SubscribeRequest $request)
    {
        $user = auth()->user();
        $is_expired = Subscription::hasSubscribed($user);
        if ($is_expired) {
            return $this->json('subscription plan buy successfully');
        }

        $plan = (new SubscriptionRepository())->storeByRequest($request);
        return $this->json('subscription plan buy successfully', [
            'subscription' => SubscriptionResouorce::make($plan)
        ]);
    }
}
