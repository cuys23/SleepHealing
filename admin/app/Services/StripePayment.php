<?php
namespace App\Services;

use App\Interfaces\PaymentGatewayInterface;
use Stripe\Stripe;

class StripePayment implements PaymentGatewayInterface
{
    public function processPayment($amount, array $data, array $config)
    {
        Stripe::setApiKey($config['secret_key']);
        $session = \Stripe\Checkout\Session::create([
            'line_items' => [
                [
                    'price_data' => [
                        'currency' => config('app.currency'),
                        'product_data' => ['name' => $data['product']['product']],
                        'unit_amount' => $amount * 100,
                    ],
                    'quantity' => 1,
                ]
            ],
            'mode' => 'payment',
            'success_url' => route('stripe.payment.success', $data['transaction_id']),
            'cancel_url' => route('stripe.payment.cancel'),
        ], ['api_key' => $config['secret_key']]);
        return redirect($session->url);
    }
    public function paymentSuccess($transaction_id)
    {
        $enroll = new PaypalPayment;
        return $enroll->enroll($transaction_id);
    }

    public function paymentCancel()
    {
        return redirect(config('app.frontend_url') . '/subscription-plans?status=cancel');
    }

}