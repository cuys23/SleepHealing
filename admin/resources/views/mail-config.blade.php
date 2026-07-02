@extends('layouts.app')
@section('content')
    <div class="container-fluid my-4">
        <div class="row">
            <div class="col-xl-8 col-lg-9 mt-2 mx-auto ">
                <form action="{{ route('mailConfig.update') }}" method="POST">
                    @method('put')
                    @csrf
                    <div class="card shadow">
                        <div class="card-header bg-white">
                            <h3 class="m-0">{{ __('SMTP Configuration') }}</h3>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-6">
                                    <x-input :value="config('app.mail_mailer')" name="mailer" type="text"
                                        placeholder="Mail Mailer" />
                                </div>
                                <div class="col-lg-6">
                                    <x-input :value="config('app.mail_host')" name="host" type="text" placeholder="Mail Host"/>
                                </div>
                                <div class="col-lg-6">
                                    <x-input :value="config('app.mail_port')" name="port" type="text" placeholder="Mail Port"/>
                                </div>
                                <div class="col-md-6">
                                    <x-input :value="config('app.mail_username')" name="username" type="text" placeholder="Mail User Name"/>
                                </div>
                                <div class="col-md-6">
                                    <x-input :value="config('app.mail_password')" name="password" type="text" placeholder="Mail Password"/>
                                </div>
                                <div class="col-md-6">
                                    <x-input :value="config('app.mail_encryption')" name="encryption" type="text" placeholder="Mail Encryption"/>
                                </div>
                                <div class="col-md-6 mb-2">
                                    <x-input :value="config('app.mail_from_address')" name="from_address" type="text" placeholder="Mail From Address" required />
                                </div>
                            </div>
                        </div>
                        <div class="card-footer bg-white">
                            <button type="submit" class="btn btn-primary">{{ __('Submit') }}</button>
                        </div>
                    </div>
                </form>
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
