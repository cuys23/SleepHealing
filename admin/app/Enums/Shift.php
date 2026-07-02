<?php

namespace App\Enums;

enum Shift: string
{
    case MORNING = 'Morning';
    case AFTERNOON = 'Afternoon';
    case EVENING = 'Evening';
    case NIGHT = 'Night';
    case MOSTRECOMANDED = 'Most Recomanded';
}