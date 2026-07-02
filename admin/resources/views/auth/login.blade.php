@php
    $websetting = App\Models\WebSetting::first();
@endphp
<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Fav icon -->
    <link rel="shortcut icon" type="image/png" sizes="16x16" href="{{ $websetting?->fav_icon_path ?? asset('web/images/fav_icon.png') }}">
    <!-- custome css -->
    <link rel="stylesheet" href="{{ asset('web/css/login.css') }}">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="{{ asset('web/css/bootstrap.min.css') }}">
    <!-- Font awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>Log In</title>
</head>

<body>
    <section class="login-section">
        <div class="z-0 position-absolute p-5 rounded-3 w-100 h-100" style="background-color: #00000033;"></div>
        <div class="card loginCard z-2">
            <div class="card-body">
                <form method="POST" action="{{ route('login') }}">
                    @csrf
                    <div class="page-content text-center">
                        <h2 class="pageTitle">Admin Login</h2>
                        <div class="logo">
                            <img src="{{ $websetting?->logoPath ?? asset('web/images/logo.png') }}" alt="logo">
                        </div>
                        <p class="pagePera">
                            {{ $websetting->subtitle ?? 'Hey, Enter your details to get login to your admin account' }}
                        </p>
                    </div>

                    @php
                        $email = Cookie::get('email');
                        $password = Cookie::get('password');
                    @endphp

                    <div class="mb-4">
                        <label class="mb-0">Email <span class="text-danger">*</span></label>
                        <input id="email" type="text" name="email"
                            class="form-control @error('email') is-invalid @enderror"
                            value="{{ $email ?? old('email') }}" placeholder="Enter email address">
                        @error('email')
                            <small class="text-danger">{{ $message }}</small>
                        @enderror
                    </div>

                    <div class="form-outline form-white mb-3">
                        <label class="mb-0">Password <span class="text-danger">*</span></label>
                        <div class="position-relative passwordInput">
                            <input id="password" type="password" name="password"
                                class="form-control @error('password') is-invalid @enderror" value="{{ $password }}"
                                placeholder="Enter Password">
                            <span class="eye" onclick="showHidePassword()">
                                <i class="fa fa-eye-slash fa-eye" id="togglePassword"></i>
                            </span>
                        </div>
                        @error('password')
                            <small class="text-danger">{{ $message }}</small>
                        @enderror
                    </div>
                    <div class="d-flex justify-content-between flex-wrap">
                        <div class="form-check checkbox">
                            <input class="form-check-input" id="check1" type="checkbox" name="remember"
                                {{ $email ? 'checked' : '' }}>
                            <label class="form-check-label" for="check1">Remember password</label>
                        </div>
                        {{-- @if (app()->environment('local'))
                            <span>
                                <button class="flex-shrink-0 btn btn-outline-primary btn-sm" type="button"
                                    onclick="setLoginCredential()">Copy</button>
                            </span>
                        @endif --}}
                        @if (app()->environment('local'))
                            <div class="card rounded mt-4" style="width: 100% !important;border-radius: 6px !important;">
                                <small class="card-header py-0">
                                    <i>Demo Credentials</i>
                                </small>
                                <div class="card-body py-2 position-relative">
                                    <span>Email: {{ config('app.demo_user') }}</span> <br>
                                    <span>Password: {{ config('app.demo_pass') }}</span>

                                    <button onclick="setLoginCredential()" class="btn btn-sm btn-outline-primary  position-absolute" style="right: 10px;top: calc(50% - 15px);" type="button">
                                        <i class="fa-regular fa-copy"></i>
                                    </button>
                                </div>
                            </div>
                        @endif
                    </div>
                    <div>
                        <button class="btn loginButton py-2" type="submit">Login</button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <script>
        const demoEmail = "{{ config('app.demo_user') }}"
        const demoPass = "{{ config('app.demo_pass') }}"
        function showHidePassword() {
            const toggle = document.getElementById("togglePassword");
            const password = document.getElementById("password");

            // toggle the type attribute
            const type = password.getAttribute("type") === "password" ? "text" : "password";
            password.setAttribute("type", type);
            // toggle the icon
            toggle.classList.toggle("fa-eye-slash");
        }

        const setLoginCredential = function() {
            var password = document.getElementById("password");
            var email = document.getElementById("email");

            email.value = demoEmail;
            password.value = demoPass;
        }
    </script>
</body>

</html>
