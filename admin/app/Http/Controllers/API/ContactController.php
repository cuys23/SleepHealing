<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\ContactRequest;
use App\Models\Contact;
use Illuminate\Http\Request;

class ContactController extends Controller
{
    public function store(ContactRequest $request)
    {
        $contact = Contact::create($request->all());
        if ($contact) {
            return response()->json([
                'success' => true,
                'message' => 'Send Successfully',
            ]);
        }
        return response()->json([
            'success' => false,
            'message' => 'Send Failed',
        ]);
    }
}
