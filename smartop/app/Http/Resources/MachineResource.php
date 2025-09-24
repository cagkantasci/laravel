<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MachineResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'uuid' => $this->uuid,
            'name' => $this->name,
            'type' => $this->type,
            'model' => $this->model,
            'serial_number' => $this->serial_number,
            'manufacturer' => $this->manufacturer,
            'production_date' => $this->production_date?->format('Y-m-d'),
            'installation_date' => $this->installation_date?->format('Y-m-d'),
            'specifications' => $this->specifications,
            'status' => $this->status,
            'location' => $this->location,
            'qr_code' => $this->qr_code,
            'notes' => $this->notes,
            'full_name' => $this->full_name,
            'is_active' => $this->isActive(),
            'company' => $this->whenLoaded('company', function () {
                return [
                    'id' => $this->company->id,
                    'name' => $this->company->name,
                ];
            }),
            'control_lists_count' => $this->whenCounted('controlLists'),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
        ];
    }
}
