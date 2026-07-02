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
        <p>
            Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum
        </p>
        <h4>Please Click this button for verify your Email address</h4>
        <div
            style=" text-align: center;
            overflow: hidden;
            padding: 20px;"
            >
            <span
            style="background: #ddd;
                padding: 10px 20px;
                border-radius: 4px;
                color: rgb(24, 24, 24);
                text-decoration: none;
                font-weight: 700;"
                >OTP: {{ $verification->otp }}</span>
        </div>
    </div>
</body>
</html>
