<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\PlayListResource;
use App\Http\Resources\ReadmoreResource;
use App\Models\PlayList;
use App\Repositories\AlbamRepository;
use App\Repositories\PlayListRepository;
use Illuminate\Support\Facades\Auth;

class PlayListController extends Controller
{
    public function __construct(public PlayListRepository $playListRepo)
    {
    }

    public function index()
    {
        $albamId = \request()->albam;
        $albam = (new AlbamRepository())->findById($albamId);

        $playLists = $albam->playlists()->active()->get();

        return $this->json('play lists', [
            'albams' => PlayListResource::collection($playLists)
        ]);
    }

    public function viewCount($id)
    {

        $playlist = $this->playListRepo->query()->where('id', $id)->active()->firstOrFail();
        $playlist->increment('views');
        return $this->json('podcast views', [
            'views' => $playlist->views
        ]);
    }

    public function readmore(PlayList $playlist)
    {

        return $this->json('play lists content', [
            'readmore' => $playlist->readmore ? ReadmoreResource::make($playlist->readmore) : null
        ]);
    }
}
