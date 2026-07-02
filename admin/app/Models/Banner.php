<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Banner extends Model
{
    use HasFactory;
    protected $guarded = ['id'];

    //==========================================> Relations
    public function media()
    {
        return $this->belongsTo(Media::class, 'media_id');
    }

    //=========================================> Attributes
    public function thumbnail(): Attribute
    {
        $media = $this->media;
        $image = asset('images/dummy-image.jpg');

        if ($media && Storage::exists($media->src)) {
            $image = Storage::url($media->src);
        }

        return new Attribute(
            get: fn () => $image
        );
    }

    //=========================================> Scope
    public function scopeActive(Builder $builder, $status = true)
    {
        return $builder->where('status', $status);
    }
}
