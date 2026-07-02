<?php

namespace Database\Seeders;

use App\Models\PaymentGateway;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PaymentGatewaySeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        DB::table('payment_gateways')->truncate();

        $gateways = [
            'paypal' => [
                'mode' => 'sandbox',
                'client_id' => 'ASw2Ol4zJrd7UOYWz7Vjwv2ZBEZ9AXuF4aCbSXLXImOp8HaCFwGHCggJ1QBuzSoouGJ6vMncd9pMAtV9',
                'client_secret' => 'EA3d_eVh67xx4_vk1FYAsV75faeFvLVf1B6d2Rg9E4BfjXetw63k883MtSoVLi2v8P3bbW3tOJVFEKdt',
            ],
            'stripe' => [
                'publishable_key' => 'pk_test_2Iu9vNpu2ROjYOb9KHDBa3Hb00KSavaClK',
                'secret_key' => 'sk_test_AC8LYQ8cVN0RNGdhZ7G02zWe00lYKYw7LR',
            ],
            'twocheckout' => [
                'merchant' => '254928155937',
                'currency' => 'USD',
            ],
            'aamarpay' => [
                'store_id' => 'aamarpaytest',
                'signature_key' => 'dbb74894e82415a2f7ff0ec3a97e4183',
                'currency' => 'BDT',
            ]
        ];

        foreach ($gateways as $name => $config) {
            PaymentGateway::updateOrCreate([
                'name' => $name
            ], [
                'config' => json_encode($config),
                'type' => 'test',
                'is_active' => true,
            ]);
        }
    }
}
