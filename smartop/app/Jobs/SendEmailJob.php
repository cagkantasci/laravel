<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use App\Mail\GenericEmail;

class SendEmailJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $timeout = 60;
    public $tries = 3;
    public $backoff = [30, 60, 120];

    protected string $to;
    protected string $mailableClass;
    protected array $data;
    protected string $type;

    /**
     * Create a new job instance.
     */
    public function __construct(
        string $to,
        string $mailableClass,
        array $data = [],
        string $type = 'general'
    ) {
        $this->to = $to;
        $this->mailableClass = $mailableClass;
        $this->data = $data;
        $this->type = $type;
        $this->onQueue($this->getQueueForType($type));
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        try {
            if (!class_exists($this->mailableClass)) {
                throw new \Exception("Mailable class {$this->mailableClass} does not exist");
            }

            $mailable = new $this->mailableClass($this->data);
            Mail::to($this->to)->send($mailable);

            Log::info('Email sent successfully', [
                'to' => $this->to,
                'mailable' => $this->mailableClass,
                'type' => $this->type
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to send email', [
                'to' => $this->to,
                'mailable' => $this->mailableClass,
                'type' => $this->type,
                'error' => $e->getMessage(),
                'attempt' => $this->attempts()
            ]);

            throw $e;
        }
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error('Email job permanently failed', [
            'to' => $this->to,
            'mailable' => $this->mailableClass,
            'type' => $this->type,
            'error' => $exception->getMessage(),
            'attempts' => $this->attempts()
        ]);
    }

    /**
     * Get queue for email type.
     */
    private function getQueueForType(string $type): string
    {
        return match ($type) {
            'emergency' => 'high-priority',
            'machine_status', 'control_list' => 'notifications',
            'reports' => 'reports',
            'invitations', 'welcome' => 'user-management',
            default => 'emails'
        };
    }

    /**
     * Get the tags that should be assigned to the job.
     */
    public function tags(): array
    {
        return [
            'email',
            'type:' . $this->type,
            'mailable:' . class_basename($this->mailableClass)
        ];
    }
}