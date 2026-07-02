<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\AlbamResource;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\CategoryWithAlbumResource;
use App\Repositories\CategoryRepository;

class CategoryController extends Controller
{
    public function __construct(private CategoryRepository $categoryRepo)
    {}

    public function index()
    {
        $categories = $this->categoryRepo->getByActive();

        return $this->json('category list', [
            'category' => CategoryResource::collection($categories)
        ]);
    }

    public function show($id)
    {
       if($id == "all") {
           $categories = $this->categoryRepo->getByActive();
           return $this->json('Latest categories with albams', [
               'category' => CategoryWithAlbumResource::collection($categories)
           ]);
       }
        if(!$this->categoryRepo->findById($id)) {
            return $this->json('category not found', 404);
        }
        $category = $this->categoryRepo->findById($id);
        return $this->json('category details with albams', [
            'category' => new CategoryResource($category),
            'albams' => AlbamResource::collection($category->albams)
        ]);
    }
}
