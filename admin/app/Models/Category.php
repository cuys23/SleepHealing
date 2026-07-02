<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;

class Category extends Model
{
    use HasFactory, SoftDeletes;

    protected $guarded = ['id'];

    //==========================================> Relations
    public function media()
    {
        return $this->belongsTo(Media::class, 'media_id');
    }

    public function icon()
    {
        return $this->belongsTo(Media::class, 'icon_id');
    }

    public function albams()
    {
        return $this->belongsToMany(Albam::class, (new AlbamCategory())->getTable())->withTimestamps();
    }

    public function playlists()
    {
        return $this->hasMany(PlayList::class);
    }

    //=========================================> Attributes
    public function thumbnail(): Attribute
    {
        $media = $this->media;
        $image = asset('images/dummy-image.jpg');

        if($media && Storage::exists($media->src)){
            $image = Storage::url($media->src);
        }

        return new Attribute(
            get: fn() => $image
        );
    }

    public function iconPath(): Attribute
    {
        $media = $this->icon;
        $image = asset('images/dummy-image.jpg');

        if($media && Storage::exists($media->src)){
            $image = Storage::url($media->src);
        }

        return new Attribute(
            get: fn() => $image
        );
    }

    //=========================================> Scope
    public function scopeActive(Builder $builder, $status = true)
    {
        return $builder->where('status', $status);
    }
}
