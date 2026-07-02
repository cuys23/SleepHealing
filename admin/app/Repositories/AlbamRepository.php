<?php

namespace App\Repositories;

use App\Http\Requests\AlbamRequest;
use App\Models\Albam;

class AlbamRepository extends Repository {

    /**
     * base method
     *
     * @method model()
     */
    public $path = 'images/albam/';
    public function model()
    {
        return Albam::class;
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

    public function findById($id)
    {
       return $this->model()::find($id);
    }

    public function storeByRequest(AlbamRequest $request): Albam
    {
        $thumbnail = null;
        if ($request->hasFile('thumbnail')) {
            $thumbnail = (new MediaRepository())->storeByRequest(
                $request->thumbnail,
                $this->path,
                'image'
            );
        }
        return $this->create([
            'name' => $request->name,
            'category_id' => $request->category,
            'description' => $request->description,
            'badge' => $request->badge,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'status' => $request->active ? true : false,
            'is_featured' => $request->featured ? true : false,
            'is_paid' => $request->paid ? true : false
        ]);
    }

    public function updateByRequest(AlbamRequest $request, Albam $albam): Albam
    {
        $thumbnail = $this->thumbnailUpdate($request, $albam);
        $albam->update([
            'name' => $request->name,
            'category_id' => $request->category,
            'description' => $request->description,
            'badge' => $request->badge,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'status' => $request->active ? true : false,
            'is_featured' => $request->featured ? true : false,
            'is_paid' => $request->paid ? true : false
        ]);
        return $albam;
    }

    private function thumbnailUpdate($request, $albam)
    {
        $thumbnail = $albam->media;
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
