<?php

namespace App\Repositories;

use App\Models\Media;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class MediaRepository extends Repository {

    /**
     * base method
     *
     * @method model()
     */
    public function model()
    {
        return Media::class;
    }

    public function storeByRequest(UploadedFile $file, $path, $type = null): Media
    {
        $src = Storage::put('/'. trim($path, '/'), $file, 'public');

        return $this->create([
            'extension' => $file->extension(),
            'src' => $src,
            'path' => $path,
            'type' => $type,
        ]);
    }

    public function updateByRequest(UploadedFile $file, Media $media, $path, $type = null): Media
    {
        $src = Storage::put('/'. trim($path, '/'), $file, 'public');

        if(Storage::exists($media->src)){
            Storage::delete($media->src);
        }

         $this->update($media, [
            'extension' => $file->extension(),
            'src' => $src,
            'path' => $path,
            'type' => $type,
        ]);

        return $media;
    }

    public function updateOrCreateByRequest(UploadedFile $file, $media = null, $path, $type = null): Media
    {
        $src = Storage::put('/' . trim($path, '/'), $file, 'public');

        if ($media && Storage::exists($media->src)) {
            Storage::delete($media->src);
        }

        $media = $this->model()::updateOrCreate([
            'id' => $media?->id ?? 0
        ], [
            'extension' => $file->extension(),
            'src' => $src,
            'path' => $path,
            'type' => $type,
        ]);

        return $media;
    }


}
