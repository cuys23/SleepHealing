<?php

namespace App\Http\Controllers\API;

use App\Models\Subscription;
use App\Http\Controllers\Controller;
use App\Http\Requests\SubscribeRequest;
use App\Models\SubscriptionPlan;
use App\Models\Transaction;
use App\Repositories\SubscriptionRepository;
use App\Http\Resources\SubscriptionResouorce;
use App\Http\Resources\SubscriptionPlanResource;
use App\Models\PaymentGateway;
use App\Repositories\SubscriptionPlanRepository;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use PayPalCheckoutSdk\Core\PayPalHttpClient;
use PayPalCheckoutSdk\Core\SandboxEnvironment;
use PayPalCheckoutSdk\Orders\OrdersCreateRequest;
use Stripe\Stripe;
use Stripe\Checkout\Session;

class SubscriptionController extends Controller
{
    public function __construct(
        private PaymentService $paymentService
    ) {


    }
    public function index()
    {
        $subscriptionPlans = (new SubscriptionPlanRepository())->getAll();

        return $this->json('Subscription plan list', [
            'plans' => SubscriptionPlanResource::collection($subscriptionPlans)
        ]);
    }

     public function buySubscription(SubscribeRequest $request)
    {
        $user = auth()->user();

        $plan = (new SubscriptionRepository())->storeByRequest($request);


        $user = auth()->user();
        $amount = $plan->amount;

        $successUrl = route('payment.success');
        $cancelUrl  = route('payment.cancel');
        $fairUrl = route('aamrpay.payment.fail');


        switch ($request->payment_method) {
            case 'stripe':

                $paymentMethod = PaymentGateway::where('name','stripe')->first();

                $publishedKey =json_decode($paymentMethod->config)->publishable_key;
                $secretKey = json_decode($paymentMethod->config)->secret_key;

                if (!$publishedKey || !$secretKey) {
                    return $this->json('Stripe credentials not configured.' ,[], 500);
                }

                Stripe::setApiKey($secretKey);

                try {
                    $callbackUrl = $successUrl . '?' . http_build_query([
                        'payment' => 'stripe',
                        'plan_id' => $request->plan_id,
                        'user_id' => $user->id
                    ]);

                    $session = Session::create([
                        'payment_method_types' => ['card'],
                        'line_items' => [[
                            'price_data' => [
                                'currency' => 'usd',
                                'product_data' => ['name' => 'Plan #' . $request->plan_id],
                                'unit_amount' => (int)($amount * 100),
                            ],
                            'quantity' => 1,
                        ]],
                        'mode' => 'payment',
                        'success_url' => $callbackUrl . '&session_id={CHECKOUT_SESSION_ID}',
                        'cancel_url' => $cancelUrl . '?payment=stripe',
                        'metadata' => [
                            'plan_id' => $request->plan_id,
                            'user_id' => $user->id,
                        ],
                    ]);

                      return $this->json('Redirecting to payment gateway.' ,[
                            'redirectUrl' => $session->url
                        ], 201);

                } catch (\Exception $e) {
                    return $this->json('Stripe error: ' . $e->getMessage() ,[], 500);
                }
            case 'paypal':
                $paymentMethod = PaymentGateway::where('name', 'paypal')->first();

                $clientId = json_decode($paymentMethod->config)->client_id;
                $secret = json_decode($paymentMethod->config)->client_secret;

                $environment = new SandboxEnvironment($clientId, $secret);
                $client = new PayPalHttpClient($environment);

                $orderData = [
                    'intent' => 'CAPTURE',
                    'purchase_units' => [
                        [
                            'reference_id' => 'default',
                            'amount' => [
                                'currency_code' => 'USD',
                                'value' => number_format($amount, 2),
                            ],
                            'description' => 'Plan #' . $request->plan_id,
                            'custom_id' => $request->plan_id,
                        ]
                    ],
                    'application_context' => [
                        'return_url' => $successUrl . '?' . http_build_query([
                            'payment' => 'paypal',
                            'plan_id' => $request->plan_id,
                            'user_id' => $user->id,
                        ]),
                        'cancel_url' => $cancelUrl . '?payment=paypal',
                    ]
                ];

                $request = new OrdersCreateRequest();
                $request->body = $orderData;


                try {
                    $response = $client->execute($request);
                    $approvalUrl = '';

                    foreach ($response->result->links as $link) {
                        if ($link->rel == 'approve') {
                            $approvalUrl = $link->href;
                            break;
                        }
                    }

                    return $this->json('Redirecting to payment gateway.', [
                        'redirectUrl' => $approvalUrl
                    ], 201);

                } catch (\Exception $e) {
                    return $this->json('PayPal error: ' . $e->getMessage(), [], 500);
                }
            case 'twocheckout':
                $paymentMethod = PaymentGateway::where('name', 'twocheckout')->first();
                $accountNumber = json_decode($paymentMethod->config)->merchant_id;

                $paymentParams = [
                    'sid' => $accountNumber,
                    'mode' => 'sandbox',
                    'li_0_name' => 'Subscription Plan',
                    'li_0_price' => $amount,
                    'li_0_quantity' => 1,
                    'currency_code' => 'USD',
                    'return_url' => $successUrl . '?plan_id=' . $request->plan_id,
                    'cancel_url' => $cancelUrl . '?plan_id=' . $request->plan_id,
                    'order_id' => uniqid('order_'),
                    'merchant_order_id' => uniqid('order_'),
                    'email' => $user->email,
                ];


                $queryString = http_build_query($paymentParams);
                $paymentUrl = 'https://www.2checkout.com/checkout/purchase?' . $queryString;

                return $this->json('Redirecting to payment gateway.' ,[
                            'redirectUrl' => $paymentUrl
                        ], 201);



            case 'aamarpay':
                $paymentMethod = PaymentGateway::where('name', 'aamarpay')->first();
                $config = json_decode($paymentMethod->config);

                $url = "https://sandbox.aamarpay.com/jsonpost.php";

                $tran_id = 'ORD_' . time() . '_' . uniqid();

                $postData = [
                    "store_id"       => $config->store_id,
                    "signature_key"  => $config->signature_key,
                    "amount"         => $amount,
                    "currency"       => "BDT",
                    "tran_id"        => $tran_id,
                    "desc"           => "Subscription Payment",
                    "cus_name"       => $user->name ?? 'Customer',
                    "cus_email"      => $user->email,
                    "cus_phone"      => $user->phone ?? '01700000000',
                    "cus_add1"       => "Dhaka",
                    "cus_city"       => "Dhaka",
                    "cus_country"    => "Bangladesh",

                    "success_url"    => route('aamrpay.payment.success',['plan_id'=> $request->plan_id,'user_id'=> $user->id, 'tran_id'=> $tran_id]),
                    "fail_url"       => $fairUrl,
                    "cancel_url"     => $cancelUrl,

                    "type"           => "json"
                ];

                $curl = curl_init();

                curl_setopt_array($curl, [
                    CURLOPT_URL            => $url,
                    CURLOPT_RETURNTRANSFER => true,
                    CURLOPT_ENCODING       => "",
                    CURLOPT_MAXREDIRS      => 10,
                    CURLOPT_TIMEOUT        => 30,
                    CURLOPT_FOLLOWLOCATION => true,
                    CURLOPT_HTTP_VERSION   => CURL_HTTP_VERSION_1_1,
                    CURLOPT_CUSTOMREQUEST  => "POST",
                    CURLOPT_POSTFIELDS     => json_encode($postData),
                    CURLOPT_HTTPHEADER     => [
                        'Content-Type: application/json'
                    ],
                ]);

                $response = curl_exec($curl);
                $err      = curl_error($curl);
                curl_close($curl);



                if ($err) {
                    return $this->json('cURL Error: ' . $err, [], 500);
                }

                $responseObj = json_decode($response);

                if ($responseObj && isset($responseObj->payment_url)) {
                    return $this->json('Redirecting to AamarPay...', [
                        'redirectUrl' => $responseObj->payment_url
                    ], 200);
                }

                return $this->json('AamarPay Payment Failed', [
                    'error'    => $responseObj->message ?? 'Unknown error',
                    'response' => $responseObj
                ], 500);



            default:
               return $this->json('Redirecting to payment gateway.' ,[
                    'status' => 'error',
                    'message' => 'Invalid payment method'
                ], 400);
        }
    }




    public function paymentView(string $transaction_id)
    {
        $transaction = Transaction::query()->where('transaction_id', '=', $transaction_id)->first();

        if ($transaction) {
            $planDetails = SubscriptionPlan::query()->where('id', '=', $transaction->plan_id)->first();
            return $this->paymentService->processPayment($planDetails->amount, [
                'gateway' => $transaction->payment_method,
                'transaction_id' => base64_encode($transaction->transaction_id),
                'product' => [
                    'product' => $planDetails->name,
                    'price' => $planDetails->amount,
                ],
                'customer' => [
                    'name' => $transaction->user?->name ?? 'N/A',
                    'email' => $transaction->user?->email ?? 'N/A',
                    'phone' => $transaction->user?->phone ?? 'N/A',
                ]
            ]);
        }
        return $this->json('Transaction not found', null, 404);


    }

    public function myPlans()
    {
        $user = auth()->user();
        $subscriptions = $user->subscriptions()->where('is_paid', '=', 1)->get();

        return $this->json('My subscription plan list', [
            'subscriptions' => SubscriptionResouorce::collection($subscriptions)
        ]);
    }

    public function store(SubscribeRequest $request)
    {
        $user = auth()->user();
        $is_expired = Subscription::hasSubscribed($user);
        if ($is_expired) {
            return $this->json('subscription plan buy successfully');
        }

        $plan = (new SubscriptionRepository())->storeByRequest($request);
        return $this->json('subscription plan buy successfully', [
            'subscription' => SubscriptionResouorce::make($plan)
        ]);
    }
}
