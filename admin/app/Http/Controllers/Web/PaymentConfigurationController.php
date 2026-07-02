<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\PaymentGateway;
use App\Repositories\MediaRepository;
use Illuminate\Http\Request;

class PaymentConfigurationController extends Controller
{
    public function index()
    {
        $payments = PaymentGateway::all();
        $paypal = $payments->where('name', 'paypal')->first();
        $stripe = $payments->where('name', 'stripe')->first();
        $twocheckout = $payments->where('name', 'twocheckout')->first();
        $aamarpay = $payments->where('name', 'aamarpay')->first();
        return view('payment_config.index', compact('paypal', 'stripe', 'twocheckout', 'aamarpay'));
    }

    public function update(Request $request)
    {

        $request->validate([
            'provider' => 'required|string',
            'status' => 'required|boolean',
            'mode' => 'required|string',
        ]);

        $configData = [];
        switch ($request->provider) {

            case 'paypal':
                $configData = [
                    'client_id' => $request->client_id,
                    'client_secret' => $request->client_secret,
                ];
                break;

            case 'stripe':
                $configData = [
                    'publishable_key' => $request->publishable_key,
                    'secret_key' => $request->secret_key,
                ];
                break;
            case 'twocheckout':
                $configData = [
                    'merchant_id' => $request->merchant_id,
                ];
                break;


            case 'aamarpay':
                $configData = [
                    'store_id' => $request->store_id,
                    'signature_key' => $request->signature_key,
                ];
                break;
            default:
                return back()->withErrors(['message' => 'Invalid payment provider']);
        }

        $media = null;
        if($request->media_id == null && $request->hasFile('image')){
            $media = (new MediaRepository())->storeByRequest(
                $request->file('image'),
                'gateway/logo',
                'Image'
            );
        }else{
            if ($request->hasFile('image')) {
                    $media = (new MediaRepository())->updateByRequest(
                        $request->file('image'),  // UploadedFile
                        $request->media_id,                  // Media
                        'gateway/logo',          // path
                        'Image'                  // type
                    );
                }
        }

         PaymentGateway::updateOrCreate(
            ['name' => $request->provider],
            [
                'is_active' => $request->status,
                'type' => $request->mode,
                'config' => json_encode($configData),
                'media_id' => $media ? $media->id : $request->media_id,
            ]
        );

        return back()->with('success', 'Payment gateway configuration updated successfully.');
    }
}
