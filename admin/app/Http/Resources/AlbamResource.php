<?php

namespace App\Http\Resources;

use App\Models\Subscription;
use App\Models\WebSetting;
use App\Repositories\CategoryRepository;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Auth;

class AlbamResource extends JsonResource
{

    public function toArray($request)
    {
        $user = Auth::guard('api')->user();
        $has_subscribed = false;
        if ($user) {
             $subscriptions = $user->subscriptions()->where('is_paid', '=', 1)->get();
             if($subscriptions->count()>0){
                $subscription = Subscription::hasSubscribed($user);
                $websetting = WebSetting::first();
                $has_subscribed = $websetting?->subscription ? true : ($subscription ? true : false);
            }
        }
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'badge' => $this->badge ?: null,
            'thumbnail' => $this->thumbnail,
            'is_paid' => $has_subscribed ? false : $this->is_paid,
            'is_new' => $this->created_at->greaterThan(now()->subDays(15)) ? true : false,
            'category' => CategoryResource::make($this->categories()->first())
        ];
    }
}
