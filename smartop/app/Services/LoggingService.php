<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Machine;
use App\Models\ControlList;

class LoggingService
{
    /**
     * Log user authentication.
     */
    public function logAuthentication(User $user, string $action, Request $request): void
    {
        $this->logActivity([
            'type' => 'authentication',
            'action' => $action,
            'user_id' => $user->id,
            'user_email' => $user->email,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'timestamp' => now(),
            'context' => [
                'company_id' => $user->company_id,
                'roles' => $user->roles->pluck('name')->toArray(),
            ]
        ]);
    }

    /**
     * Log machine operations.
     */
    public function logMachineOperation(
        Machine $machine,
        string $action,
        ?User $user = null,
        array $context = []
    ): void {
        $this->logActivity([
            'type' => 'machine_operation',
            'action' => $action,
            'machine_id' => $machine->id,
            'machine_code' => $machine->machine_code,
            'user_id' => $user?->id,
            'user_email' => $user?->email,
            'timestamp' => now(),
            'context' => array_merge([
                'company_id' => $machine->company_id,
                'machine_type' => $machine->machine_type,
                'location' => $machine->location,
                'previous_status' => $context['previous_status'] ?? null,
                'new_status' => $context['new_status'] ?? $machine->status,
            ], $context)
        ]);
    }

    /**
     * Log control list operations.
     */
    public function logControlListOperation(
        ControlList $controlList,
        string $action,
        ?User $user = null,
        array $context = []
    ): void {
        $this->logActivity([
            'type' => 'control_list_operation',
            'action' => $action,
            'control_list_id' => $controlList->id,
            'machine_id' => $controlList->machine_id,
            'machine_code' => $controlList->machine->machine_code,
            'user_id' => $user?->id,
            'user_email' => $user?->email,
            'timestamp' => now(),
            'context' => array_merge([
                'company_id' => $controlList->machine->company_id,
                'assigned_user_id' => $controlList->assigned_user_id,
                'status' => $controlList->status,
                'priority' => $controlList->priority,
                'due_date' => $controlList->due_date?->toISOString(),
            ], $context)
        ]);
    }

    /**
     * Log security events.
     */
    public function logSecurityEvent(
        string $event,
        string $severity,
        Request $request,
        ?User $user = null,
        array $context = []
    ): void {
        $logData = [
            'type' => 'security',
            'event' => $event,
            'severity' => $severity,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'url' => $request->fullUrl(),
            'method' => $request->method(),
            'timestamp' => now(),
            'context' => array_merge([
                'user_id' => $user?->id,
                'user_email' => $user?->email,
                'company_id' => $user?->company_id,
                'headers' => $this->sanitizeHeaders($request->headers->all()),
            ], $context)
        ];

        $this->logActivity($logData);

        // Also log to security channel for high-severity events
        if (in_array($severity, ['high', 'critical'])) {
            Log::channel('security')->warning('Security event detected', $logData);
        }
    }

    /**
     * Log API requests.
     */
    public function logApiRequest(
        Request $request,
        $response,
        float $duration,
        ?User $user = null
    ): void {
        $statusCode = is_object($response) ? $response->getStatusCode() : $response;

        $logData = [
            'type' => 'api_request',
            'method' => $request->method(),
            'url' => $request->fullUrl(),
            'status_code' => $statusCode,
            'duration_ms' => round($duration * 1000, 2),
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'user_id' => $user?->id,
            'timestamp' => now(),
            'context' => [
                'company_id' => $user?->company_id,
                'endpoint' => $request->route()?->uri(),
                'response_size' => is_object($response) ? strlen($response->getContent()) : 0,
            ]
        ];

        // Log errors and slow requests separately
        if ($statusCode >= 400) {
            Log::channel('api')->error('API error', $logData);
        } elseif ($duration > 2.0) {
            Log::channel('performance')->warning('Slow API request', $logData);
        } else {
            Log::channel('api')->info('API request', $logData);
        }

        $this->logActivity($logData);
    }

    /**
     * Log system errors.
     */
    public function logSystemError(
        \Throwable $exception,
        ?Request $request = null,
        ?User $user = null,
        array $context = []
    ): void {
        $logData = [
            'type' => 'system_error',
            'error_class' => get_class($exception),
            'error_message' => $exception->getMessage(),
            'error_code' => $exception->getCode(),
            'file' => $exception->getFile(),
            'line' => $exception->getLine(),
            'trace' => $exception->getTraceAsString(),
            'timestamp' => now(),
            'context' => array_merge([
                'user_id' => $user?->id,
                'company_id' => $user?->company_id,
                'url' => $request?->fullUrl(),
                'method' => $request?->method(),
                'ip_address' => $request?->ip(),
            ], $context)
        ];

        Log::channel('errors')->error('System error occurred', $logData);
        $this->logActivity($logData);
    }

    /**
     * Log performance metrics.
     */
    public function logPerformanceMetric(
        string $metric,
        float $value,
        string $unit = 'ms',
        array $context = []
    ): void {
        $logData = [
            'type' => 'performance_metric',
            'metric' => $metric,
            'value' => $value,
            'unit' => $unit,
            'timestamp' => now(),
            'context' => $context
        ];

        Log::channel('performance')->info('Performance metric', $logData);
    }

    /**
     * Log business events.
     */
    public function logBusinessEvent(
        string $event,
        array $data,
        ?User $user = null
    ): void {
        $logData = [
            'type' => 'business_event',
            'event' => $event,
            'data' => $data,
            'user_id' => $user?->id,
            'company_id' => $user?->company_id,
            'timestamp' => now()
        ];

        Log::channel('business')->info('Business event', $logData);
        $this->logActivity($logData);
    }

    /**
     * Log to activity table for auditing.
     */
    private function logActivity(array $data): void
    {
        try {
            DB::table('activity_logs')->insert([
                'type' => $data['type'],
                'action' => $data['action'] ?? $data['event'] ?? 'unknown',
                'user_id' => $data['user_id'] ?? null,
                'machine_id' => $data['machine_id'] ?? null,
                'control_list_id' => $data['control_list_id'] ?? null,
                'ip_address' => $data['ip_address'] ?? null,
                'user_agent' => $data['user_agent'] ?? null,
                'data' => json_encode($data),
                'created_at' => now(),
                'updated_at' => now()
            ]);
        } catch (\Throwable $e) {
            // Don't let logging failures break the application
            Log::error('Failed to log activity', [
                'error' => $e->getMessage(),
                'original_data' => $data
            ]);
        }
    }

    /**
     * Sanitize headers for logging.
     */
    private function sanitizeHeaders(array $headers): array
    {
        $sensitiveHeaders = [
            'authorization',
            'cookie',
            'x-api-key',
            'x-auth-token'
        ];

        $sanitized = [];
        foreach ($headers as $key => $value) {
            if (in_array(strtolower($key), $sensitiveHeaders)) {
                $sanitized[$key] = '[REDACTED]';
            } else {
                $sanitized[$key] = is_array($value) ? implode(', ', $value) : $value;
            }
        }

        return $sanitized;
    }

    /**
     * Get activity logs with filtering.
     */
    public function getActivityLogs(array $filters = [], int $limit = 100): array
    {
        $query = DB::table('activity_logs')->orderBy('created_at', 'desc');

        if (isset($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        if (isset($filters['user_id'])) {
            $query->where('user_id', $filters['user_id']);
        }

        if (isset($filters['machine_id'])) {
            $query->where('machine_id', $filters['machine_id']);
        }

        if (isset($filters['date_from'])) {
            $query->where('created_at', '>=', $filters['date_from']);
        }

        if (isset($filters['date_to'])) {
            $query->where('created_at', '<=', $filters['date_to']);
        }

        if (isset($filters['company_id'])) {
            // This would require a join or subquery based on your schema
            // For now, we'll filter by JSON data
            $query->whereJsonContains('data->context->company_id', $filters['company_id']);
        }

        $logs = $query->limit($limit)->get();

        return $logs->map(function ($log) {
            $log->data = json_decode($log->data, true);
            return $log;
        })->toArray();
    }

    /**
     * Get log statistics.
     */
    public function getLogStatistics(int $days = 30): array
    {
        $dateFrom = now()->subDays($days);

        return [
            'total_logs' => DB::table('activity_logs')
                ->where('created_at', '>=', $dateFrom)
                ->count(),

            'by_type' => DB::table('activity_logs')
                ->select('type', DB::raw('COUNT(*) as count'))
                ->where('created_at', '>=', $dateFrom)
                ->groupBy('type')
                ->pluck('count', 'type')
                ->toArray(),

            'errors_count' => DB::table('activity_logs')
                ->where('type', 'system_error')
                ->where('created_at', '>=', $dateFrom)
                ->count(),

            'security_events' => DB::table('activity_logs')
                ->where('type', 'security')
                ->where('created_at', '>=', $dateFrom)
                ->count(),

            'api_requests' => DB::table('activity_logs')
                ->where('type', 'api_request')
                ->where('created_at', '>=', $dateFrom)
                ->count(),

            'period' => [
                'from' => $dateFrom->toISOString(),
                'to' => now()->toISOString(),
                'days' => $days
            ]
        ];
    }

    /**
     * Archive old logs.
     */
    public function archiveOldLogs(int $days = 90): int
    {
        $cutoffDate = now()->subDays($days);

        // Move to archive table (you would need to create this)
        $logsToArchive = DB::table('activity_logs')
            ->where('created_at', '<', $cutoffDate)
            ->get();

        if ($logsToArchive->isNotEmpty()) {
            // Insert into archive table
            DB::table('activity_logs_archive')->insert(
                $logsToArchive->toArray()
            );

            // Delete from main table
            $deletedCount = DB::table('activity_logs')
                ->where('created_at', '<', $cutoffDate)
                ->delete();

            Log::info('Logs archived', [
                'archived_count' => $deletedCount,
                'cutoff_date' => $cutoffDate->toISOString()
            ]);

            return $deletedCount;
        }

        return 0;
    }

    /**
     * Export logs to file.
     */
    public function exportLogs(array $filters = [], string $format = 'json'): string
    {
        $logs = $this->getActivityLogs($filters, 10000);
        $filename = 'activity_logs_' . now()->format('Y-m-d_H-i-s') . '.' . $format;
        $filepath = storage_path('app/exports/' . $filename);

        if (!file_exists(dirname($filepath))) {
            mkdir(dirname($filepath), 0755, true);
        }

        if ($format === 'csv') {
            $this->exportToCsv($logs, $filepath);
        } else {
            file_put_contents($filepath, json_encode($logs, JSON_PRETTY_PRINT));
        }

        return $filepath;
    }

    /**
     * Export logs to CSV format.
     */
    private function exportToCsv(array $logs, string $filepath): void
    {
        $file = fopen($filepath, 'w');

        // Write header
        fputcsv($file, [
            'timestamp',
            'type',
            'action',
            'user_id',
            'user_email',
            'machine_id',
            'ip_address',
            'details'
        ]);

        // Write data
        foreach ($logs as $log) {
            fputcsv($file, [
                $log->created_at,
                $log->type,
                $log->action,
                $log->user_id,
                $log->data['user_email'] ?? '',
                $log->machine_id,
                $log->ip_address,
                json_encode($log->data)
            ]);
        }

        fclose($file);
    }
}