@extends('layouts.app')
@section('content')
    <div class="container-fluid my-4">
        <div class="row">
            <div class="col-12 mt-2 mx-auto ">
                <div class="card shadow">
                    <div class="card-header bg-custom py-2">
                        <h3 class="m-0 text-white ">{{ __('Payment Configuration') }}</h3>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            {{-- Paypal Config Start --}}
                            <div class="col-md-6 mb-3">
                                <div class="card shadow-sm">
                                    <div class="card-header bg-white">
                                        <h3 class="m-0">{{ __('Paypal') }}</h3>
                                    </div>
                                    <form action="{{ route('paymentConfig.update') }}" method="POST"
                                        enctype="multipart/form-data">
                                        <div class="card-body">
                                            @method('put')
                                            @csrf
                                            <div class="row">
                                                <input type ="hidden" name="provider" value="paypal">
                                                <div class="py-2">
                                                    <img width="100%" id="preview{{ $paypal->name }}" class="paymentLogo"
                                                        src="{{ asset($paypal->logo) }}" alt="logo" loading="lazy">

                                                </div>
                                                <div class="col-md-12 mb-3">
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input"
                                                            {{ $paypal?->is_active == 1 ? 'checked' : '' }} value="1"
                                                            type="radio" name="status" id="paypalActive">
                                                        <label class="form-check-label" for="paypalActive">
                                                            Active
                                                        </label>
                                                    </div>
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input"
                                                            {{ $paypal?->is_active == 0 ? 'checked' : '' }} value="0"
                                                            type="radio" name="status" id="paypalInactive">
                                                        <label class="form-check-label" for="paypalInactive">
                                                            Inactive
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-12 mb-3">
                                                    <select name="mode" id="" class="form-control">
                                                        <option {{ $paypal?->type == 'sandbox' ? 'selected' : '' }}
                                                            value="sandbox">Test</option>
                                                        <option {{ $paypal?->type == 'live' ? 'selected' : '' }}
                                                            value="live">Live</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-12">
                                                    @php
                                                        $paypalConfig = json_decode($paypal?->config);
                                                    @endphp
                                                    <x-input value="{{ $paypalConfig?->client_id }}" name="client_id"
                                                        type="text" placeholder="Client ID" />
                                                </div>
                                                <div class="col-md-12">
                                                    <x-input value="{{ $paypalConfig?->client_secret }}"
                                                        name="client_secret" type="text" placeholder="Client Secret" />
                                                </div>

                                                <div class="col-md-12">
                                                    <input type="hidden" name="media_id" value="{{ $paypal->media_id }}">
                                                    <input name="image" type="file" class="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="card-footer bg-white">
                                            <button type="submit" class="btn btn-primary">{{ __('Update') }}</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                            {{-- Paypal Config End --}}

                            {{-- Stripe Config Start --}}
                            <div class="col-md-6 mb-3">
                                <div class="card shadow-sm">
                                    <div class="card-header bg-white">
                                        <h3 class="m-0">{{ __('Stripe') }}</h3>
                                    </div>
                                    <form action="{{ route('paymentConfig.update') }}" method="POST"
                                        enctype="multipart/form-data">
                                        <div class="card-body">
                                            @method('put')
                                            @csrf
                                            <div class="row">
                                                <input type ="hidden" name="provider" value="stripe">
                                                <div class="py-2">
                                                    <img width="100%" id="preview{{ $stripe->name }}" class="paymentLogo"
                                                        src="{{ asset($stripe->logo) }}" alt="logo" loading="lazy">

                                                </div>
                                                <div class="col-md-12 mb-3">
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input"
                                                            {{ $stripe?->is_active == 1 ? 'checked' : '' }} value="1"
                                                            type="radio" name="status" id="stripeActive">
                                                        <label class="form-check-label" for="stripeActive">
                                                            Active
                                                        </label>
                                                    </div>
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input"
                                                            {{ $stripe?->is_active == 0 ? 'checked' : '' }} value="0"
                                                            type="radio" name="status" id="stripeInactive">
                                                        <label class="form-check-label" for="stripeInactive">
                                                            Inactive
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-12 mb-3">
                                                    <select name="mode" id="" class="form-control">
                                                        <option {{ $stripe?->type == 'test' ? 'selected' : '' }}
                                                            value="test">Test</option>
                                                        <option {{ $stripe?->type == 'live' ? 'selected' : '' }}
                                                            value="live">Live</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-12">
                                                    @php
                                                        $stripeConfig = json_decode($stripe?->config);
                                                    @endphp
                                                    <x-input value="{{ $stripeConfig?->publishable_key }}"
                                                        name="publishable_key" type="text"
                                                        placeholder="Publishable Key" />
                                                </div>
                                                <div class="col-md-12">
                                                    <x-input value="{{ $stripeConfig?->secret_key }}" name="secret_key"
                                                        type="text" placeholder="Secret Key" />
                                                </div>

                                                <div class="col-md-12">
                                                    <input type="hidden" name="media_id"
                                                        value="{{ $stripe->media_id }}">
                                                    <input name="image" type="file" class="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="card-footer bg-white">
                                            <button type="submit" class="btn btn-primary">{{ __('Update') }}</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                            {{-- Stripe Config End --}}

                            {{-- 2Checkout Config Start --}}
                            <div class="col-md-6 mb-3">
                                <div class="card shadow-sm">
                                    <div class="card-header bg-white">
                                        <h3 class="m-0">{{ __('2Checkout') }}</h3>
                                    </div>
                                    <form action="{{ route('paymentConfig.update') }}" method="POST" enctype="multipart/form-data">
                                        <div class="card-body">
                                            @method('put')
                                            @csrf
                                            <div class="row">
                                                <input type ="hidden" name="provider" value="twocheckout">
                                                <div class="py-2">
                                                    <img width="100%" id="preview{{ $twocheckout->name }}" class="paymentLogo"
                                                        src="{{ asset($twocheckout->logo) }}" alt="logo" loading="lazy">

                                                </div>
                                                <div class="col-md-12 mb-3">
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input"
                                                            {{ $twocheckout?->is_active == 1 ? 'checked' : '' }}
                                                            value="1" type="radio" name="status"
                                                            id="twocheckoutActive">
                                                        <label class="form-check-label" for="twocheckoutActive">
                                                            Active
                                                        </label>
                                                    </div>
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input"
                                                            {{ $twocheckout?->is_active == 0 ? 'checked' : '' }}
                                                            value="0" type="radio" name="status"
                                                            id="twocheckoutInactive">
                                                        <label class="form-check-label" for="twocheckoutInactive">
                                                            Inactive
                                                        </label>
                                                    </div>
                                                </div>
                                            
                                                <div class="col-md-12 mb-3">
                                                    <select name="mode" id="" class="form-control">
                                                        <option {{ $twocheckout?->type == 'test' ? 'selected' : '' }}
                                                            value="test">Test</option>
                                                        <option {{ $twocheckout?->type == 'live' ? 'selected' : '' }}
                                                            value="live">Live</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-12">
                                                    @php
                                                        $twocheckoutConfig = json_decode($twocheckout?->config);
                                                    @endphp
                                                    <x-input value="{{ $twocheckoutConfig->merchant_id ?? '' }}"
                                                        name="merchant_id" type="text" placeholder="Merchant ID" />

                                                </div>
                                                   <div class="col-md-12">
                                                    <input type="hidden" name="media_id"
                                                        value="{{ $twocheckout->media_id }}">
                                                    <input name="image" type="file" class="form-control" />
                                                </div>

                                            </div>
                                        </div>
                                        <div class="card-footer bg-white">
                                            <button type="submit" class="btn btn-primary">{{ __('Update') }}</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                            {{-- 2Checkout Config End --}}

                            {{-- AamarPay Config Start --}}
                            <div class="col-md-6 mb-3">
                                <div class="card shadow-sm">
                                    <div class="card-header bg-white">
                                        <h3 class="m-0">{{ __('AamarPay') }}</h3>
                                    </div>
                                    <form action="{{ route('paymentConfig.update') }}" method="POST" enctype="multipart/form-data">
                                        <div class="card-body">
                                            @method('put')
                                            @csrf
                                            <div class="row">
                                                <input type ="hidden" name="provider" value="aamarpay">
                                                 <div class="py-2">
                                                    <img width="100%" id="preview{{ $aamarpay->name }}" class="paymentLogo"
                                                        src="{{ asset($aamarpay->logo) }}" alt="logo" loading="lazy">

                                                </div>
                                                <div class="col-md-12 mb-3">
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input"
                                                            {{ $aamarpay?->is_active == 1 ? 'checked' : '' }}
                                                            value="1" type="radio" name="status"
                                                            id="aamarpayActive">
                                                        <label class="form-check-label" for="aamarpayActive">
                                                            Active
                                                        </label>
                                                    </div>
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input"
                                                            {{ $aamarpay?->is_active == 0 ? 'checked' : '' }}
                                                            value="0" type="radio" name="status"
                                                            id="aamarpayInactive">
                                                        <label class="form-check-label" for="aamarpayInactive">
                                                            Inactive
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-12 mb-3">
                                                    <select name="mode" id="" class="form-control">
                                                        <option {{ $aamarpay?->type == 'test' ? 'selected' : '' }}
                                                            value="test">Test</option>
                                                        <option {{ $aamarpay?->type == 'live' ? 'selected' : '' }}
                                                            value="live">Live</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-12">
                                                    @php
                                                        $aamarpayConfig = json_decode($aamarpay?->config);
                                                    @endphp
                                                    <x-input value="{{ $aamarpayConfig?->store_id }}" name="store_id"
                                                        type="text" placeholder="Store ID" />
                                                </div>
                                                <div class="col-md-12">
                                                    <x-input value="{{ $aamarpayConfig?->signature_key }}" name="signature_key"
                                                        type="text" placeholder="Signature Key" />
                                                </div>
                                                 <div class="col-md-12">
                                                    <input type="hidden" name="media_id"
                                                        value="{{ $aamarpay->media_id }}">
                                                    <input name="image" type="file" class="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="card-footer bg-white">
                                            <button type="submit" class="btn btn-primary">{{ __('Update') }}</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                            {{-- AamarPay Config End --}}

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <style>
        .infoBtn {
            border: none;
            width: 20px;
            height: 20px;
            border-radius: 100%;
            font-size: 12px;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            color: #fff;
        }
    </style>
@endsection
