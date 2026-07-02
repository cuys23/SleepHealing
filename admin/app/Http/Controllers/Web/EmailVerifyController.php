<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Repositories\UserRepository;
use App\Repositories\VerificationRepository;

class EmailVerifyController extends Controller
{
    public function verify($userId, $token)
    {
        $userId = decrypt($userId);
        $user = (new UserRepository())->find($userId);
        if(!$user){
            abort(404);
        }

        $verify = (new VerificationRepository())->findByEmail($user->email);

        if($verify && $verify->token === $token){
            $user->update([
                'email_verified_at' => now()
            ]);
            $verify->delete();
        }

        return view('welcome');
    }
}
