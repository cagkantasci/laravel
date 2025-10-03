<?php

namespace App\Http\Requests\Machine;

use App\Http\Requests\BaseRequest;
use Illuminate\Validation\Rule;

class UpdateMachineRequest extends BaseRequest
{
    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        $machineId = $this->route('machine')->id;

        return [
            'name' => [
                'sometimes',
                'string',
                'max:255'
            ],
            'type' => [
                'sometimes',
                'string',
                'in:excavator,bulldozer,crane,loader,grader,compactor,drill,pump,generator,other'
            ],
            'model' => [
                'sometimes',
                'string',
                'max:255'
            ],
            'serial_number' => [
                'sometimes',
                'string',
                'max:255',
                Rule::unique('machines', 'serial_number')->ignore($machineId)
            ],
            'manufacturer' => [
                'nullable',
                'string',
                'max:255'
            ],
            'production_date' => [
                'nullable',
                'date',
                'before_or_equal:today'
            ],
            'installation_date' => [
                'nullable',
                'date',
                'after_or_equal:production_date'
            ],
            'specifications' => [
                'nullable',
                'array'
            ],
            'specifications.engine_power' => [
                'nullable',
                'numeric',
                'min:1'
            ],
            'specifications.weight' => [
                'nullable',
                'numeric',
                'min:0.1'
            ],
            'specifications.fuel_capacity' => [
                'nullable',
                'numeric',
                'min:1'
            ],
            'status' => [
                'sometimes',
                'in:active,inactive,maintenance,out_of_service'
            ],
            'location' => [
                'nullable',
                'string',
                'max:500'
            ],
            'notes' => [
                'nullable',
                'string',
                'max:1000'
            ]
        ];
    }

    public function messages(): array
    {
        return array_merge(parent::messages(), [
            'installation_date.after_or_equal' => 'Kurulum tarihi üretim tarihinden sonra olmalıdır.',
            'production_date.before_or_equal' => 'Üretim tarihi bugünden sonra olamaz.',
            'specifications.engine_power.min' => 'Motor gücü 1 HP\'den az olamaz.',
            'specifications.weight.min' => 'Ağırlık 0.1 tondan az olamaz.',
            'specifications.fuel_capacity.min' => 'Yakıt kapasitesi 1 litreden az olamaz.',
        ]);
    }
}