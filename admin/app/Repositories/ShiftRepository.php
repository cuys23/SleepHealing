<?php

namespace App\Repositories;

use App\Models\Shift;

class ShiftRepository extends Repository
{
    public $path = 'images/shift/';
    public function model()
    {
        return Shift::class;
    }

    public function findByType($type)
    {
        return $this->query()->where('type', $type)->first();
    }
}
