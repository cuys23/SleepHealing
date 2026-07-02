<?php

namespace App\Http\Controllers;

use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;

class MailConfigurationController extends Controller
{
    public function index()
    {
        return view('mail-config');
    }

    public function update(Request $request)
    {
        try {
            $this->setEnv('MAIL_MAILER', $request->mailer);
            $this->setEnv('MAIL_HOST', $request->host);
            $this->setEnv('MAIL_PORT', $request->port);
            $this->setEnv('MAIL_USERNAME', $request->username);
            $this->setEnv('MAIL_PASSWORD', $request->password);
            $this->setEnv('MAIL_ENCRYPTION', $request->encryption);
            $this->setEnv('MAIL_FROM_ADDRESS', $request->from_address);

            Artisan::call('config:clear');
            Artisan::call('config:cache');

            return back()->with('success', 'Mail configuration is setuped successful.');
        } catch (Exception $e) {
            return back()->with('error', $e->getMessage());
        }

    }
}
