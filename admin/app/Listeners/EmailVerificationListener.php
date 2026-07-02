<?php

namespace App\Listeners;

use Illuminate\Support\Facades\Mail;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;

class EmailVerificationListener implements ShouldQueue
{
    use InteractsWithQueue;

    /**
     * Create the event listener.
     *
     * @return void
     */
    public function __construct()
    {
        //
    }

    /**
     * Handle the event.
     *
     * @param  object  $event
     * @return void
     */
    public function handle($event)
    {
        $user = $event->user;
        $email = $user->email;
        $verification = $event->verification;

        if(\request()->routeIs('forgot.password')){
            Mail::send('email.forgot-password', compact('verification', 'user'), function ($message) use($email){
                $message->from(app('config')->get('mail.from.address'), config('app.name'))
                        ->to($email)
                        ->subject('Verification');
            });
        }else{
            Mail::send('email.email-verify', compact('verification', 'user'), function ($message) use($email){
                $message->from(app('config')->get('mail.from.address'), config('app.name'))
                        ->to($email)
                        ->subject('Verification');
            });
        }
    }
}
