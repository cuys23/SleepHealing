<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Albam;
use App\Models\Category;
use App\Models\PlayList;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;

class DashboardController extends Controller
{
    public function index()
    {
        $users = User::role('user')->count();
        $categories = Category::query()->count();
        $albams = Albam::query()->count();
        $playLists = PlayList::query()->count();


        $week_user = User::whereBetween('created_at', [Carbon::now()->startOfWeek(), Carbon::now()->endOfWeek()])->get();
        $totalWeekUser = [];
        foreach ($week_user as $user) {
            $totalWeekUser[$user->created_at->format('d/m/Y')] = $total = User::whereDate('created_at', '=', $user->created_at->format('Y-m-d'))->count();
        }

        $week_category = [];
        $week_number = [];
        foreach ($totalWeekUser as $key => $value) {
            $week_category[] = $key;
            $week_number[] = $value;
        }

        $latest_users = User::role('user')->latest('id')->take(10)->get();
        $latest_category = Category::latest('id')->take(10)->get();
        $latest_playlist = PlayList::latest('id')->take(10)->get();



        return view('admin.index', compact('users', 'categories', 'albams', 'playLists', 'week_category', 'week_number', 'latest_users', 'latest_category', 'latest_playlist'));
    }
}
