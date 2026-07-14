<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\FavoriteRequest;
use App\Http\Resources\PlayListResource;
use App\Repositories\PlayListRepository;
use Illuminate\Database\QueryException;
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

        if ($user->favorites()->where('play_list_id', $playList->id)->exists()) {
            $user->favorites()->detach($playList->id);

            return $this->json('Audio is removed successfully from favorites');
        }

        try {
            $user->favorites()->attach($playList->id);
        } catch (QueryException $e) {
            // SQLSTATE 23000: a concurrent request already favorited this
            // track first (favorites_user_playlist_unique). The desired end
            // state - favorited - is already true, so this is a success,
            // not a 500.
            if ($e->getCode() !== '23000') {
                throw $e;
            }
        }

        return $this->json('Audio is addedd successfully.', [
            'playList' => PlayListResource::make($playList)
        ]);
    }
}
