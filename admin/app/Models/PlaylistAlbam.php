<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlaylistAlbam extends Model
{
    use HasFactory;

    protected $guarded = ['id'];

    public function playlist()
    {
        return $this->belongsTo(PlayList::class, 'play_list_id');
    }

    public function albam()
    {
        return $this->belongsTo(Albam::class, 'albam_id');
    }
}
