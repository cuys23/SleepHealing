<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\ChangePasswordRequest;
use App\Http\Requests\UserRequest;
use App\Repositories\UserRepository;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
   public function index()
   {
     $user = auth()->user();
     return view('profile.index', compact('user'));
   }

   public function edit()
   {
        $user = auth()->user();
        return view('profile.edit',compact('user'));
   }
   public function update(Request $request)
   {
        $user = auth()->user();
        $request->validate([
            'name' => 'required|string',
            'email' => ['required', 'email', "unique:users,email,$user->id"],
            'profile_photo' => 'nullable|image|mimes:jpg,jpeg,png,gif,svg'
        ]);
        (new UserRepository())->updateByRequest($request,$user);
        return redirect()->route('profile.index')->with('success','profile update successfully');
   }

   public function showChangePassword()
   {
        return view('profile.change-password');
   }

   public function changePassword(ChangePasswordRequest $request)
   {
        $user = auth()->user();
        if (!Hash::check($request->current_password,$user->password)) {
            return redirect()->back()->with('error','You have entered wrong password');
        }
        $user->update([
            'password' => Hash::make($request->password)
        ]);
        return redirect()->route('profile.index')->with('success','password change successfully');
   }
}
