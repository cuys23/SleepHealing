<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class SubscriptionPlanResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'thumbnail' => $this->thumbnail,
            'features' => [$this->feature_1, $this->feature_2, $this->feature_3, $this->feature_4],
            'duration' => $this->duration . ' Months',
            'amount' => $this->amount,
            'is_recommended' => $this->is_recommended ? true : false
        ];
    }
}
