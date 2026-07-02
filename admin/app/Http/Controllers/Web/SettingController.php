<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use App\Repositories\SettingRepository;
use Illuminate\Http\Request;

class SettingController extends Controller
{
    private $settingRepo;
    public function __construct(SettingRepository $settingRepository)
    {
        $this->settingRepo = $settingRepository;
    }

    public function show($slug)
    {
        $setting = $this->settingRepo->findBySlug($slug);

        return view('settings.index', compact('setting'));
    }

    public function edit($slug)
    {
        $setting = $this->settingRepo->findBySlug($slug);

        return view('settings.edit', compact('setting'));
    }

    public function update(Request $request, Setting $setting)
    {
        $request->validate([
            'content' => 'required',
            'title' => 'required',
        ]);
        
        $this->settingRepo->updateByRequest($request, $setting);

        return back()->with('success', 'Updated Successfully!');
    }
}
