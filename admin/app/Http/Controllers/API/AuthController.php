<?php

namespace App\Http\Controllers\API;

use App\Models\WebSetting;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use App\Http\Controllers\Controller;
use App\Http\Requests\SigninRequest;
use App\Http\Requests\SignupRequest;
use App\Http\Resources\UserResource;
use App\Repositories\UserRepository;
use Illuminate\Support\Facades\Hash;
use App\Events\EmailVerificationEvent;
use App\Http\Requests\ForgotPasswordRequest;
use App\Http\Requests\ResetPasswordRequest;
use App\Http\Requests\SocialLoginRequest;
use App\Http\Requests\VerifyOtpRequest;
use App\Models\Subscription;
use App\Repositories\DeviceKeyRepository;
use App\Repositories\VerificationRepository;

class AuthController extends Controller
{

    public function __construct(public UserRepository $userRepo)
    {
    }

    public function signIn(SigninRequest $request)
    {
        $websetting = WebSetting::first();
        $is_expired = false;
        if ($user = $this->authenticate($request)) {

            $subscriptions = $user->subscriptions()->where('is_paid', '=', 1)->get();

            if($subscriptions->count()>0){
                $is_expired = Subscription::hasSubscribed($user);
            }

            if ($request->device_key) {
                (new DeviceKeyRepository())->storeByRequest($user, $request);
            }

            return $this->json('Log In Successful', [
                'has_subscribed' => $websetting?->subscription ? true : ($is_expired ? true : false),
                'user' => new UserResource($user),
                'access' => $this->userRepo->getAccessToken($user)
            ]);
        }
        return $this->json('Credential is invalid!', [], Response::HTTP_BAD_REQUEST);
    }

    public function signUp(SignupRequest $request)
    {
        $user = $this->userRepo->storeByRequest($request);

        $user->assignRole('user');

        if ($request->device_key) {
            (new DeviceKeyRepository())->storeByRequest($user, $request);
        }

        // EmailVerificationEvent::dispatch($user);
        return $this->json('Log In Successful', [
            'user' => new UserResource($user),
            'access' => $this->userRepo->getAccessToken($user)
        ]);
    }

    public function forgotPassword(ForgotPasswordRequest $request)
    {
        $user = (new UserRepository())->findByEmail($request->email);

        if ($user) {
            EmailVerificationEvent::dispatch($user);
        }

        // Generic response whether or not the account exists: the OTP/reset
        // token are never returned here, only delivered to the account's
        // email address by EmailVerificationListener.
        return $this->json('If the account exists, password reset instructions have been sent.');
    }

    public function otpVerify(VerifyOtpRequest $request)
    {
        $verification = (new VerificationRepository())->findByEmail($request->email);

        if ($verification && !$verification->isExpired() && $verification->otp == $request->otp) {
            return $this->json('This is your password reset token', [
                'reset_token' => $verification->token
            ]);
        }

        return $this->json('Invalid OTP');
    }

    public function resetPassword(ResetPasswordRequest $request)
    {
        $verification = (new VerificationRepository())->findByToken($request->reset_token);

        if ($verification && !$verification->isExpired()) {
            $user = (new UserRepository())->findByEmail($verification->email);
            $user->update([
                'password' => Hash::make($request->password)
            ]);

            $verification->delete();
            return $this->json('Password is reseted successfully');
        }

        // Pre-existing bug fixed here: json()'s signature is
        // (message, data, status, ...) - passing HTTP_BAD_REQUEST as the
        // second argument silently set it as $data, leaving $status at its
        // 200 default, so this branch always responded 200 despite the
        // "Invalid Request" message.
        return $this->json('Invalid Request', [], Response::HTTP_BAD_REQUEST);
    }

    public function tokenResend()
    {
        $user = auth()->user();

        if (!$user->email_verified_at) {
            $verification = (new VerificationRepository())->findOrCreate($user->email);
            EmailVerificationEvent::dispatch($user);
            // return $verification;
            return $this->json('Please check you email. We have sent a verification email.');
        }
        return $this->json('Already verified');
    }

    public function logout()
    {
        $user = auth()->user();
        if (\request()->device_key) {
            (new DeviceKeyRepository())->destroy(\request()->device_key);
        }
        if ($user) {
            $user->token()->revoke();
            return $this->json('Logged out successfully!');
        }
        return $this->json('No Logged in user found', [], Response::HTTP_UNAUTHORIZED);
    }

    private function authenticate(SigninRequest $request)
    {
        $user = $this->userRepo->findByEmail($request->email);

        if (!is_null($user) && Hash::check($request->password, $user->password)) {
            return $user;
        }

        return false;
    }

    public function socialLogin(SocialLoginRequest $request)
    {

        $user = $this->userRepo->query();
        $type = $request->type;

        if ($type) {
            $user = $user->where($type . '_id', $request->id)->first();

            if (!$user) {
                $user = $this->userRepo->storeBySocialLoginRequest($request);
            }

            return $this->json('Log In Successful', [
                'user' => new UserResource($user),
                'access' => $this->userRepo->getAccessToken($user)
            ]);
        }

        return $this->json('Invalid Type', [], Response::HTTP_BAD_REQUEST);
    }

    public function emailVerify(Request $request)
    {
        $request->validate([
            'otp' => 'required'
        ]);
        $verification = (new VerificationRepository())->findByOtp($request->otp);
        if ($verification) {
            $user = (new UserRepository())->findByEmail($verification->email);
            $user->update([
                'email_verified_at' => now()
            ]);
            $verification->delete();
            return $this->json('Email verified successfully');
        }
        return $this->json('Invalid OTP');
    }
}
