<?php 

namespace App\Enums;

enum Badge: string
{
    case UPCOMING = 'Upcoming';
    case NEW = 'New';
    case POPULAR = 'Popular';
    case LATEST = 'Latest';
}