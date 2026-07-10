<?php

namespace App\Http\Requests;

use App\Models\Albam;
use App\Models\Category;
use App\Rules\ValidAudioDuration;
use Illuminate\Foundation\Http\FormRequest;

class PlayListRequest extends FormRequest
{
    private ValidAudioDuration $audioDurationRule;

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
        $this->audioDurationRule = new ValidAudioDuration();

        $audioRequired = ['bail', 'required', 'mimes:mp3,ogg,wav'];
        if (request()->routeIs('playlist.update')) {
            $audioRequired = ['bail', 'nullable', 'mimes:mp3,ogg,wav'];
        }
        return [
            'name' => 'required|string',
            'category' => 'nullable|exists:' . (new Category())->getTable() . ',id',
            'albam' => 'nullable|exists:' . (new Albam())->getTable() . ',id',
            'description' => 'nullable|string',
            'thumbnail' => ['nullable', 'mimes:png,jpg,jpeg,svg,gif'],
            'audio' => [...$audioRequired, $this->audioDurationRule],
            'active' => 'nullable'
        ];
    }

    /**
     * The duration ffprobe detected while validating the "audio" field.
     * Null when no new audio file was submitted. Guaranteed non-null when
     * hasFile('audio') is true, since validation would otherwise have
     * failed before the controller/repository ever ran.
     */
    public function detectedAudioDuration(): ?int
    {
        return $this->audioDurationRule->detectedDuration();
    }
}
