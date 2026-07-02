<?php

namespace App\Http\Requests;

use App\Models\Category;
use Illuminate\Foundation\Http\FormRequest;

class AlbamRequest extends FormRequest
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
            'category' => 'nullable|exists:'.(new Category())->getTable().',id',
            'thumbnail' => 'nullable|file|mimes:png,jpg,jpeg,gif,svg',
            'description' => 'nullable|string',
            'active' => 'nullable'
        ];
    }
}
