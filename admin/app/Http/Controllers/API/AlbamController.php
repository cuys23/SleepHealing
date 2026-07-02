<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\AlbamResource;
use App\Models\Category;
use App\Repositories\AlbamRepository;
use App\Repositories\CategoryRepository;
use Illuminate\Http\Request;

class AlbamController extends Controller
{
    public function __construct(public AlbamRepository $albamRepo)
    {}

    public function index(Request $request)
    {
        $request->validate([
            'category' => 'required|exists:'.(new Category())->getTable().',id'
        ]);

        $category = (new CategoryRepository())->findById($request->category);

        $albams = $category->albams()->active()->get();

        return $this->json('albam list', [
            'albams' => AlbamResource::collection($albams)
        ]);
    }
}
