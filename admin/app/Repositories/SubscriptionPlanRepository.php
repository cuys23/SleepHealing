<?php

namespace App\Repositories;

use App\Http\Requests\SubscriptionPlanRequest;
use App\Models\SubscriptionPlan;

class SubscriptionPlanRepository extends Repository {

    /**
     * base method
     *
     * @method model()
     */
    public $path = 'images/subscriptionPlan/';
    public function model()
    {
        return SubscriptionPlan::class;
    }

    public function getAll()
    {
        return $this->model()::paginate(10);
    }

    public function storeByRequest(SubscriptionPlanRequest $request): SubscriptionPlan
    {
        $thumbnail = null;
        if ($request->hasFile('thumbnail')) {
            $thumbnail = (new MediaRepository())->storeByRequest(
                $request->thumbnail,
                $this->path,
                'image'
            );
        }
        return $this->model()::create([
            'name' => $request->name,
            'duration' => $request->duration,
            'amount' => $request->amount,
            'feature_1' => $request->feature_1,
            'feature_2' => $request->feature_2,
            'feature_3' => $request->feature_3,
            'feature_4' => $request->feature_4,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'status' => $request->active ? true : false,
            'is_recommended' => $request->is_recommended ? true : false

        ]);
    }

    public function updateByRequest(SubscriptionPlanRequest $request, SubscriptionPlan $subscriptionplan): SubscriptionPlan
    {
        $thumbnail = $this->thumbnailUpdate($request, $subscriptionplan);
        $subscriptionplan->update([
            'name' => $request->name,
            'duration' => $request->duration,
            'amount' => $request->amount,
            'feature_1' => $request->feature_1,
            'feature_2' => $request->feature_2,
            'feature_3' => $request->feature_3,
            'feature_4' => $request->feature_4,
            'media_id' => $thumbnail ? $thumbnail->id : null,
            'status' => $request->active ? true : false,
            'is_recommended' => $request->is_recommended ? true : false
        ]);
        return $subscriptionplan;
    }

    private function thumbnailUpdate($request, $subscriptionplan)
    {
        $thumbnail = $subscriptionplan->media;
        if ($request->hasFile('thumbnail') && $thumbnail == null) {
            $thumbnail = (new MediaRepository())->storeByRequest(
                $request->thumbnail,
                $this->path,
                'image'
            );
        }

        if ($request->hasFile('thumbnail') && $thumbnail) {
            $thumbnail = (new MediaRepository())->updateByRequest(
                $request->thumbnail,
                $thumbnail,
                $this->path,
                'image',
            );
        }

        return $thumbnail;
    }
}
