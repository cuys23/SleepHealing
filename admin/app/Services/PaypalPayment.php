<?php
namespace App\Services;

use App\Interfaces\PaymentGatewayInterface;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Srmklive\PayPal\Services\PayPal as PayPalClient;

class PaypalPayment implements PaymentGatewayInterface
{
    public $configSuccess;
    public function processPayment($amount, array $data, array $configInput)
    {
        $config = [
            "mode" => $configInput['mode'],
            "sandbox" => [
                "client_id" => $configInput['client_id'],
                "client_secret" => $configInput['client_secret'],
                "app_id" => "APP-80W284485P519543T"
            ],
            "live" => [
                "client_id" => $configInput['client_id'],
                "client_secret" => $configInput['client_secret'],
                "app_id" => "APP-80W284485P519543T"
            ],
            "payment_action" => "Sale",
            "currency" => config('app.currency'),
            "notify_url" => "",
            "locale" => "en_US",
            "validate_ssl" => false
        ];

        session(['configSuccess' => $config]);
        $provider = new PayPalClient();
        $provider->setApiCredentials($config);
        $provider->getAccessToken();

        $response = $provider->createOrder([
            "intent" => "CAPTURE",
            "application_context" => [
                "return_url" => route('paypal.payment.success', $data['transaction_id']),
                "cancel_url" => route('paypal.payment.cancel'),
            ],
            "purchase_units" => [
                0 => [
                    "amount" => [
                        "currency_code" => config('app.currency'),
                        "value" => $amount
                    ]
                ]
            ]
        ]);
        if (isset($response['id']) && $response['id'] != null) {
            foreach ($response['links'] as $links) {
                if ($links['rel'] == 'approve') {
                    return redirect()->away($links['href']);
                }
            }
        }

        return redirect(url('/subscription-plans'));
    }
    public function paymentCancel()
    {
        return redirect(url('/subscription-plans'));
    }


    public function paymentSuccess(Request $request, string $transaction_id)
    {
        $configSuccess = session('configSuccess');
        $provider = new PayPalClient;
        $provider->setApiCredentials($configSuccess);
        $provider->getAccessToken();
        $response = $provider->capturePaymentOrder($request['token']);

        if (isset($response['status']) && $response['status'] == 'COMPLETED') {
            return $this->enroll($transaction_id);
        } else {
            return redirect(config('app.frontend_url') . '/subscription-plans?status=success');
        }
    }

    public function enroll(string $transaction_id)
    {
        $decodedId = base64_decode($transaction_id);
        $transaction = Transaction::query()->where('transaction_id', '=', $decodedId)->first();

        if (!$transaction) {
            return redirect(config('app.frontend_url') . '/subscription-plans?status=failed');
        }

        $plan = SubscriptionPlan::query()->where('id', '=', $transaction->plan_id)->first();
        if (!$plan) {
            return redirect(config('app.frontend_url') . '/subscription-plans?status=failed');
        }

        $transaction->update(['is_paid' => true, 'paid_at' => now()]);
        Subscription::create([
            'user_id' => $transaction->user_id,
            'subscription_plan_id' => $plan->id,
            'expired_at' => now()->addMonths($plan->duration),
            'amount' => $plan->amount,
        ]);

        return redirect(config('app.frontend_url') . '/subscription-plans?status=success');
    }

}