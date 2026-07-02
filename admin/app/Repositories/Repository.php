<?php

namespace App\Repositories;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

abstract class Repository
{
    /**
     * Define relevant model
     *
     * @return Model|Builder
     */
    abstract public function model();

    /**
     * @return Builder
     */
    public function query()
    {
        return $this->model()::query();
    }

    /**
     * All data return from DB
     *
     * @return collection|Empty
     */
    public function getAll()
    {
        return $this->query()->get();
    }

    /**
     * Make sure primaryKey is id
     *
     * @param int-primaryKey
     * @return Builder|Model|object|null
     */
    public function find(int $primaryKey)
    {
        return $this->query()->find($primaryKey);
    }

    /**
     * Give first data in the model if exists
     *
     * @return Builder|Model|object|null
     */
    public function first()
    {
        return $this->query()->first();
    }

    /**
     * Make sure primaryKey is id
     *
     * @param int-primaryKey
     * @return Builder|Model|object|404
     */
    public function findOrFail(int $primaryKey)
    {
        return $this->query()->findOrFail($primaryKey);
    }

    /**
     * Make sure primaryKey is id
     *
     * @param int $primaryKey
     * @return bool
     */
    public function delete(int $primaryKey)
    {
        return $this->find($primaryKey)->delete();
    }

    /**
     * @param array $data
     * @return Builder|Model|mixed
     */
    public function create(array $data)
    {
        return $this->query()->create($data);
    }

    /**
     * @param Model $model
     * @param array $data
     * @return bool
     */
    public function update(Model $model, array $data)
    {
        return $model->update($data);
    }
}
