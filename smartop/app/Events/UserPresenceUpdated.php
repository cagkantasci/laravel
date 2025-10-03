<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use App\Models\User;

class UserPresenceUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public User $user;
    public string $status; // online, offline, away
    public array $metadata;

    /**
     * Create a new event instance.
     */
    public function __construct(User $user, string $status, array $metadata = [])
    {
        $this->user = $user;
        $this->status = $status;
        $this->metadata = $metadata;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        return [
            new PresenceChannel('company.' . $this->user->company_id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'user.presence.updated';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'user' => [
                'id' => $this->user->id,
                'name' => $this->user->name,
                'email' => $this->user->email,
                'status' => $this->status,
                'last_seen' => now()->toISOString(),
                'roles' => $this->user->roles->pluck('name'),
            ],
            'metadata' => $this->metadata,
            'timestamp' => now()->toISOString(),
            'event_type' => 'user_presence_updated'
        ];
    }
}