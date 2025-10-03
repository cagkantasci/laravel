<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use App\Models\Machine;

class MachineStatusChanged implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Machine $machine;
    public string $oldStatus;
    public string $newStatus;
    public array $metadata;

    /**
     * Create a new event instance.
     */
    public function __construct(
        Machine $machine,
        string $oldStatus,
        string $newStatus,
        array $metadata = []
    ) {
        $this->machine = $machine;
        $this->oldStatus = $oldStatus;
        $this->newStatus = $newStatus;
        $this->metadata = $metadata;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('company.' . $this->machine->company_id),
            new PrivateChannel('machine.' . $this->machine->id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'machine.status.changed';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'machine' => [
                'id' => $this->machine->id,
                'uuid' => $this->machine->uuid,
                'name' => $this->machine->name,
                'type' => $this->machine->type,
                'serial_number' => $this->machine->serial_number,
                'old_status' => $this->oldStatus,
                'new_status' => $this->newStatus,
                'company_id' => $this->machine->company_id,
            ],
            'metadata' => $this->metadata,
            'timestamp' => now()->toISOString(),
            'event_type' => 'machine_status_changed'
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