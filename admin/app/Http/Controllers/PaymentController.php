<?php

namespace App\Http\Controllers;

use App\Models\PaymentGateway;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\Transaction;
use App\Models\User;
use App\Services\AamarPayment;
use App\Services\PaymentService;
use App\Services\PaypalPayment;
use App\Services\StripePayment;
use Carbon\Carbon;
use Illuminate\Http\Request;
use PayPalCheckoutSdk\Core\PayPalHttpClient;
use PayPalCheckoutSdk\Core\SandboxEnvironment;
use PayPalCheckoutSdk\Orders\OrdersCaptureRequest;

class PaymentController extends Controller
{
    protected $paymentService;
    public function index()
    {
        return view('payment');
    }

    public function payment(Request $request)
    {
        $paymentService = (new PaymentService());

        $this->paymentService = $paymentService;
        $amount = 100;
        $data = $request->all();
        return $this->paymentService->processPayment($amount, $data);

    }

    public function paymentSuccess(Request $request, $transaction_id)
    {

        $success = (new PaypalPayment);
        return $success->paymentSuccess($request, $transaction_id);
    }

    public function paymentCancel()
    {
        $cancel = (new PaypalPayment());
        return $cancel->paymentCancel();
    }

    public function stripePaymentSuccess($transaction_id)
    {
        $success = (new StripePayment());
        return $success->paymentSuccess($transaction_id);
    }

    public function stripePaymentCancel()
    {
        $cancel = (new StripePayment());
        return $cancel->paymentCancel();
    }

    public function aamarpayPaymentSuccess(Request $request)
    {

        $plan = SubscriptionPlan::find(request('plan_id'));
        $user = User::find(request('user_id'));

        $amount = $plan->amount;
        $transactionId = request('tran_id');

        foreach ($user->subscriptions as $subscription) {
            $subscriptionPlanId = $subscription->subscription_plan_id;
            if ($subscriptionPlanId == $plan->id) {
                $subscription->update([
                    'is_paid' => true
                ]);

                Transaction::create([
                    'user_id' => $user->id,
                    'plan_id' => $plan->id,
                    'amount' => $amount,
                    'is_paid' => true,
                    'payment_method' => 'amarpay',
                    'transaction_id' => $transactionId,
                     ]);
                }
            }

        return to_route('payment.success.response');


        $success = (new AamarPayment());
        return $success->paymentSuccess($request);
    }


    public function aamarpayPaymentCancel()
    {
        $cancel = (new AamarPayment());
        return $cancel->paymentCancel();
    }

    public function aamarpayPaymentFail(Request $request)
    {
        $fail = (new AamarPayment());
        return $fail->paymentFail($request);
    }



      public function successPayment(Request $request)
    {
        $queryParameters = $request->query();
        $plan = SubscriptionPlan::find($queryParameters['plan_id']);
        $user = User::find($queryParameters['user_id']);

        $amount = $plan->amount;
        $paymentMethod = $queryParameters['payment'];

        switch ($paymentMethod) {
            case 'stripe':
                $paymentMethod = PaymentGateway::where('name','stripe')->first();
                $secret_key = json_decode($paymentMethod->config)->secret_key;

                \Stripe\Stripe::setApiKey($secret_key);

                $sessionId = $queryParameters['session_id'];

                $session = \Stripe\Checkout\Session::retrieve($sessionId);

                if ($session->payment_status === 'paid') {

                       foreach ($user->subscriptions as $subscription) {

                            $subscriptionPlanId = $subscription->subscription_plan_id;
                            if ($subscriptionPlanId == $plan->id) {
                                $subscription->update([
                                    'is_paid' => true
                                ]);
                                Transaction::create([
                                    'user_id' => $user->id,
                                    'plan_id' => $plan->id,
                                    'amount' => $amount,
                                    'is_paid' => true,
                                    'payment_method' => 'stripe',
                                    'transaction_id' => $session->id
                                ]);


                        }
                        }
                    return to_route('payment.success.response');
                }
                return to_route('payment.cancel');
             case 'paypal':
                $paymentMethod = PaymentGateway::where('name', 'paypal')->first();
                $clientId = json_decode($paymentMethod->config)->client_id;
                $secretKey = json_decode($paymentMethod->config)->client_secret;

                $environment = new SandboxEnvironment($clientId, $secretKey);
                $client = new PayPalHttpClient($environment);

                $payerId = $queryParameters['PayerID'];
                $orderId = $queryParameters['token'];

                $captureRequest = new OrdersCaptureRequest($orderId);
                try {
                    $response = $client->execute($captureRequest);

                    if ($response->result->status === 'COMPLETED') {
                        foreach ($user->subscriptions as $subscription) {
                            $subscriptionPlanId = $subscription->subscription_plan_id;
                            if ($subscriptionPlanId == $plan->id) {
                                $subscription->update([
                                    'is_paid' => true
                                ]);

                                Transaction::create([
                                    'user_id' => $user->id,
                                    'plan_id' => $plan->id,
                                    'amount' => $amount,
                                    'is_paid' => true,
                                    'payment_method' => 'paypal',
                                    'transaction_id' => $response->result->id,
                                ]);
                            }
                        }

                        return to_route('payment.success.response');
                    } else {
                        return to_route('payment.cancel');
                    }
                } catch (\Exception $e) {
                    return $this->json('PayPal error: ' . $e->getMessage(), [], 500);
                }
            case 'twocheckout':
                $paymentMethod = PaymentGateway::where('name', 'twocheckout')->first();
                $secretKey = json_decode($paymentMethod->config)->secret_key;
                $orderId = $queryParameters['order_id'];
                $transactionId = $queryParameters['transaction_id'];
                $status = $queryParameters['status'];

                try {
                    if ($status === 'success') {
                        foreach ($user->subscriptions as $subscription) {
                            $subscriptionPlanId = $subscription->subscription_plan_id;
                            if ($subscriptionPlanId == $plan->id) {
                                $subscription->update([
                                    'is_paid' => true
                                ]);

                                Transaction::create([
                                    'user_id' => $user->id,
                                    'plan_id' => $plan->id,
                                    'amount' => $amount,
                                    'is_paid' => true,
                                    'payment_method' => 'twocheckout',
                                    'transaction_id' => $transactionId,
                                ]);
                            }
                        }

                        return to_route('payment.success.response');
                    } else {
                        return to_route('payment.cancel');
                    }
                } catch (\Exception $e) {
                    return $this->json('2Checkout error: ' . $e->getMessage(), [], 500);
                }
            case 'aamarpay':

                $paymentMethod = PaymentGateway::where('name', 'aamarpay')->first();

                $orderId = $queryParameters['order_id'];
                $transactionId = $queryParameters['transaction_id'];
                $paymentStatus = $queryParameters['status'];

                try {

                    if ($paymentStatus === 'success') {

                        foreach ($user->subscriptions as $subscription) {
                            $subscriptionPlanId = $subscription->subscription_plan_id;
                            if ($subscriptionPlanId == $plan->id) {
                                $subscription->update([
                                    'is_paid' => true
                                ]);

                                Transaction::create([
                                    'user_id' => $user->id,
                                    'plan_id' => $plan->id,
                                    'amount' => $amount,
                                    'is_paid' => true,
                                    'payment_method' => 'amarpay',
                                    'transaction_id' => $transactionId,
                                ]);
                            }
                        }

                        return to_route('payment.success.response');
                    } else {
                        return to_route('payment.cancel');
                    }
                } catch (\Exception $e) {
                    return $this->json('AmarPay error: ' . $e->getMessage(), [], 500);
                }


            default:
            return $this->json(message: 'Payment not completed');
        }
    }

    public function success()
    {
        return $this->json('Payment done successfully.');

    }



    public function cancelPayment()
    {

        return $this->json('Payment not completed.');

    }
}
