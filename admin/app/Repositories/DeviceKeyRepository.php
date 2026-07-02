<?php

namespace App\Repositories;

use App\Models\DeviceKey;

class DeviceKeyRepository extends Repository
{
    public function model()
    {
        return DeviceKey::class;
    }

    public function findByKey($key)
    {
        return $this->model()::where('key', $key)->first();
    }

    public function storeByRequest($user, $request): DeviceKey
    {

        $exists = $this->model()::updateOrCreate(
            [
                'key' => $request->device_key ? $request->device_key : 0
            ],
            [
                'user_id' => $user->id,
                'device_type' => $request->device_type
            ]
        );

        return $exists;
    }

    public function destroy($key): bool
    {
        $exists = $this->findByKey($key);

        if ($exists) {
            $exists->delete();
            return true;
        }
        return false;
    }
}
