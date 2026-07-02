<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SubscriptionPlanRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, mixed>
     */
    public function rules()
    {
        return [
            'name' => 'required|string',
            'amount' => 'required|numeric|digits_between:1,6',
            'duration' => 'required|integer',
            'thumbnail' => 'nullable|file|mimes:png,jpg,jpeg,gif,svg',
            'feature_1' => 'required|string',
            'feature_2' => 'required|string',
            'feature_3' => 'required|string',
            'feature_4' => 'required|string',
            'is_recommended' => 'required|boolean',
        ];
    }
}
