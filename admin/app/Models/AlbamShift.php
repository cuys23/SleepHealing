<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AlbamShift extends Model
{
    use HasFactory;

    protected $guarded = ['id'];

    public function category()
    {
        return $this->belongsTo(Shift::class, 'shift_id');
    }

    public function albam()
    {
        return $this->belongsTo(Albam::class, 'albam_id');
    }
}
