<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Artisan;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        $this->call(RoleSeeder::class);
        $this->call(AdminSeeder::class);
        $this->call(SettingSeeder::class);
        $this->call(WebSettingSeeder::class);
        $this->call(ShiftSeeder::class);
        $this->call(PaymentGatewaySeeder::class);

        if(app()->environment('local')){
            $this->call(UserSeeder::class);
            $this->call(CategorySeeder::class);
            $this->call(AlbamSeeder::class);
            $this->call(PlaylistSeeder::class);
            $this->call(SubscriptionPlanSeeder::class);
            $this->call(SubscriptionSeeder::class);
        }

        $this->installPassportClient();
    }

    private function installPassportClient()
    {
        $this->command->warn('Passport installing........');
        Artisan::call('passport:install');
        $this->command->info('Passport installed');
    }
}
