<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\CategoryRequest;
use App\Models\Category;
use App\Repositories\AlbamRepository;
use App\Repositories\CategoryRepository;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class CategoryController extends Controller
{
    public function index()
    {
        $categories = (new CategoryRepository())->getAll();
        return view('category.index', compact('categories'));
    }

    public function toggle(Category $category)
    {
        $category->update([
            'status' => !$category->status
        ]);
        return back()->with('success','Status Update Successfully');
    }

    public function create()
    {
        return view('category.create');
    }

    public function store(CategoryRequest $request)
    {
        $category = (new CategoryRepository())->storeByRequest($request);
        return redirect()->route('category.index')->with('success','Create Successfully');

    }
    public function edit(Category $category)
    {
        return view('category.edit', compact('category'));
    }

    public function update(CategoryRequest $request, Category $category)
    {
        (new CategoryRepository())->updateByRequest($request, $category);
        return redirect()->route('category.index')->with('success','Update Successfully');
    }

    public function delete(Category $category)
    {
        $media = $category->media;
        if ($media && Storage::exists($media->src)) {
            Storage::delete($media->src);
        }
        $category->delete();
        return back()->with('success', 'Deleted Successfully');
    }

    public function getAlbams(Category $category)
    {
        $albams = (new AlbamRepository())->getAll();

        $selectAlbams = [];
        foreach ($category->albams as $albam){
            $selectAlbams[] = $albam->pivot->albam_id;
        }

        return view('category.albam-create', compact('albams', 'category', 'selectAlbams'));
    }
    public function updateAlbum(Category $category, Request $request)
    {
        $category->albams()->sync($request->albams);
        return redirect()->route('category.index')->with('success', 'Albams added successfully');
    }

}
