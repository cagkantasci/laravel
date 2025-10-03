<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class RealTimeNotification implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public int $userId;
    public string $type;
    public string $title;
    public string $message;
    public array $data;
    public string $priority;

    /**
     * Create a new event instance.
     */
    public function __construct(
        int $userId,
        string $type,
        string $title,
        string $message,
        array $data = [],
        string $priority = 'normal'
    ) {
        $this->userId = $userId;
        $this->type = $type;
        $this->title = $title;
        $this->message = $message;
        $this->data = $data;
        $this->priority = $priority;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('user.' . $this->userId),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'notification.received';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'notification' => [
                'type' => $this->type,
                'title' => $this->title,
                'message' => $this->message,
                'priority' => $this->priority,
                'data' => $this->data,
                'timestamp' => now()->toISOString(),
            ]
        ];
    }
}