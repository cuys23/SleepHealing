<?php
namespace App\Services;

use App\Interfaces\PaymentGatewayInterface;
use Illuminate\Http\Request;

class AamarPayment implements PaymentGatewayInterface
{

    public function processPayment($amount, array $data, array $config)
    {

        // Generate a unique transaction ID
        $tran_id = uniqid();

        // Set the currency to use (BDT for Bangladeshi Taka)
        $currency = $config['currency'];

        // Store ID provided by Aamar Payment
        $store_id = $config['store_id'];

        // Signature key provided by Aamar Payment
        $signature_key = $config['signature_key'];

        // URL to send the payment request
        $url = "https://sandbox.aamarpay.com/jsonpost.php";

        // Initialize cURL
        $curl = curl_init();
        // Set cURL options
        curl_setopt_array(
            $curl,
            array(
                CURLOPT_URL => $url,
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_ENCODING => "",
                CURLOPT_MAXREDIRS => 10,
                CURLOPT_TIMEOUT => 30,
                CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
                CURLOPT_CUSTOMREQUEST => "POST",
                CURLOPT_FOLLOWLOCATION => true,
                CURLOPT_POSTFIELDS => '{' .
                    '"store_id": "' . $store_id . '",' .
                    '"tran_id": "' . $tran_id . '",' .
                    '"success_url": "' . route('aamrpay.payment.success') . '",' .
                    '"fail_url": "' . route('aamrpay.payment.fail') . '",' .
                    '"cancel_url": "' . route('aamrpay.payment.cancel') . '",' .
                    '"amount": "' . $amount . '",' .
                    '"currency": "' . $currency . '",' .
                    '"signature_key": "' . $signature_key . '",' .
                    '"desc": "Merchant Registration Payment",' .
                    '"cus_name": "Name",' .
                    '"cus_email": "payer@merchantcusomter.com",' .
                    '"cus_add1": "House B-158 Road 22",' .
                    '"cus_add2": "Mohakhali DOHS",' .
                    '"cus_city": "Dhaka",' .
                    '"cus_state": "Dhaka",' .
                    '"cus_postcode": "1206",' .
                    '"cus_country": "Bangladesh",' .
                    '"cus_phone": "+8801704",' .
                    '"type": "json"' .
                    '}',
                CURLOPT_HTTPHEADER => array(
                    'Content-Type: application/json'
                ),
            )
        );

        // Execute the cURL request and get the response
        $response = curl_exec($curl);

        // Close the cURL session
        curl_close($curl);

        // Decode the JSON response
        $responseObj = json_decode($response);

        // If a payment URL is returned, redirect the user to it
        if (isset($responseObj->payment_url) && !empty($responseObj->payment_url)) {

            $paymentUrl = $responseObj->payment_url;
            return redirect()->away($paymentUrl);

        } else {
            // Otherwise, echo the response
            echo $response;
        }

    }

    public function paymentSuccess(Request $request)
    {
        // Extract the transaction ID from the request
        $request_id = $request->mer_txnid;

        // Construct the URL to check the transaction status
        $url = "http://sandbox.aamarpay.com/api/v1/trxcheck/request.php"
            . "?request_id=$request_id"
            . "&store_id=aamarpaytest"
            . "&signature_key=dbb74894e82415a2f7ff0ec3a97e4183"
            . "&type=json";

        // Initialize cURL
        $curl = curl_init();

        // Set cURL options
        curl_setopt_array(
            $curl,
            array(
                CURLOPT_URL => $url,
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_ENCODING => '',
                CURLOPT_MAXREDIRS => 10,
                CURLOPT_TIMEOUT => 0,
                CURLOPT_FOLLOWLOCATION => true,
                CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
                CURLOPT_CUSTOMREQUEST => 'GET',
            )
        );

        // Execute the cURL request and get the response
        $response = curl_exec($curl);

        // Close the cURL session
        curl_close($curl);

        return redirect(config('app.frontend_url') . '/subscription-plans?status=success');
    }


    public function paymentFail(Request $request)
    {
        return redirect(config('app.frontend_url') . '/subscription-plans?status=failed');
    }


    public function paymentCancel()
    {
    
        return redirect(config('app.frontend_url') . '/subscription-plans?status=cancel');
    }
}