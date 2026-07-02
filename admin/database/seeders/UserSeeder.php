<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        for($i = 0; $i < rand(10, 50); $i++){
            $user = User::factory()->create([
                'email' => 'user_' . $i . '@example.com'
            ]);

            $user->assignRole('user');
        }
    }
}
