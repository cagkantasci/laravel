<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ControlListResource extends JsonResource
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
            'title' => $this->title,
            'description' => $this->description,
            'control_items' => $this->control_items,
            'status' => $this->status,
            'priority' => $this->priority,
            'scheduled_date' => $this->scheduled_date?->format('Y-m-d H:i:s'),
            'completed_date' => $this->completed_date?->format('Y-m-d H:i:s'),
            'approved_at' => $this->approved_at?->format('Y-m-d H:i:s'),
            'rejection_reason' => $this->rejection_reason,
            'notes' => $this->notes,
            'completion_percentage' => $this->completion_percentage,
            'priority_color' => $this->priority_color,
            'status_color' => $this->status_color,
            'is_pending' => $this->isPending(),
            'is_completed' => $this->isCompleted(),
            'is_approved' => $this->isApproved(),
            'is_rejected' => $this->isRejected(),
            'is_overdue' => $this->isOverdue(),
            'can_be_approved' => $this->canBeApproved(),
            'company' => $this->whenLoaded('company', function () {
                return [
                    'id' => $this->company->id,
                    'name' => $this->company->name,
                ];
            }),
            'machine' => $this->whenLoaded('machine', function () {
                return [
                    'id' => $this->machine->id,
                    'name' => $this->machine->name,
                    'type' => $this->machine->type,
                    'location' => $this->machine->location,
                ];
            }),
            'control_template' => $this->whenLoaded('controlTemplate', function () {
                return [
                    'id' => $this->controlTemplate->id,
                    'name' => $this->controlTemplate->name,
                    'category' => $this->controlTemplate->category,
                ];
            }),
            'user' => $this->whenLoaded('user', function () {
                return [
                    'id' => $this->user->id,
                    'name' => $this->user->name,
                ];
            }),
            'approver' => $this->whenLoaded('approver', function () {
                return [
                    'id' => $this->approver->id,
                    'name' => $this->approver->name,
                ];
            }),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
        ];
    }
}
