<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\BaseRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends BaseRequest
{
    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'name' => [
                'required',
                'string',
                'max:255',
                'regex:/^[a-zA-ZüğıöçşİĞÜÖÇŞ\s]+$/'
            ],
            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                'unique:users,email'
            ],
            'password' => [
                'required',
                'string',
                'confirmed',
                Password::min(8)
                    ->letters()
                    ->mixedCase()
                    ->numbers()
                    ->symbols()
            ],
            'phone' => [
                'nullable',
                'string',
                'regex:/^(\+90|0)?[5][0-9]{9}$/'
            ],
            'identity_number' => [
                'nullable',
                'string',
                'size:11',
                'regex:/^[0-9]+$/',
                'unique:users,identity_number'
            ],
            'birth_date' => [
                'nullable',
                'date',
                'before:today'
            ],
            'gender' => [
                'nullable',
                'in:male,female,other'
            ],
            'company_id' => [
                'nullable',
                'exists:companies,id'
            ]
        ];
    }

    public function messages(): array
    {
        return array_merge(parent::messages(), [
            'name.regex' => 'İsim sadece harf ve boşluk içerebilir.',
            'phone.regex' => 'Telefon numarası geçerli bir Türkiye telefon numarası olmalıdır.',
            'identity_number.size' => 'Kimlik numarası 11 haneli olmalıdır.',
            'identity_number.regex' => 'Kimlik numarası sadece rakam içerebilir.',
            'birth_date.before' => 'Doğum tarihi bugünden önce olmalıdır.',
        ]);
    }
}