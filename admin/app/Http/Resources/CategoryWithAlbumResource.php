<?php

namespace App\Http\Resources;

use App\Models\Subscription;
use App\Models\WebSetting;
use Auth;
use Illuminate\Http\Resources\Json\JsonResource;

class CategoryWithAlbumResource extends JsonResource
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
            'description' => $this->description,
            'thumbnail' => $this->thumbnail,
            'icon' => $this->iconPath,
            'albams' => AlbumAssociateCategoryResource::collection($this->albams)
        ];
    }
}
