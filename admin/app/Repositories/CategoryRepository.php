<?php

namespace App\Repositories;

use App\Http\Requests\CategoryRequest;
use App\Models\Category;

class CategoryRepository extends Repository
{

    /**
     * base method
     *
     * @method model()
     */
    public $path = 'images/category/';
    public function model()
    {
        return Category::class;
    }

    public function getByActive()
    {
        return $this->query()->active()->get();
    }

    public function findById($id)
    {
        return $this->model()::find($id);
    }

    public function getAll()
    {
        $search = request()->search;
        return $this->query()->when($search, function ($query) use ($search) {
            $query->where('name', 'like', "%$search%");
        })->paginate(10);
    }

    public function storeByRequest(CategoryRequest $request): Category
    {
        $thumbnail = null;
        if ($request->hasFile('thumbnail')) {
            $thumbnail = (new MediaRepository())->storeByRequest(
                $request->thumbnail,
                $this->path,
                'image'
            );
        }
        $icon = null;
        if ($request->hasFile('icon')) {
            $icon = (new MediaRepository())->storeByRequest(
                $request->icon,
                $this->path,
                'image'
            );
        }
        return $this->model()::create([
            'name' => $request->name,
            'description' => $request->description,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'icon_id' => $icon ? $icon->id : null,
            'status' => $request->active ? true : false,
        ]);
    }

    public function updateByRequest(CategoryRequest $request, Category $category): Category
    {
        $thumbnail = $this->thumbnailUpdate($request, $category);
        $icon = $this->iconUpdate($request, $category);
        $category->update([
            'name' => $request->name,
            'description' => $request->description,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'icon_id' => $icon ? $icon->id : null,
            'status' => $request->active ? true : false
        ]);
        return $category;
    }

    private function thumbnailUpdate($request, $category)
    {
        $thumbnail = $category->media;
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

    private function iconUpdate($request, $category)
    {
        $icon = $category->icon;
        if ($request->hasFile('icon') && $icon == null) {
            $icon = (new MediaRepository())->storeByRequest(
                $request->icon,
                $this->path,
                'image'
            );
        }

        if ($request->hasFile('icon') && $icon) {
            $icon = (new MediaRepository())->updateByRequest(
                $request->icon,
                $icon,
                $this->path,
                'image',
            );
        }

        return $icon;
    }
}
