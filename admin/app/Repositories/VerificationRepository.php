<?php

namespace App\Repositories;

use App\Models\Verification;

class VerificationRepository extends Repository {

    /**
     * base method
     *
     * @method model()
     */
    public function model()
    {
        return Verification::class;
    }

    public function findOrCreate($email)
    {
        return $this->query()->updateOrCreate([
            'email' => $email
        ],[
            'otp' => $this->generateUniqueOtp(),
            'token' => $this->generateUniqueToken()
        ]);
    }

    public function findByEmail($email)
    {
        return $this->query()->where('email', $email)->first();
    }

    public function findByToken($token)
    {
        return $this->query()->where('token', $token)->first();
    }

    private function generateUniqueOtp(): int
    {
        do {
            $otp = mt_rand(123400, 999999);
        } while ($this->query()->where('otp', $otp)->exists());

        return $otp;
    }

    private function generateUniqueToken()
    {
        do {
            $token = $this->generateToken();
        } while ($this->query()->where('token', $token)->exists());

        return $token;
    }

    private function generateToken()
    {
        return hash_hmac(
            'sha256',
            uniqid(rand(100000000, 100000000000000), true),
            substr(md5(mt_rand()), 500000000, 700000000000)
        );
    }

    public function findByOtp($otp)
    {
        return $this->query()->where('otp', $otp)->first();
    }

}
