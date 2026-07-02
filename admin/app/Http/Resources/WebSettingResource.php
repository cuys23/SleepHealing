<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class WebSettingResource extends JsonResource
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
            'theme_name' => $this->theme_name ?? 'base',
            'version' => '2.4.1',
            'app_name' => $this->webData->title ?? null,
            'address' => $this->address ?? null,
            'phone' => $this->mobile ?? null,
            'email' => $this->email ?? null,
            'subscription' => ($this->subscription ? false : true) ?? null,
            'currency' => "$",
            'favicon' => Storage::url($this->favIcon->src ?? null),
            'logo' => Storage::url($this->logo->src ?? null),
        ];
    }
}
