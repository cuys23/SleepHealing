<?php

namespace App\Rules;

use App\Services\AudioDurationService;
use Illuminate\Contracts\Validation\Rule;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Log;

/**
 * Confirms ffprobe can detect a positive, finite duration from an uploaded
 * audio file. This runs during form validation - before the controller or
 * repository touches the filesystem or the database - so an unreadable,
 * corrupt, unsupported, or zero/negative-duration upload never reaches the
 * point where it could leave a partial PlayList/Media row or a stored file
 * behind. A song create/update either fully succeeds with a real duration,
 * or fails validation with nothing written anywhere.
 */
class ValidAudioDuration implements Rule
{
    private ?int $detectedDuration = null;

    public function passes($attribute, $value)
    {
        if (! $value instanceof UploadedFile) {
            return true;
        }

        $this->detectedDuration = (new AudioDurationService())->detectSeconds($value->getRealPath());

        if ($this->detectedDuration === null) {
            Log::warning('Audio duration detection failed for an uploaded playlist audio file.', [
                'original_name' => $value->getClientOriginalName(),
                'mime' => $value->getClientMimeType(),
                'size' => $value->getSize(),
            ]);

            return false;
        }

        return true;
    }

    public function message()
    {
        return 'The audio file could not be processed. It may be corrupt, empty, or an unsupported audio format - please try a different file.';
    }

    /**
     * The duration ffprobe detected while this rule ran. Only meaningful
     * after passes() has run and returned true - callers must not reach the
     * repository layer otherwise.
     */
    public function detectedDuration(): ?int
    {
        return $this->detectedDuration;
    }
}
