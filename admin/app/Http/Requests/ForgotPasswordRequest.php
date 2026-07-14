<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ForgotPasswordRequest extends FormRequest
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
        // Deliberately no exists:users,email - the controller must respond
        // identically whether or not the account exists, to avoid confirming
        // account existence via a validation error.
        return [
            'email' => 'required|email|string'
        ];
    }
}
