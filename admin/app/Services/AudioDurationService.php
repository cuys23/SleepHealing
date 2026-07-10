<?php

namespace App\Services;

use Symfony\Component\Process\Exception\ExceptionInterface;
use Symfony\Component\Process\Process;

class AudioDurationService
{
    /**
     * Detect the duration of an audio file in whole seconds using ffprobe
     * (bundled in the app image alongside ffmpeg). Returns null rather than
     * throwing on any detection failure - including zero, negative, or
     * non-finite readings, which indicate unreadable/corrupt audio just as
     * much as an ffprobe error does. Callers decide how to surface a null.
     */
    public function detectSeconds(string $absolutePath): ?int
    {
        $process = new Process([
            'ffprobe',
            '-v', 'error',
            '-show_entries', 'format=duration',
            '-of', 'csv=p=0',
            $absolutePath,
        ]);
        $process->setTimeout(10);

        try {
            $process->run();
        } catch (ExceptionInterface $e) {
            return null;
        }

        if (! $process->isSuccessful()) {
            return null;
        }

        $output = trim($process->getOutput());
        if ($output === '' || ! is_numeric($output)) {
            return null;
        }

        $seconds = (float) $output;
        if (! is_finite($seconds) || $seconds <= 0) {
            return null;
        }

        return (int) round($seconds);
    }
}
