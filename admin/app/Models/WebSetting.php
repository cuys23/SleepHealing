<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class WebSetting extends Model
{
    use HasFactory;
    protected $guarded = ['id'];

    public function signature()
    {
        return $this->belongsTo(Media::class, 'signature_id');
    }

    public function logo()
    {
        return $this->belongsTo(Media::class, 'logo_id');
    }

    public function favIcon()
    {
        return $this->belongsTo(Media::class, 'favicon_id');
    }

    public function getSignaturePathAttribute(): string
    {
        if ($this->signature && Storage::exists($this->signature->src)) {
           return Storage::url($this->signature->src);
        }
        return asset('web/signature.png');
    }

    public function getlogoPathAttribute(): string
    {
        if ($this->logo && Storage::exists($this->logo->src)) {
           return Storage::url($this->logo->src);
        }
        return asset('web/images/logo.png');
    }

    public function getfavIconPathAttribute(): string
    {
        if ($this->favIcon && Storage::exists($this->favIcon->src)) {
           return Storage::url($this->favIcon->src);
        }
        return asset('web/images/fav_icon.png');
    }
}
