<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\BannerRequest;
use App\Models\Banner;
use App\Repositories\BannerRepository;
use Illuminate\Support\Facades\Storage;

class BannerController extends Controller
{
    public function index()
    {
        $banners = (new BannerRepository())->getAll();
        return view('banner.index', compact('banners'));
    }

    public function toggle(Banner $banner)
    {
        $banner->update([
            'status' => !$banner->status
        ]);
        return back()->with('success','Status Update Successfully');
    }

    public function create()
    {
        return view('banner.create');
    }

    public function store(BannerRequest $request)
    {
        (new BannerRepository())->storeByRequest($request);
        return redirect()->route('banner.index')->with('success','Create Successfully');

    }
    public function edit(Banner $banner)
    {
        return view('banner.edit', compact('banner'));
    }

    public function update(BannerRequest $request, Banner $banner)
    {
        (new BannerRepository())->updateByRequest($request, $banner);
        return redirect()->route('banner.index')->with('success','Update Successfully');
    }

    public function delete(Banner $banner)
    {
        $media = $banner->media;
        if ($media && Storage::exists($media->src)) {
            Storage::delete($media->src);
        }
        $banner->delete();
        return back()->with('success', 'Deleted Successfully');
    }
}
