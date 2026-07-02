<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlaylistAlbam extends Model
{
    use HasFactory;

    public function playlist()
    {
        return $this->belongsTo(PlayList::class, 'playlist_id');
    }

    public function albam()
    {
        return $this->belongsTo(Albam::class, 'albam_id');
    }
}
