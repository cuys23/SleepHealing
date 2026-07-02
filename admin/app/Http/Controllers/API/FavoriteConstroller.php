<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\FavoriteRequest;
use App\Http\Resources\PlayListResource;
use App\Repositories\PlayListRepository;
use Illuminate\Http\Response;

class FavoriteConstroller extends Controller
{
    public function index()
    {
        $user = auth()->user();
        return $this->json('Favorite lists.', [
            'playList' => PlayListResource::collection($user->favorites)
        ]);
    }

    public function store(FavoriteRequest $request)
    {
        $playList = (new PlayListRepository())->find($request->play_list_id);
        $user = auth()->user();
        $favorites = $user->favorites->pluck('id')->toArray();

        if(in_array($playList->id, $favorites)){
            $user->favorites()->detach($playList->id);

            return $this->json('Audio is removed successfully from favorites');
        }else{
            $user->favorites()->attach($request->play_list_id);

            return $this->json('Audio is addedd successfully.', [
                'playList' => PlayListResource::make($playList)
            ]);
        }
    }
}
