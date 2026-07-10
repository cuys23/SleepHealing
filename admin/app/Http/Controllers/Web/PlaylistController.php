<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\PlayListRequest;
use App\Http\Requests\ReadmoreRequest;
use App\Models\PlayList;
use App\Models\Readmore;
use App\Repositories\AlbamRepository;
use App\Repositories\CategoryRepository;
use App\Repositories\PlayListRepository;
use Illuminate\Support\Facades\Storage;

class PlaylistController extends Controller
{
    public function index()
    {
        $playlists = (new PlayListRepository())->getAllByPaginate();
        return view('playlist.index', compact('playlists'));
    }

    public function toggle(PlayList $playlist)
    {
        $playlist->update([
            'status' => !$playlist->status
        ]);
        return back()->with('success', 'Status Update Successfully');
    }

    function updatePaidStatus(PlayList $playlist)
    {
        $playlist->update([
            'is_paid' => !$playlist->is_paid
        ]);
        return redirect()->route('playlist.index')->with('success', 'Paid Status Updated Successfully');
    }

    public function show(PlayList $playlist)
    {
        return view('playlist.show', compact('playlist'));
    }

    public function create()
    {
        $categories = (new CategoryRepository())->getByActive();
        $albams = (new AlbamRepository())->getAll();
        return view('playlist.create', compact('categories', 'albams'));
    }
    public function store(PlayListRequest $request)
    {
        $playlist = (new PlayListRepository())->storeByRequest($request);

        $response = redirect()->route('playlist.index')->with('success', 'Create successfully');

        if ($warning = $this->buildPlaylistWarning($playlist)) {
            $response->with('warning', $warning);
        }

        return $response;
    }

    public function edit(PlayList $playlist)
    {
        $categories = (new CategoryRepository())->getAll();
        $albams = (new AlbamRepository())->findById($playlist->category_id);
        return view('playlist.edit', compact('categories', 'playlist', 'albams'));
    }

    public function update(PlayListRequest $request, PlayList $playlist)
    {
        $playlist = (new PlayListRepository())->updateByRequest($request, $playlist);

        $response = redirect()->route('playlist.index')->with('success', 'Update Successfully');

        if ($warning = $this->buildPlaylistWarning($playlist)) {
            $response->with('warning', $warning);
        }

        return $response;
    }

    /**
     * A duration-detection failure is now a hard validation error (see
     * PlayListRequest / ValidAudioDuration), so the only remaining
     * "succeeded but not fully visible" state is a song with no album
     * attached.
     */
    private function buildPlaylistWarning(PlayList $playlist): ?string
    {
        if ($playlist->albams()->doesntExist()) {
            return 'This song has no album attached, so it will not appear in the app yet. Open an Album and use its Albums screen to attach this song.';
        }

        return null;
    }

    public function delete(PlayList $playlist)
    {
        $media = $playlist->media;
        $audio = $playlist->audio;
        if ($media && Storage::exists($media->src)) {
            Storage::delete($media->src);
        }
        if ($audio && Storage::exists($audio->src)) {
            Storage::delete($audio->src);
        }
        $playlist->delete();
        return back()->with('success', 'Deleted Successfully');
    }

    public function readmore(PlayList $playlist){
        return view('playlist.readmore', compact('playlist'));
    }

    public function readmoreUpdate(PlayList $playlist, ReadmoreRequest $request){
        Readmore::updateOrCreate([
            'id' => $playlist->readmore->id ?? 0
        ],[
            'play_list_id' => $playlist->id,
            'title' => $request->title,
            'sub_title' => $request->sub_title,
            'content' => $request->content
        ]);
        return to_route('playlist.index')->with('success', 'Read more added successfully');
    }
}
