<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\AlbamResource;
use App\Repositories\DashboardCategoryRepository;
use App\Repositories\ShiftRepository;

class ShiftController extends Controller
{
    public function index()
    {
        $request = request();
        $type = $request->type ?? 'morning';
        $take = $request->perPage ?? $request->take ?? '10';
        $page = $request->page ?? '1';

        $skip = ($page * $take) - $take;

        $category = (new ShiftRepository())->findByType($type);

        $albams = $category?->albams()->where('status', true)->skip($skip)->take($take)->get();

        return $this->json($type.' albams list', [
            'total' => $category?->albams()->where('status', true)->count() ?? 0,
            'albams' => AlbamResource::collection($albams ?? [])
        ]);
    }
}
