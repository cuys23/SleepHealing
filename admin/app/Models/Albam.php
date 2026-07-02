<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Albam extends Model
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

    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }

    public function categories()
    {
        return $this->belongsToMany(Category::class, (new AlbamCategory())->getTable());
    }

    public function playlists()
    {
        return $this->belongsToMany(PlayList::class, (new PlaylistAlbam())->getTable())->withTimestamps();
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
