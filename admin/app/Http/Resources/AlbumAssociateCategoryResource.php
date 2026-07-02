<?php

namespace App\Http\Resources;

use App\Models\Subscription;
use App\Models\WebSetting;
use Auth;
use Illuminate\Http\Resources\Json\JsonResource;

class AlbumAssociateCategoryResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        $user = Auth::guard('api')->user();
        $has_subscribed = false;
        if ($user) {
            $subscription = Subscription::hasSubscribed($user);
            $websetting = WebSetting::first();
            $has_subscribed = $websetting?->subscription ? true : ($subscription ? true : false);
        }
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'badge' => $this->badge ?: null,
            'thumbnail' => $this->thumbnail,
            'is_paid' => $has_subscribed ? false : $this->is_paid,
            'is_new' => $this->created_at->greaterThan(now()->subDays(15)) ? true : false,
        ];
    }
}
