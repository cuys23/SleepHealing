<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\SubscriptionPlanRequest;
use App\Models\SubscriptionPlan;
use App\Repositories\SubscriptionPlanRepository;
use Illuminate\Support\Facades\Storage;

class SubscriptionPlanController extends Controller
{
    public function index()
    {
        $subscriptionPlans = (new SubscriptionPlanRepository())->getAll();
        return view('subscription_plan.index', compact('subscriptionPlans'));
    }

    public function toggle(SubscriptionPlan $subscriptionPlan)
    {
        $subscriptionPlan->update([
            'status' => !$subscriptionPlan->status
        ]);
        return back()->with('success','Status Update Successfully');
    }

    public function show(SubscriptionPlan $subscriptionPlan)
    {
        return view('subscription_plan.show', compact('subscriptionPlan'));
    }

    public function create()
    {
        return view('subscription_plan.create');
    }

    public function store(SubscriptionPlanRequest $request)
    {
        $subscriptionPlan = (new SubscriptionPlanRepository())->storeByRequest($request);
        return redirect()->route('subscriptionPlan.index')->with('success','Create Successfully');

    }
    public function edit(SubscriptionPlan $subscriptionPlan)
    {
        return view('subscription_plan.edit', compact('subscriptionPlan'));
    }

    public function update(SubscriptionPlanRequest $request, SubscriptionPlan $subscriptionPlan)
    {
        (new SubscriptionPlanRepository())->updateByRequest($request, $subscriptionPlan);
        return redirect()->route('subscriptionPlan.index')->with('success','Update Successfully');
    }

    public function delete(SubscriptionPlan $subscriptionPlan)
    {
        if ($subscriptionPlan->subscriptions()->exists()) {
            return back()->with('errors', 'Sorry already has supcription users');
        }

        $media = $subscriptionPlan->media;
        if ($media && Storage::exists($media->src)) {
            Storage::delete($media->src);
        }
        $subscriptionPlan->delete();
        return back()->with('success', 'Deleted Successfully');
    }

}
