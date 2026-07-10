<?php

namespace Tests\Unit;

use App\Services\DurationFormatter;
use Tests\TestCase;

class DurationFormatterTest extends TestCase
{
    public function test_to_seconds_parses_the_canonical_plain_seconds_form(): void
    {
        $this->assertSame(242, DurationFormatter::toSeconds('242'));
        $this->assertSame(0, DurationFormatter::toSeconds('0'));
    }

    public function test_to_seconds_parses_legacy_colon_separated_forms(): void
    {
        $this->assertSame(210, DurationFormatter::toSeconds('3:30'));
        $this->assertSame(3662, DurationFormatter::toSeconds('1:01:02'));
    }

    public function test_to_seconds_handles_null_empty_and_garbage_input(): void
    {
        $this->assertNull(DurationFormatter::toSeconds(null));
        $this->assertNull(DurationFormatter::toSeconds(''));
        $this->assertNull(DurationFormatter::toSeconds('   '));
        $this->assertNull(DurationFormatter::toSeconds('not-a-duration'));
        $this->assertNull(DurationFormatter::toSeconds('1:2:3:4'));
    }

    public function test_format_matches_the_required_zero_padded_shape(): void
    {
        $this->assertSame('01:02', DurationFormatter::format('62'));
        $this->assertSame('04:02', DurationFormatter::format('242'));
        $this->assertSame('01:01:02', DurationFormatter::format('3662'));
        $this->assertSame('00:00', DurationFormatter::format('0'));
    }

    public function test_format_normalizes_legacy_input_to_the_same_zero_padded_shape(): void
    {
        // A pre-existing "3:30" row must render identically to a freshly
        // detected 210-second row - same output, same code path.
        $this->assertSame('03:30', DurationFormatter::format('3:30'));
        $this->assertSame(DurationFormatter::format('210'), DurationFormatter::format('3:30'));
    }

    public function test_format_returns_null_for_absent_or_unparseable_duration(): void
    {
        $this->assertNull(DurationFormatter::format(null));
        $this->assertNull(DurationFormatter::format(''));
        $this->assertNull(DurationFormatter::format('garbage'));
    }
}
