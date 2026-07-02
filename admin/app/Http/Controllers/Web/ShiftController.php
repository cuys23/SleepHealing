<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Shift;
use App\Repositories\AlbamRepository;
use App\Repositories\ShiftRepository;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ShiftController extends Controller
{
    public function index()
    {
        $shifts = (new ShiftRepository())->getAll();
        return view('shift.index', compact('shifts'));
    }

    public function toggle(Shift $shift)
    {
        $shift->update([
            'status' => !$shift->status
        ]);
        return back()->with('success','Status Update Successfully');
    }

    public function delete(Shift $shift)
    {
        $media = $shift->media;
        if ($media && Storage::exists($media->src)) {
            Storage::delete($media->src);
        }
        $shift->delete();
        return back()->with('success', 'Deleted Successfully');
    }

    public function getAlbams(Shift $shift)
    {
        $albams = (new AlbamRepository())->getAll();

        $selectAlbams = [];
        foreach ($shift->albams as $albam){
            $selectAlbams[] = $albam->pivot->albam_id;
        }

        return view('shift.albam-create', compact('albams', 'shift', 'selectAlbams'));
    }

    public function updateAlbum(Shift $shift, Request $request)
    {
        $shift->albams()->sync($request->albams);
        return redirect()->route('shift.index')->with('success', 'Albams added successfully');
    }
}
