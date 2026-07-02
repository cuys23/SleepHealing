<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SubscriptionPlan extends Model
{
    use HasFactory;

    protected $guarded = ['id'];

    //==========================================> Relations
    public function media()
    {
        return $this->belongsTo(Media::class, 'media_id');
    }

    public function subscriptions()
    {
        return $this->hasOne(Subscription::class);
    }

    //=========================================> Attributes
    public function thumbnail(): Attribute
    {
        $media = $this->media;
        $image = asset('images/dummy-profile.png');

        if($media && Storage::exists($media->src)){
            $image = Storage::url($media->src);
        }

        return new Attribute(
            get: fn() => $image
        );
    }
}
