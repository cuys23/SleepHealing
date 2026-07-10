<?php

namespace App\Services;

class DurationFormatter
{
    /**
     * Parse a stored duration value into total whole seconds. Accepts the
     * canonical plain-seconds form ("242") as well as legacy "m:s" / "h:m:s"
     * text ("3:30") already present in rows created before automatic
     * detection existed.
     */
    public static function toSeconds(?string $raw): ?int
    {
        if ($raw === null) {
            return null;
        }

        $trimmed = trim($raw);
        if ($trimmed === '') {
            return null;
        }

        if (ctype_digit($trimmed)) {
            return (int) $trimmed;
        }

        $parts = explode(':', $trimmed);
        if (count($parts) < 2 || count($parts) > 3) {
            return null;
        }

        foreach ($parts as $part) {
            if (! is_numeric(trim($part))) {
                return null;
            }
        }

        $parts = array_map('floatval', $parts);
        $seconds = array_pop($parts);
        $minutes = array_pop($parts);
        $hours = $parts ? array_pop($parts) : 0.0;

        return (int) round($hours * 3600 + $minutes * 60 + $seconds);
    }

    /**
     * Format a stored duration value as zero-padded mm:ss, or hh:mm:ss once
     * an hour is reached. Returns null when the value is absent or
     * unparseable so callers can render an explicit "not detected" state
     * instead of a misleading "00:00".
     */
    public static function format(?string $raw): ?string
    {
        $seconds = self::toSeconds($raw);
        if ($seconds === null) {
            return null;
        }

        $hours = intdiv($seconds, 3600);
        $minutes = intdiv($seconds % 3600, 60);
        $secs = $seconds % 60;

        return $hours > 0
            ? sprintf('%02d:%02d:%02d', $hours, $minutes, $secs)
            : sprintf('%02d:%02d', $minutes, $secs);
    }
}
