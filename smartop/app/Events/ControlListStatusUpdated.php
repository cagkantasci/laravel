<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use App\Models\ControlList;

class ControlListStatusUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public ControlList $controlList;
    public string $oldStatus;
    public string $newStatus;
    public ?int $updatedBy;
    public array $metadata;

    /**
     * Create a new event instance.
     */
    public function __construct(
        ControlList $controlList,
        string $oldStatus,
        string $newStatus,
        ?int $updatedBy = null,
        array $metadata = []
    ) {
        $this->controlList = $controlList;
        $this->oldStatus = $oldStatus;
        $this->newStatus = $newStatus;
        $this->updatedBy = $updatedBy;
        $this->metadata = $metadata;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('company.' . $this->controlList->company_id),
            new PrivateChannel('machine.' . $this->controlList->machine_id),
            new PrivateChannel('user.' . $this->controlList->user_id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'control-list.status.updated';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'control_list' => [
                'id' => $this->controlList->id,
                'uuid' => $this->controlList->uuid,
                'title' => $this->controlList->title,
                'machine_id' => $this->controlList->machine_id,
                'user_id' => $this->controlList->user_id,
                'company_id' => $this->controlList->company_id,
                'old_status' => $this->oldStatus,
                'new_status' => $this->newStatus,
                'priority' => $this->controlList->priority,
                'completion_percentage' => $this->controlList->completion_percentage,
            ],
            'updated_by' => $this->updatedBy,
            'metadata' => $this->metadata,
            'timestamp' => now()->toISOString(),
            'event_type' => 'control_list_status_updated'
        ];
    }

    /**
     * Determine if this event should broadcast.
     */
    public function shouldBroadcast(): bool
    {
        return $this->oldStatus !== $this->newStatus;
    }
}