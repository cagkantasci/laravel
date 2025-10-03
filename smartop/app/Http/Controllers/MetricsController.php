<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Queue;
use App\Models\Machine;
use App\Models\ControlList;
use App\Models\User;

class MetricsController extends Controller
{
    /**
     * Export metrics in Prometheus format.
     */
    public function export(): Response
    {
        $metrics = $this->collectMetrics();
        $prometheusFormat = $this->formatForPrometheus($metrics);

        return response($prometheusFormat, 200, [
            'Content-Type' => 'text/plain; version=0.0.4; charset=utf-8'
        ]);
    }

    /**
     * Get application health status.
     */
    public function health(): Response
    {
        $health = $this->checkHealth();

        return response()->json($health, $health['status'] === 'healthy' ? 200 : 503);
    }

    /**
     * Get detailed application metrics.
     */
    public function metrics(): Response
    {
        $metrics = Cache::remember('app_metrics', 60, function () {
            return $this->collectDetailedMetrics();
        });

        return response()->json([
            'success' => true,
            'data' => $metrics,
            'collected_at' => now()->toISOString()
        ]);
    }

    /**
     * Collect basic metrics for monitoring.
     */
    private function collectMetrics(): array
    {
        return [
            // HTTP metrics
            'http_requests_total' => $this->getHttpRequestsTotal(),
            'http_request_duration_seconds' => $this->getHttpRequestDuration(),

            // Database metrics
            'database_connections_active' => $this->getDatabaseConnections(),
            'database_query_duration_seconds' => $this->getDatabaseQueryDuration(),

            // Queue metrics
            'laravel_queue_size' => $this->getQueueSizes(),
            'laravel_queue_workers' => $this->getQueueWorkers(),
            'laravel_queue_failed_jobs' => $this->getFailedJobs(),

            // Application metrics
            'smartop_machines_total' => Machine::count(),
            'smartop_machines_by_status' => $this->getMachinesByStatus(),
            'smartop_control_lists_total' => ControlList::count(),
            'smartop_control_lists_by_status' => $this->getControlListsByStatus(),
            'smartop_overdue_control_lists' => $this->getOverdueControlLists(),
            'smartop_overdue_maintenance' => $this->getOverdueMaintenance(),
            'smartop_users_active' => $this->getActiveUsers(),

            // System metrics
            'laravel_cache_hits' => $this->getCacheHits(),
            'laravel_cache_misses' => $this->getCacheMisses(),
            'laravel_session_count' => $this->getSessionCount(),
        ];
    }

    /**
     * Collect detailed metrics for dashboard.
     */
    private function collectDetailedMetrics(): array
    {
        return [
            'system' => [
                'uptime' => $this->getUptime(),
                'memory_usage' => $this->getMemoryUsage(),
                'cache_status' => $this->getCacheStatus(),
                'queue_status' => $this->getQueueStatus(),
                'database_status' => $this->getDatabaseStatus(),
            ],
            'application' => [
                'machines' => [
                    'total' => Machine::count(),
                    'active' => Machine::where('status', 'active')->count(),
                    'maintenance' => Machine::where('status', 'maintenance')->count(),
                    'inactive' => Machine::where('status', 'inactive')->count(),
                ],
                'control_lists' => [
                    'total_today' => ControlList::whereDate('created_at', today())->count(),
                    'completed_today' => ControlList::whereDate('created_at', today())
                        ->where('status', 'completed')->count(),
                    'pending' => ControlList::where('status', 'pending')->count(),
                    'overdue' => $this->getOverdueControlLists(),
                ],
                'users' => [
                    'total' => User::count(),
                    'active_today' => User::whereDate('last_login_at', today())->count(),
                    'online' => $this->getOnlineUsers(),
                ],
                'performance' => [
                    'avg_response_time' => $this->getAverageResponseTime(),
                    'error_rate' => $this->getErrorRate(),
                    'throughput' => $this->getThroughput(),
                ]
            ]
        ];
    }

    /**
     * Check application health.
     */
    private function checkHealth(): array
    {
        $checks = [
            'database' => $this->checkDatabaseHealth(),
            'cache' => $this->checkCacheHealth(),
            'queue' => $this->checkQueueHealth(),
            'storage' => $this->checkStorageHealth(),
        ];

        $overallStatus = collect($checks)->every(fn($check) => $check['status'] === 'healthy')
            ? 'healthy'
            : 'unhealthy';

        return [
            'status' => $overallStatus,
            'timestamp' => now()->toISOString(),
            'checks' => $checks,
            'version' => config('app.version', '1.0.0'),
            'environment' => config('app.env'),
        ];
    }

    /**
     * Format metrics for Prometheus.
     */
    private function formatForPrometheus(array $metrics): string
    {
        $output = [];

        foreach ($metrics as $name => $value) {
            if (is_array($value)) {
                foreach ($value as $label => $labelValue) {
                    $output[] = "{$name}{{$label}} {$labelValue}";
                }
            } else {
                $output[] = "{$name} {$value}";
            }
        }

        return implode("\n", $output) . "\n";
    }

    // Health check methods
    private function checkDatabaseHealth(): array
    {
        try {
            DB::select('SELECT 1');
            return ['status' => 'healthy', 'message' => 'Database connection successful'];
        } catch (\Throwable $e) {
            return ['status' => 'unhealthy', 'message' => 'Database connection failed: ' . $e->getMessage()];
        }
    }

    private function checkCacheHealth(): array
    {
        try {
            $testKey = 'health_check_' . time();
            Cache::put($testKey, 'test', 10);
            $value = Cache::get($testKey);
            Cache::forget($testKey);

            if ($value === 'test') {
                return ['status' => 'healthy', 'message' => 'Cache is working'];
            } else {
                return ['status' => 'unhealthy', 'message' => 'Cache test failed'];
            }
        } catch (\Throwable $e) {
            return ['status' => 'unhealthy', 'message' => 'Cache error: ' . $e->getMessage()];
        }
    }

    private function checkQueueHealth(): array
    {
        try {
            $size = Queue::size();
            return ['status' => 'healthy', 'message' => "Queue size: {$size}"];
        } catch (\Throwable $e) {
            return ['status' => 'unhealthy', 'message' => 'Queue error: ' . $e->getMessage()];
        }
    }

    private function checkStorageHealth(): array
    {
        try {
            $path = storage_path('app/health_check.txt');
            file_put_contents($path, 'test');
            $content = file_get_contents($path);
            unlink($path);

            if ($content === 'test') {
                return ['status' => 'healthy', 'message' => 'Storage is writable'];
            } else {
                return ['status' => 'unhealthy', 'message' => 'Storage test failed'];
            }
        } catch (\Throwable $e) {
            return ['status' => 'unhealthy', 'message' => 'Storage error: ' . $e->getMessage()];
        }
    }

    // Metric collection methods
    private function getHttpRequestsTotal(): int
    {
        // This would typically come from a metrics collection system
        return Cache::get('http_requests_total', 0);
    }

    private function getHttpRequestDuration(): float
    {
        // This would typically come from application performance monitoring
        return Cache::get('http_request_duration_avg', 0.5);
    }

    private function getDatabaseConnections(): int
    {
        try {
            $result = DB::select("SHOW STATUS LIKE 'Threads_connected'");
            return (int) $result[0]->Value;
        } catch (\Throwable $e) {
            return 0;
        }
    }

    private function getDatabaseQueryDuration(): float
    {
        // This would typically come from query logging
        return Cache::get('db_query_duration_avg', 0.1);
    }

    private function getQueueSizes(): array
    {
        return [
            'default' => Queue::size('default'),
            'emails' => Queue::size('emails'),
            'notifications' => Queue::size('notifications'),
            'reports' => Queue::size('reports'),
        ];
    }

    private function getQueueWorkers(): int
    {
        // This would need to be implemented based on your queue system
        return 1;
    }

    private function getFailedJobs(): int
    {
        return DB::table('failed_jobs')->count();
    }

    private function getMachinesByStatus(): array
    {
        return Machine::selectRaw('status, COUNT(*) as count')
            ->groupBy('status')
            ->pluck('count', 'status')
            ->toArray();
    }

    private function getControlListsByStatus(): array
    {
        return ControlList::selectRaw('status, COUNT(*) as count')
            ->groupBy('status')
            ->pluck('count', 'status')
            ->toArray();
    }

    private function getOverdueControlLists(): int
    {
        return ControlList::where('status', 'pending')
            ->where('due_date', '<', now())
            ->count();
    }

    private function getOverdueMaintenance(): int
    {
        return Machine::where('next_maintenance_date', '<', now())
            ->where('status', '!=', 'maintenance')
            ->count();
    }

    private function getActiveUsers(): int
    {
        return User::where('last_login_at', '>=', now()->subDays(7))->count();
    }

    private function getCacheHits(): int
    {
        return Cache::get('cache_hits', 0);
    }

    private function getCacheMisses(): int
    {
        return Cache::get('cache_misses', 0);
    }

    private function getSessionCount(): int
    {
        try {
            return DB::table('sessions')->count();
        } catch (\Throwable $e) {
            return 0;
        }
    }

    private function getUptime(): int
    {
        // This would typically come from system monitoring
        return Cache::get('app_uptime', time());
    }

    private function getMemoryUsage(): array
    {
        return [
            'current' => memory_get_usage(true),
            'peak' => memory_get_peak_usage(true),
            'limit' => $this->convertToBytes(ini_get('memory_limit'))
        ];
    }

    private function getCacheStatus(): array
    {
        return [
            'driver' => config('cache.default'),
            'hits' => $this->getCacheHits(),
            'misses' => $this->getCacheMisses(),
        ];
    }

    private function getQueueStatus(): array
    {
        return [
            'driver' => config('queue.default'),
            'sizes' => $this->getQueueSizes(),
            'failed' => $this->getFailedJobs(),
        ];
    }

    private function getDatabaseStatus(): array
    {
        return [
            'connection' => config('database.default'),
            'active_connections' => $this->getDatabaseConnections(),
        ];
    }

    private function getOnlineUsers(): int
    {
        // This would typically come from session or presence tracking
        return Cache::get('online_users_count', 0);
    }

    private function getAverageResponseTime(): float
    {
        return Cache::get('avg_response_time', 0.5);
    }

    private function getErrorRate(): float
    {
        return Cache::get('error_rate', 0.01);
    }

    private function getThroughput(): float
    {
        return Cache::get('requests_per_second', 10.0);
    }

    private function convertToBytes(string $value): int
    {
        $unit = strtolower(substr($value, -1));
        $value = (int) $value;

        return match ($unit) {
            'g' => $value * 1024 * 1024 * 1024,
            'm' => $value * 1024 * 1024,
            'k' => $value * 1024,
            default => $value
        };
    }
}