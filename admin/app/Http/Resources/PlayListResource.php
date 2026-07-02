<?php

namespace App\Http\Resources;

use App\Models\Subscription;
use App\Models\WebSetting;
use App\Repositories\AlbamRepository;
use App\Repositories\UserRepository;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Auth;

class PlayListResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        $favorites = [];
        $has_subscribed = false;
        $user = Auth::guard('api')->user();
        if ($user) {
            $favorites = $user->favorites()->pluck('id')->toArray();
            $subscription = Subscription::hasSubscribed($user);
            $websetting = WebSetting::first();
            $has_subscribed = $websetting?->subscription ? true : ($subscription ? true : false);
        }

        $albam = (new AlbamRepository())->findById($request->albam);
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'duration' => $this->duration,
            'thumbnail' => $this->thumbnail,
            'audio' => $this->audioFile,
            'views' => $this->views,
            'is_favorite' => in_array( $this->id, $favorites),
            'is_paid' => $has_subscribed ? false : $this->is_paid,
            'albam' => AlbamResource::make($albam),
            'has_readmore' => $this->readmore ? true : false
        ];
    }
}
