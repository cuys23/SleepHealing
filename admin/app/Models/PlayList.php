<?php

namespace App\Models;

use App\Services\DurationFormatter;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;

class PlayList extends Model
{
    use HasFactory, SoftDeletes;

    protected $guarded = ['id'];
    protected $casts = [
        'is_paid' => 'boolean',
    ];

    //==========================================> Relations
    public function media()
    {
        return $this->belongsTo(Media::class, 'media_id');
    }

    public function readmore()
    {
        return $this->hasOne(Readmore::class, 'play_list_id');
    }

    public function audio()
    {
        return $this->belongsTo(Media::class, 'audio_id');
    }

    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }

    public function favorites()
    {
        return $this->belongsToMany(User::class, 'favorites');
    }

    public function albams()
    {
        return $this->belongsToMany(Albam::class, (new PlaylistAlbam())->getTable())->withTimestamps();
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

    public function audioFile(): Attribute
    {
        $media = $this->audio;
        $audio = asset('audio/dummy-audio.mp3');

        if($media && Storage::exists($media->src)){
            $audio = Storage::url($media->src);
        }

        return new Attribute(
            get: fn() => $audio
        );
    }

    public function formattedDuration(): Attribute
    {
        return new Attribute(
            get: fn() => DurationFormatter::format($this->duration)
        );
    }

    //=========================================> Scope
    public function scopeActive(Builder $builder, $status = true)
    {
        return $builder->where('status', $status);
    }
}
