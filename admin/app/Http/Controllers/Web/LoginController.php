<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Repositories\UserRepository;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cookie;
use Illuminate\Support\Facades\Hash;

class LoginController extends Controller
{
    public function index()
    {
        return view('auth.login');
    }

    public function login(LoginRequest $loginRequest)
    {
        $user = $this->isAuthenticate($loginRequest);
        $credentials = $loginRequest->only('email', 'password');

        if (!$user) {
            return redirect()->back()
                ->withErrors(['email' => ["Invalid credentials"]])
                ->withInput();
        }

        $remember = $loginRequest->remember ? true : false;
        if ($remember) {
            $time = time() + 60 * 60 * 24 * 30; // one month
            Cookie::queue('email', $loginRequest->email,$time);
            Cookie::queue('password', $loginRequest->password, $time);
        } else {
            Cookie::queue(Cookie::forget('email'));
            Cookie::queue(Cookie::forget('password'));
        }


        Auth::login($user);
        return redirect()->route('root')->with('success', 'Login Successfully');
    }

    private function isAuthenticate($loginRequest)
    {
        $user = (new UserRepository())->findByEmail($loginRequest->email);
        if (!is_null($user) && Hash::check($loginRequest->password, $user->password)) {
            return $user;
        }
        return false;
    }

    public function logout()
    {
        $user = auth()->user();
        Auth::logout($user);
        return redirect()->route('login');
    }
}
