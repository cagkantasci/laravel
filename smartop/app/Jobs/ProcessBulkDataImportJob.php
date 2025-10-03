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
use App\Services\ImportService;

class ProcessBulkDataImportJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $timeout = 1800; // 30 minutes for large imports
    public $tries = 1;

    protected User $user;
    protected string $filePath;
    protected string $importType;
    protected array $options;

    /**
     * Create a new job instance.
     */
    public function __construct(
        User $user,
        string $filePath,
        string $importType,
        array $options = []
    ) {
        $this->user = $user;
        $this->filePath = $filePath;
        $this->importType = $importType;
        $this->options = $options;
        $this->onQueue('imports');
    }

    /**
     * Execute the job.
     */
    public function handle(ImportService $importService): void
    {
        Log::info('Processing bulk data import', [
            'user_id' => $this->user->id,
            'file_path' => $this->filePath,
            'import_type' => $this->importType
        ]);

        $importRecord = null;

        try {
            // Create import record
            $importRecord = $importService->createImportRecord([
                'user_id' => $this->user->id,
                'file_path' => $this->filePath,
                'type' => $this->importType,
                'status' => 'processing',
                'options' => $this->options,
                'started_at' => now()
            ]);

            // Validate file
            $this->validateFile();

            // Process the import
            $result = $importService->processImport(
                $this->filePath,
                $this->importType,
                $this->options,
                [$this, 'updateProgress']
            );

            // Update import record with results
            $importRecord->update([
                'status' => 'completed',
                'total_records' => $result['total'],
                'successful_records' => $result['successful'],
                'failed_records' => $result['failed'],
                'errors' => $result['errors'] ?? [],
                'completed_at' => now()
            ]);

            // Notify user of completion
            $this->notifyUserImportCompleted($importRecord, $result);

            Log::info('Bulk import completed successfully', [
                'import_id' => $importRecord->id,
                'total' => $result['total'],
                'successful' => $result['successful'],
                'failed' => $result['failed']
            ]);

        } catch (\Throwable $e) {
            Log::error('Bulk import failed', [
                'user_id' => $this->user->id,
                'file_path' => $this->filePath,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            // Update import record with failure
            if ($importRecord) {
                $importRecord->update([
                    'status' => 'failed',
                    'error_message' => $e->getMessage(),
                    'completed_at' => now()
                ]);
            }

            // Notify user of failure
            $this->notifyUserImportFailed($e->getMessage());

            throw $e;

        } finally {
            // Clean up the uploaded file
            if (Storage::exists($this->filePath)) {
                Storage::delete($this->filePath);
            }
        }
    }

    /**
     * Validate the import file.
     */
    protected function validateFile(): void
    {
        if (!Storage::exists($this->filePath)) {
            throw new \Exception('Import file not found');
        }

        $fileSize = Storage::size($this->filePath);
        $maxSize = config('import.max_file_size', 50 * 1024 * 1024); // 50MB default

        if ($fileSize > $maxSize) {
            throw new \Exception('Import file too large');
        }

        $mimeType = Storage::mimeType($this->filePath);
        $allowedTypes = [
            'text/csv',
            'application/vnd.ms-excel',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        ];

        if (!in_array($mimeType, $allowedTypes)) {
            throw new \Exception('Invalid file type');
        }
    }

    /**
     * Update import progress (callback for ImportService).
     */
    public function updateProgress(int $processed, int $total): void
    {
        $percentage = $total > 0 ? round(($processed / $total) * 100, 2) : 0;

        Log::info('Import progress', [
            'processed' => $processed,
            'total' => $total,
            'percentage' => $percentage
        ]);

        // Optionally broadcast progress to user via WebSocket
        // broadcast(new ImportProgressEvent($this->user->id, $percentage));
    }

    /**
     * Notify user that import completed.
     */
    protected function notifyUserImportCompleted($importRecord, array $result): void
    {
        $notificationData = [
            'title' => 'Import Completed',
            'message' => "Your {$this->importType} import has been completed",
            'import_id' => $importRecord->id,
            'total_records' => $result['total'],
            'successful_records' => $result['successful'],
            'failed_records' => $result['failed'],
            'priority' => 'normal'
        ];

        SendNotificationJob::dispatch(
            $notificationData,
            'import_completed',
            [$this->user->toArray()]
        );

        // Send detailed email report
        $emailData = [
            'user_name' => $this->user->name,
            'import_type' => $this->importType,
            'result' => $result,
            'import_record' => $importRecord
        ];

        SendEmailJob::dispatch(
            $this->user->email,
            'Import Completed - ' . ucfirst($this->importType),
            'emails.import-completed',
            $emailData
        );
    }

    /**
     * Notify user that import failed.
     */
    protected function notifyUserImportFailed(string $errorMessage): void
    {
        $notificationData = [
            'title' => 'Import Failed',
            'message' => "Your {$this->importType} import has failed",
            'error' => $errorMessage,
            'support_contact' => config('app.support_email'),
            'priority' => 'high'
        ];

        SendNotificationJob::dispatch(
            $notificationData,
            'import_failed',
            [$this->user->toArray()]
        );
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error('Import job permanently failed', [
            'user_id' => $this->user->id,
            'file_path' => $this->filePath,
            'error' => $exception->getMessage()
        ]);
    }

    /**
     * Get the tags that should be assigned to the job.
     */
    public function tags(): array
    {
        return [
            'import',
            'type:' . $this->importType,
            'user:' . $this->user->id
        ];
    }
}