<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\BannerResource;
use App\Repositories\BannerRepository;
use Illuminate\Http\Request;

class BannerController extends Controller
{
    public function index()
    {
        $banners = (new BannerRepository())->getAllByActive();
        return $this->json('banner list', [
            'banner' => BannerResource::collection($banners)
        ]);
    }
}
