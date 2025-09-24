<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CompanyResource extends JsonResource
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
            'trade_name' => $this->trade_name,
            'tax_number' => $this->tax_number,
            'tax_office' => $this->tax_office,
            'email' => $this->email,
            'phone' => $this->phone,
            'address' => $this->address,
            'city' => $this->city,
            'district' => $this->district,
            'postal_code' => $this->postal_code,
            'website' => $this->website,
            'status' => $this->status,
            'subscription_plan' => $this->subscription_plan ? json_decode($this->subscription_plan, true) : null,
            'subscription_expires_at' => $this->subscription_expires_at?->format('Y-m-d H:i:s'),
            'settings' => $this->settings ? json_decode($this->settings, true) : null,
            'users_count' => $this->whenCounted('users'),
            'users' => $this->whenLoaded('users'),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
        ];
    }
}
