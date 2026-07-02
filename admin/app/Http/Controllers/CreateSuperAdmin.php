<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class CreateSuperAdmin extends Controller
{
    public function index()
    {
        return view('create-root');
    }

    public function store(Request $request)
    {
        $request->validate([
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:8|confirmed',
        ]);

        // Admin User
        $user = User::factory()->create([
                'email' => $request->email,
                'name' => 'Administrator',
                'status' => true,
                'email_verified_at' => now(),
                'password' => bcrypt($request->password),
            ]);

        $user->assignRole('root');

        // Redirect to the dashboard or any other page
        return redirect()->route('root')->with('success', 'You are ready to use ReadyLMS! Please login with your credentials.');
    }
}
