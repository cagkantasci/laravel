<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use App\Services\NotificationService;

class SendNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $timeout = 120;
    public $tries = 3;
    public $backoff = [60, 120, 300]; // Retry delays in seconds

    protected array $notificationData;
    protected string $notificationType;
    protected array $recipients;

    /**
     * Create a new job instance.
     */
    public function __construct(
        array $notificationData,
        string $notificationType,
        array $recipients
    ) {
        $this->notificationData = $notificationData;
        $this->notificationType = $notificationType;
        $this->recipients = $recipients;

        // Set queue based on priority
        $priority = $notificationData['priority'] ?? 'normal';
        $this->onQueue($this->getQueueByPriority($priority));
    }

    /**
     * Execute the job.
     */
    public function handle(NotificationService $notificationService): void
    {
        Log::info('Processing notification job', [
            'type' => $this->notificationType,
            'recipients_count' => count($this->recipients),
            'data' => $this->notificationData
        ]);

        try {
            foreach ($this->recipients as $recipient) {
                $notificationService->send(
                    $recipient,
                    $this->notificationType,
                    $this->notificationData
                );
            }

            Log::info('Notification job completed successfully', [
                'type' => $this->notificationType,
                'recipients_count' => count($this->recipients)
            ]);

        } catch (\Throwable $e) {
            Log::error('Notification job failed', [
                'type' => $this->notificationType,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            throw $e;
        }
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error('Notification job permanently failed', [
            'type' => $this->notificationType,
            'recipients_count' => count($this->recipients),
            'error' => $exception->getMessage(),
            'attempts' => $this->attempts()
        ]);

        // Optionally notify administrators about the failure
        // NotificationService::notifyAdmins('job_failed', [...]);
    }

    /**
     * Get queue name based on priority.
     */
    protected function getQueueByPriority(string $priority): string
    {
        return match ($priority) {
            'critical' => 'notifications-critical',
            'high' => 'notifications-high',
            'low' => 'notifications-low',
            default => 'notifications'
        };
    }

    /**
     * Get the tags that should be assigned to the job.
     */
    public function tags(): array
    {
        return [
            'notification',
            'type:' . $this->notificationType,
            'recipients:' . count($this->recipients)
        ];
    }
}