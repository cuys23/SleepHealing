<?php

namespace App\Repositories;

use App\Http\Requests\PlayListRequest;
use App\Models\PlayList;

class PlayListRepository extends Repository
{

    public $path = 'images/playlist/';
    public $audioPath = 'audio/playlist/';
    public function model()
    {
        return PlayList::class;
    }

    public function getAll()
    {
        return $this->model()::all();
    }

    public function getAllByPaginate()
    {
        $search = request()->search;
        return $this->query()->when($search, function ($query) use ($search) {
            $query->where('name', 'like', "%$search%");
        })->paginate(10);
    }

    public function storeByRequest(PlayListRequest $request)
    {
        $thumbnail = null;
        if ($request->hasFile('thumbnail')) {
            $thumbnail = (new MediaRepository())->storeByRequest(
                $request->thumbnail,
                $this->path,
                'image'
            );
        }

        $audioFile = null;
        if ($request->hasFile('audio')) {
            $audioFile = (new MediaRepository())->storeByRequest(
                $request->audio,
                $this->audioPath,
                'audio'
            );
        }
        return  $this->create([
            'name' => $request->name,
            'duration' => $request->duration,
            'description' => $request->description,
            'category_id' => $request->category,
            'albam_id' => $request->albam,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'audio_id' => $audioFile ? $audioFile->id : null,
            'status' => $request->active ? true : false,
            'is_paid' => $request->paid ? true : false
        ]);
    }

    public function updateByRequest(PlayListRequest $request, PlayList $playlist): PlayList
    {
        $thumbnail = $this->thumbnailUpdate($request, $playlist);
        $audioFile = $this->audioFileUpdate($request, $playlist);
        $playlist->update([
            'name' => $request->name,
            'duration' => $request->duration,
            'description' => $request->description,
            'category_id' => $request->category,
            'albam_id' => $request->albam,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'audio_id' => $audioFile ? $audioFile->id : null,
            'status' => $request->active ? true : false,
            'is_paid' => $request->paid ? true : false
        ]);
        return $playlist;
    }

    private function audioFileUpdate($request, $playlist)
    {
        $audioFile = $playlist->audio;
        if ($request->hasFile('audio') && $audioFile == null) {
            $audioFile = (new MediaRepository())->storeByRequest(
                $request->audio,
                $this->audioPath,
                'audio'
            );
        }

        if ($request->hasFile('audio') && $audioFile) {
            $audioFile = (new MediaRepository())->updateByRequest(
                $request->audio,
                $audioFile,
                $this->audioPath,
                'audio',
            );
        }

        return $audioFile;
    }

    private function thumbnailUpdate($request, $playlist)
    {
        $thumbnail = $playlist->media;
        if ($request->hasFile('thumbnail') && $thumbnail == null) {
            $thumbnail = (new MediaRepository())->storeByRequest(
                $request->thumbnail,
                $this->path,
                'image'
            );
        }

        if ($request->hasFile('thumbnail') && $thumbnail) {
            $thumbnail = (new MediaRepository())->updateByRequest(
                $request->thumbnail,
                $thumbnail,
                $this->path,
                'image',
            );
        }

        return $thumbnail;
    }
}
