<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UpdateAdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        if (app()->environment('production')) {
            $this->updateProductionData();
        } else {
            $this->updateLocalData();
        }
    }

    private function updateLocalData()
    {
        $root = User::updateOrCreate(
            ['email' => 'root@playmusic.com'],
            [
                'email' => 'root@playmusic.com',
                'name' => 'Playmusic Root',
                'status' => true,
                'password' => Hash::make('secret')
            ]
        );

        $admin = User::updateOrCreate(
            ['email' => 'admin@playmusic.com'],
            [
                'name' => 'Playmusic Admin',
                'status' => true,
                'password' => Hash::make('secret')
            ]
        );

        $visitor = User::updateOrCreate(
            ['email' => 'user@playmusic.com'],
            [
                'name' => 'Playmusic User',
                'password' => Hash::make('secret'),
                'status' => true
            ]
        );

        $root->assignRole('root');
        $admin->assignRole('admin');
        $visitor->assignRole('user');

        return true;
    }

    private function updateProductionData()
    {
        $root = User::updateOrCreate(
            ['email' => 'root@playmusic.com'],
            ['name' => 'Playmusic Root', 'status' => true, 'password' => Hash::make('secret')],

        );

        $admin = User::updateOrCreate(
            ['email' => 'admin@playmusic.com'],
            ['name' => 'Playmusic Admin', 'status' => true, 'password' => Hash::make('secret')],
        );

        $visitor = User::updateOrCreate(
            ['email' => 'visitor@playmusic.com'],
            ['name' => 'Playmusic Visitor', 'password' => Hash::make('secret'), 'status' => true]
        );

        $root->assignRole('root');
        $admin->assignRole('admin');
        $visitor->assignRole('user');

        return true;
    }
}
