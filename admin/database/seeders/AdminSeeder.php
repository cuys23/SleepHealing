<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        if(app()->environment('local')){
            $this->local();
        }
    }

    private function local()
    {
        $root = User::factory()->create([
            'name' => 'Maditam Root',
            'email' => 'root@example.com',
            'status' => true,
        ]);

        $admin = User::factory()->create([
            'name' => 'Maditam Admin',
            'email' => 'admin@example.com',
            'status' => true,
        ]);

        $visitor = User::factory()->create([
            'name' => 'Maditam Visitor',
            'email' => 'visitor@maditam.com',
            'password' => Hash::make('secret@1234'),
            'status' => true,
        ]);

        $root->assignRole('root');
        $admin->assignRole('admin');
        $visitor->assignRole('visitor');

        return true;
    }
}
