<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Document</title>
</head>
<body>
    <h1 style="text-align:center">Welcome To Maditam</h1>
    <div
        style=" background: #dfdfdf66;
        width: 100%;
        border-radius: 5px;
        padding: 10px;
        margin:0 auto;"
        >

        <h3>Hello {{ $user->name }}</h3>
        <p>Welcome to {{ config('app.name') }} — your space for calm, balance, and mindfulness. ✨</p>
        <p>
           To complete your registration and unlock guided meditations, breathing exercises, and personalized mindfulness journeys, please verify your email address.
        </p>
        <p>Click the button below to confirm your email: {{ $user->email }}</p>
        <div
            style=" text-align: center;
            overflow: hidden;
            padding: 20px;"
            >
            <a target="_blank" href="{{ route('email-verify', ['userId' => encrypt($user->id), 'token' => $verification->token]) }}"
            style="background: #0094ff;
                padding: 10px 20px;
                border-radius: 4px;
                color: #fff;
                text-decoration: none;
                font-weight: 700;"
                >Verify My Email</a>
        </div>
        <p>If you didn’t create an account with {{ config('app.name') }}, you can safely ignore this message.</p>

        <p>Wishing you peace and clarity, <br>
        The {{ config('app.name') }} Team</p>
    </div>
</body>
</html>
