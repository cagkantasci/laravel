<?php

namespace App\Http\Requests;

use App\Http\Requests\BaseRequest;

class FileUploadRequest extends BaseRequest
{
    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'file' => [
                'required',
                'file',
                'max:10240', // 10MB max
                'mimes:jpeg,jpg,png,gif,pdf,doc,docx,xls,xlsx'
            ],
            'type' => [
                'required',
                'in:image,document,attachment'
            ],
            'description' => [
                'nullable',
                'string',
                'max:500'
            ]
        ];
    }

    public function messages(): array
    {
        return array_merge(parent::messages(), [
            'file.max' => 'Dosya boyutu 10MB\'dan büyük olamaz.',
            'file.mimes' => 'Dosya formatı desteklenmiyor. Sadece jpeg, jpg, png, gif, pdf, doc, docx, xls, xlsx dosyaları yükleyebilirsiniz.',
        ]);
    }

    /**
     * Configure the validator instance.
     */
    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            if ($this->hasFile('file')) {
                $file = $this->file('file');

                // Check file content type
                $allowedMimes = [
                    'image/jpeg', 'image/jpg', 'image/png', 'image/gif',
                    'application/pdf',
                    'application/msword',
                    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                    'application/vnd.ms-excel',
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                ];

                if (!in_array($file->getMimeType(), $allowedMimes)) {
                    $validator->errors()->add('file', 'Dosya türü güvenlik nedeniyle engellendi.');
                }

                // Check for malicious file names
                $filename = $file->getClientOriginalName();
                if (preg_match('/[<>:"|?*]/', $filename)) {
                    $validator->errors()->add('file', 'Dosya adı geçersiz karakterler içeriyor.');
                }

                // Check file signature for images
                if (in_array($file->getMimeType(), ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'])) {
                    $handle = fopen($file->getPathname(), 'rb');
                    $header = fread($handle, 10);
                    fclose($handle);

                    $signatures = [
                        'image/jpeg' => ["\xFF\xD8\xFF"],
                        'image/png' => ["\x89\x50\x4E\x47\x0D\x0A\x1A\x0A"],
                        'image/gif' => ["GIF87a", "GIF89a"]
                    ];

                    $mimeType = $file->getMimeType();
                    if (isset($signatures[$mimeType])) {
                        $valid = false;
                        foreach ($signatures[$mimeType] as $signature) {
                            if (substr($header, 0, strlen($signature)) === $signature) {
                                $valid = true;
                                break;
                            }
                        }
                        if (!$valid) {
                            $validator->errors()->add('file', 'Dosya içeriği güvenlik kontrolünden geçemedi.');
                        }
                    }
                }
            }
        });
    }
}