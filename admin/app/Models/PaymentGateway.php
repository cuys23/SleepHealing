<?php

namespace App\Models;


use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

use Illuminate\Database\Eloquent\Casts\Attribute;

class PaymentGateway extends Model
{
    use HasFactory;
    protected $casts = [
        'config' => 'array',
    ];

    protected $guarded = ['id'];



       public function media(): BelongsTo
    {
        return $this->belongsTo(Media::class);
    }


    public function logo(): Attribute
    {
        $logo = asset('gateway/' . strtolower($this->name) . '.png');
        if ($this->media && Storage::exists($this->media->src)) {
            $logo = Storage::url($this->media->src);
        }
        return new Attribute(
            get: fn () => $logo
        );
    }
}
