<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\AlbamRequest;
use App\Models\Albam;
use App\Repositories\AlbamRepository;
use App\Repositories\CategoryRepository;
use App\Repositories\PlayListRepository;
use App\Repositories\ShiftRepository;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AlbamController extends Controller
{
    public function index()
    {
        $albams = (new AlbamRepository())->getAllByPaginate();
        return view('album.index', compact('albams'));
    }

    public function toggle(Albam $albam)
    {
        $albam->update([
            'status' => !$albam->status
        ]);
        return back()->with('success', 'Status Update Successfully');
    }

    public function create()
    {
        $categories = (new CategoryRepository())->getByActive();
        $shifts = (new ShiftRepository())->getAll();
        return view('album.create', compact('categories', 'shifts'));
    }

    public function store(AlbamRequest $request)
    {
        $albam = (new AlbamRepository())->storeByRequest($request);
        return redirect()->route('albam.index')->with('success', 'Create Successfully');
    }
    public function edit(Albam $albam)
    {
        $categories = (new CategoryRepository())->getAll();
        return view('album.edit', compact('categories', 'albam'));
    }

    public function update(AlbamRequest $request, Albam $albam)
    {
        (new AlbamRepository())->updateByRequest($request, $albam);
        return redirect()->route('albam.index')->with('success', 'Update Successfully');
    }

    public function delete(Albam $albam)
    {
        $media = $albam->media;
        if ($media && Storage::exists($media->src)) {
            Storage::delete($media->src);
        }
        $albam->delete();
        return back()->with('success', 'Deleted Successfully');
    }

    public function getPlaylist(Albam $albam)
    {
        $playlists = (new PlayListRepository())->getAll();

        $selectPlaylists = [];
        foreach ($albam->playlists as $playlist) {
            $selectPlaylists[] = $playlist->pivot->play_list_id;
        }

        return view('album.create-playlist', compact('playlists', 'albam', 'selectPlaylists'));
    }

    public function updatePlaylist(Albam $albam, Request $request)
    {
        $albam->playlists()->sync($request->playlists);

        return redirect()->route('albam.index')->with('success', 'Playlist added successfully');
    }

    function updatePaidStatus(Albam $albam)
    {
        $albam->update([
            'is_paid' => !$albam->is_paid
        ]);
        return redirect()->route('albam.index')->with('success', 'Albam Paid Updated Successfully');
    }
}
