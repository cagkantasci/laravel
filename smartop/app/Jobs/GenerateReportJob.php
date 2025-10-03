<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use App\Models\User;
use App\Services\ReportService;
use App\Services\EmailService;

class GenerateReportJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $timeout = 600; // 10 minutes for large reports
    public $tries = 1; // Reports should not be retried

    protected User $user;
    protected string $reportType;
    protected array $parameters;
    protected string $format;

    /**
     * Create a new job instance.
     */
    public function __construct(
        User $user,
        string $reportType,
        array $parameters,
        string $format = 'pdf'
    ) {
        $this->user = $user;
        $this->reportType = $reportType;
        $this->parameters = $parameters;
        $this->format = $format;
        $this->onQueue('reports');
    }

    /**
     * Execute the job.
     */
    public function handle(ReportService $reportService, EmailService $emailService): void
    {
        Log::info('Generating report', [
            'user_id' => $this->user->id,
            'report_type' => $this->reportType,
            'format' => $this->format,
            'parameters' => $this->parameters
        ]);

        try {
            // Generate the report
            $reportPath = $reportService->generate(
                $this->reportType,
                $this->parameters,
                $this->format
            );

            // Store report metadata
            $reportRecord = $reportService->createReportRecord([
                'user_id' => $this->user->id,
                'type' => $this->reportType,
                'format' => $this->format,
                'parameters' => $this->parameters,
                'file_path' => $reportPath,
                'status' => 'completed',
                'generated_at' => now()
            ]);

            // Send notification to user
            $this->notifyUserReportReady($reportRecord);

            Log::info('Report generated successfully', [
                'report_id' => $reportRecord->id,
                'file_path' => $reportPath,
                'file_size' => Storage::size($reportPath)
            ]);

        } catch (\Throwable $e) {
            Log::error('Report generation failed', [
                'user_id' => $this->user->id,
                'report_type' => $this->reportType,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            // Create failed report record
            $reportService->createReportRecord([
                'user_id' => $this->user->id,
                'type' => $this->reportType,
                'format' => $this->format,
                'parameters' => $this->parameters,
                'status' => 'failed',
                'error_message' => $e->getMessage(),
                'generated_at' => now()
            ]);

            // Notify user about failure
            $this->notifyUserReportFailed($e->getMessage());

            throw $e;
        }
    }

    /**
     * Notify user that report is ready.
     */
    protected function notifyUserReportReady($reportRecord): void
    {
        $notificationData = [
            'title' => 'Report Generated',
            'message' => "Your {$this->reportType} report is ready for download",
            'report_id' => $reportRecord->id,
            'download_url' => route('api.reports.download', $reportRecord->id),
            'expires_at' => now()->addDays(7)->toISOString(),
            'priority' => 'normal'
        ];

        SendNotificationJob::dispatch(
            $notificationData,
            'report_ready',
            [$this->user->toArray()]
        );

        // Also send email with download link
        $emailData = [
            'user_name' => $this->user->name,
            'report_type' => $this->reportType,
            'download_url' => route('api.reports.download', $reportRecord->id),
            'expires_at' => now()->addDays(7)->format('Y-m-d H:i:s')
        ];

        SendEmailJob::dispatch(
            $this->user->email,
            'Report Ready for Download',
            'emails.report-ready',
            $emailData
        );
    }

    /**
     * Notify user that report generation failed.
     */
    protected function notifyUserReportFailed(string $errorMessage): void
    {
        $notificationData = [
            'title' => 'Report Generation Failed',
            'message' => "Failed to generate your {$this->reportType} report",
            'error' => $errorMessage,
            'support_contact' => config('app.support_email'),
            'priority' => 'high'
        ];

        SendNotificationJob::dispatch(
            $notificationData,
            'report_failed',
            [$this->user->toArray()]
        );
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error('Report generation job permanently failed', [
            'user_id' => $this->user->id,
            'report_type' => $this->reportType,
            'error' => $exception->getMessage()
        ]);
    }

    /**
     * Get the tags that should be assigned to the job.
     */
    public function tags(): array
    {
        return [
            'report',
            'type:' . $this->reportType,
            'format:' . $this->format,
            'user:' . $this->user->id
        ];
    }
}