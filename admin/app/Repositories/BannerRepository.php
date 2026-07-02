<?php

namespace App\Repositories;

use App\Http\Requests\BannerRequest;
use App\Models\Banner;

class BannerRepository extends Repository {

    /**
     * base method
     *
     * @method model()
     */
    public $path = 'images/banner/';
    public function model()
    {
        return Banner::class;
    }
    public function getAll()
    {
        return $this->model()::all();
    }
    public function getAllByActive()
    {
        return $this->model()::active()->get();
    }
    public function getAllByPaginate()
    {
        return $this->model()::paginate(10);
    }

    public function findById($id)
    {
       return $this->model()::find($id);
    }

    public function storeByRequest(BannerRequest $request): Banner
    {
        $thumbnail = null;
        if ($request->hasFile('thumbnail')) {
            $thumbnail = (new MediaRepository())->storeByRequest(
                $request->thumbnail,
                $this->path,
                'image'
            );
        }
        return $this->model()::create([
            'title' => $request->title,
            'description' => $request->description,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'status' => $request->status ? true : false
        ]);
    }

    public function updateByRequest(BannerRequest $request, Banner $banner): Banner
    {
        $thumbnail = $this->thumbnailUpdate($request, $banner);
        $banner->update([
            'title' => $request->title,
            'description' => $request->description,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'status' => $request->status ? true : false
        ]);
        return $banner;
    }

    private function thumbnailUpdate($request, $banner)
    {
        $thumbnail = $banner->media;
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
