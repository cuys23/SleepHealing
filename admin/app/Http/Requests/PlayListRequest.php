<?php

namespace App\Http\Requests;

use App\Models\Albam;
use App\Models\Category;
use Illuminate\Foundation\Http\FormRequest;

class PlayListRequest extends FormRequest
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
        $audioRequired = 'required|mimes:mp3,ogg,wav';
        if (request()->routeIs('playlist.update')) {
            $audioRequired = 'nullable|mimes:mp3,ogg,wav';
        }
        return [
            'name' => 'required|string',
            'duration' => 'required',
            'category' => 'nullable|exists:' . (new Category())->getTable() . ',id',
            'albam' => 'nullable|exists:' . (new Albam())->getTable() . ',id',
            'description' => 'nullable|string',
            'thumbnail' => ['nullable', 'mimes:png,jpg,jpeg,svg,gif'],
            'audio' => $audioRequired,
            'active' => 'nullable'
        ];
    }
}
