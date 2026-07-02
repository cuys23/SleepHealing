<?php

namespace App\Http\Requests;

use App\Models\DashboardCategory;
use Illuminate\Foundation\Http\FormRequest;

class DashboardCategoryRequest extends FormRequest
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
        $type = 'nullable|string';
        if (request()->routeIs('dashboardCategory.store')) {
            $type = 'required|string|unique:'.(new DashboardCategory())->getTable().',type';
        }
        return [
            'name' => 'required|string',
            'thumbnail' => 'nullable|file|mimes:png,jpg,jpeg,gif,svg',
            'type' => $type,
            'description' => 'nullable|string',
            'active' => 'nullable'
        ];
    }
}
