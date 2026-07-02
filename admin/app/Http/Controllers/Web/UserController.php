<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use App\Repositories\UserRepository;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index()
    {
        $users = (new UserRepository())->getAll();
        return view('user.index', compact('users'));
    }

    public function toggle(User $user)
    {
        $user->update([
            'status' => !$user->status
        ]);
        return back()->with('success', 'Status Update Successfully');
    }

    public function show(User $user)
    {
        return view('user.show', compact('user'));
    }

    public function edit(User $user)
    {
        $subscriptions = SubscriptionPlan::all();
        return view('user.edit', compact('user', 'subscriptions'));
    }

    public function update(Request $request, User $user)
    {
        $request->validate([
            'name' => 'required',
            'email' => 'required|unique:users,email,' . $user->id
        ]);
        if (!$request->subscription) {
            $user->subscriptions()->delete();
        }
        (new UserRepository())->updateByRequest($request, $user);
        return back()->with('success', 'Update Successfully');
    }

    public function delete(User $user)
    {
        $user->subscriptions()?->delete();
        $user->favorites()?->delete();
        $user->delete();
        return back()->with('success', 'Deleted Successfully');
    }
}
