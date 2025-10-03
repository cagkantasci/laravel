<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Contracts\Validation\Validator;

abstract class BaseRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Handle a failed validation attempt.
     */
    protected function failedValidation(Validator $validator)
    {
        $errors = $validator->errors()->toArray();

        throw new HttpResponseException(
            response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $errors,
                'data' => null
            ], 422)
        );
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'required' => ':attribute alanı zorunludur.',
            'email' => ':attribute geçerli bir email adresi olmalıdır.',
            'min' => ':attribute en az :min karakter olmalıdır.',
            'max' => ':attribute en fazla :max karakter olmalıdır.',
            'unique' => ':attribute zaten kullanılmaktadır.',
            'exists' => 'Seçilen :attribute geçersizdir.',
            'in' => 'Seçilen :attribute geçersizdir.',
            'numeric' => ':attribute sayı olmalıdır.',
            'date' => ':attribute geçerli bir tarih olmalıdır.',
            'image' => ':attribute resim dosyası olmalıdır.',
            'mimes' => ':attribute :values formatında olmalıdır.',
            'max_file' => ':attribute dosyası en fazla :max KB olmalıdır.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'name' => 'İsim',
            'email' => 'E-posta',
            'password' => 'Şifre',
            'phone' => 'Telefon',
            'company_id' => 'Şirket',
            'machine_id' => 'Makine',
            'status' => 'Durum',
            'priority' => 'Öncelik',
            'title' => 'Başlık',
            'description' => 'Açıklama',
            'type' => 'Tip',
            'model' => 'Model',
            'serial_number' => 'Seri Numarası',
            'manufacturer' => 'Üretici',
        ];
    }
}