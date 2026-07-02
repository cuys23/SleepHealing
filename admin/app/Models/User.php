<?php

namespace App\Models;

use Laravel\Passport\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;
use Illuminate\Support\Facades\Storage;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles, SoftDeletes;

    protected $guarded = ['id'];

    //==========================================> Relations
    public function media()
    {
        return $this->belongsTo(Media::class, 'media_id');
    }

    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }

    public function favorites()
    {
        return $this->belongsToMany(PlayList::class, 'favorites');
    }

    public function devices()
    {
        return $this->hasMany(DeviceKey::class);
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
