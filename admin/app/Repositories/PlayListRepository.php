<?php

namespace App\Repositories;

use App\Http\Requests\PlayListRequest;
use App\Models\Media;
use App\Models\PlayList;
use App\Models\PlaylistAlbam;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class PlayListRepository extends Repository
{

    public $path = 'images/playlist/';
    public $audioPath = 'audio/playlist/';
    public function model()
    {
        return PlayList::class;
    }

    public function getAll()
    {
        return $this->model()::all();
    }

    public function getAllByPaginate()
    {
        $search = request()->search;
        return $this->query()->when($search, function ($query) use ($search) {
            $query->where('name', 'like', "%$search%");
        })->latest('id')->paginate(10);
    }

    public function storeByRequest(PlayListRequest $request)
    {
        // PlayListRequest's ValidAudioDuration rule already ran ffprobe
        // against the upload during validation and rejected the request
        // before we got here if no positive duration could be detected -
        // so nothing below can be reached with an unusable audio file.
        $thumbnail = null;
        if ($request->hasFile('thumbnail')) {
            $thumbnail = (new MediaRepository())->storeByRequest(
                $request->thumbnail,
                $this->path,
                'image'
            );
        }

        $audioFile = null;
        $duration = null;
        if ($request->hasFile('audio')) {
            $duration = $request->detectedAudioDuration();
            if ($duration === null) {
                throw new \RuntimeException('Audio duration must be validated before repository processing.');
            }
            $audioFile = (new MediaRepository())->storeByRequest(
                $request->audio,
                $this->audioPath,
                'audio'
            );
        }

        try {
            return DB::transaction(function () use ($request, $thumbnail, $audioFile, $duration) {
                $playlist = $this->create([
                    'name' => $request->name,
                    'duration' => $duration,
                    'description' => $request->description,
                    'category_id' => $request->category,
                    'albam_id' => $request->albam,
                    'media_id' => $thumbnail ? $thumbnail->id : null,
                    'audio_id' => $audioFile ? $audioFile->id : null,
                    'status' => $request->active ? true : false,
                    'is_paid' => $request->paid ? true : false
                ]);

                // The public API lists songs via the playlist_albams many-to-many
                // relation (Albam::playlists()), not the albam_id column above.
                // Create-only: the Album "Playlist" tree screen remains the way to
                // attach a song to additional albums afterwards.
                if ($request->albam) {
                    PlaylistAlbam::firstOrCreate([
                        'play_list_id' => $playlist->id,
                        'albam_id' => $request->albam,
                    ]);
                }

                return $playlist;
            });
        } catch (\Throwable $e) {
            // The DB transaction rolled back the PlayList/pivot rows, but a
            // transaction can't roll back filesystem writes - remove any
            // file we just stored so a DB failure can't leave an orphaned
            // upload behind.
            $this->deleteStoredMedia($thumbnail);
            $this->deleteStoredMedia($audioFile);
            throw $e;
        }
    }

    private function deleteStoredMedia(?Media $media): void
    {
        if ($media && Storage::exists($media->src)) {
            Storage::delete($media->src);
        }
    }

    public function updateByRequest(PlayListRequest $request, PlayList $playlist): PlayList
    {
        // As in storeByRequest, ValidAudioDuration already ran ffprobe
        // during validation and rejected the request if a new audio upload
        // had no detectable positive duration. So it's safe to resolve the
        // new duration here, before audioFileUpdate() replaces the old
        // file/Media row - the old file is only ever touched once we know
        // the replacement is good.
        $newDuration = null;
        if ($request->hasFile('audio')) {
            $newDuration = $request->detectedAudioDuration();
            if ($newDuration === null) {
                throw new \RuntimeException('Audio duration must be validated before repository processing.');
            }
        }

        $thumbnail = $this->thumbnailUpdate($request, $playlist);
        $audioFile = $this->audioFileUpdate($request, $playlist);

        $attributes = [
            'name' => $request->name,
            'description' => $request->description,
            'category_id' => $request->category,
            'albam_id' => $request->albam,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'audio_id' => $audioFile ? $audioFile->id : null,
            'status' => $request->active ? true : false,
            'is_paid' => $request->paid ? true : false
        ];

        // Only overwrite duration when the audio file actually changed - a
        // save with no new upload must not wipe out a previously detected
        // value.
        if ($request->hasFile('audio')) {
            $attributes['duration'] = $newDuration;
        }

        $playlist->update($attributes);
        return $playlist;
    }

    private function audioFileUpdate($request, $playlist)
    {
        $audioFile = $playlist->audio;
        if ($request->hasFile('audio') && $audioFile == null) {
            $audioFile = (new MediaRepository())->storeByRequest(
                $request->audio,
                $this->audioPath,
                'audio'
            );
        } elseif ($request->hasFile('audio') && $audioFile) {
            $audioFile = (new MediaRepository())->updateByRequest(
                $request->audio,
                $audioFile,
                $this->audioPath,
                'audio',
            );
        }

        return $audioFile;
    }

    private function thumbnailUpdate($request, $playlist)
    {
        $thumbnail = $playlist->media;
        if ($request->hasFile('thumbnail') && $thumbnail == null) {
            $thumbnail = (new MediaRepository())->storeByRequest(
                $request->thumbnail,
                $this->path,
                'image'
            );
        } elseif ($request->hasFile('thumbnail') && $thumbnail) {
            $thumbnail = (new MediaRepository())->updateByRequest(
                $request->thumbnail,
                $thumbnail,
                $this->path,
                'image',
            );
        }

        return $thumbnail;
    }
}
