<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\SettingRequest;
use App\Models\WebSetting;
use App\Repositories\MediaRepository;

class WebSettingController extends Controller
{
    private $path = 'images/webs/';
    private $uploadPath = 'web/images/';
    public function index()
    {
        $websetting = WebSetting::first();
        return view('web-setting', compact('websetting'));
    }

    public function update(SettingRequest $request,WebSetting $webSetting)
    {

        $logo = $this->logoCreateOrUpdate($request, $webSetting);
        $favIcon = $this->favIconCreateOrUpdate($request, $webSetting);

        $signature = $this->SignatureUpdate($request, $webSetting);
        WebSetting::updateOrCreate(
            [
                'id' => $webSetting ? $webSetting->id : 0,
            ],
            [
                'name' => $request->name,
                'title' => $request->title,
                'theme_name' => $request->theme_name,
                'subtitle' => $request->subtitle,
                'signature_id' => $signature ? $signature->id : null,
                'address' => $request->address,
                'mobile' => $request->mobile,
                'email' => $request->email,
                'active_subscription' => $request->active_subscription,
                'logo_id' => $logo->id ?? null,
                'favicon_id' => $favIcon->id ?? null
        ]);

        return back()->with('success', 'Update Successfully');
    }

    private function WebLogoAndFaviconUpdate($requestFile, $imageName)
    {
        unlink($this->uploadPath.$imageName);
        $requestFile->move($this->uploadPath,$imageName);
    }

    private function SignatureUpdate($request, $webSetting)
    {
        $thumbnail = $webSetting->signature;
        if ($request->hasFile('signature')) {
            $thumbnail = (new MediaRepository())->updateByRequest(
                $request->signature,
                $thumbnail,
                $this->path
            );
        }
        return $thumbnail;
    }

    private function logoCreateOrUpdate($request, $webSetting)
    {
        $thumbnail = $webSetting->logo;
        if ($request->hasFile('logo')) {
            $thumbnail = (new MediaRepository())->updateOrCreateByRequest(
                $request->logo,
                $thumbnail,
                $this->path
            );
        }
        return $thumbnail;
    }

    private function favIconCreateOrUpdate($request, $webSetting)
    {
        $thumbnail = $webSetting->favIcon;
        if ($request->hasFile('fav_icon')) {
            $thumbnail = (new MediaRepository())->updateOrCreateByRequest(
                $request->fav_icon,
                $thumbnail,
                $this->path
            );
        }
        return $thumbnail;
    }

    public function toggle(WebSetting $webSetting)
    {
        WebSetting::updateOrCreate(
            [
                'id' => $webSetting ? $webSetting->id : 0,
            ],
            [
                'name' => $webSetting->name ?? 'Maditam',
                'subscription' => $webSetting->subscription ? !$webSetting->subscription : true,
        ]);

        return redirect()->back()->with('success', 'Update Successfully');
    }

    public function AdsToggle(WebSetting $webSetting)
    {
        WebSetting::updateOrCreate(
            [
                'id' => $webSetting ? $webSetting->id : 0,
            ],
            [
                'name' => $webSetting->name ?? 'Maditam',
                'ads_show' => $webSetting->ads_show ? !$webSetting->ads_show : true,
        ]);

        return redirect()->back()->with('success', 'Update Successfully');
    }
}
