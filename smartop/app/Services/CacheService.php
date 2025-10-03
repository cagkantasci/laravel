<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Redis;

class CacheService
{
    protected int $defaultTtl = 3600; // 1 hour
    protected string $keyPrefix = 'smartop:';

    /**
     * Get cache key with prefix.
     */
    protected function getKey(string $key): string
    {
        return $this->keyPrefix . $key;
    }

    /**
     * Get cached data or execute callback to fetch and cache.
     */
    public function remember(string $key, callable $callback, ?int $ttl = null): mixed
    {
        $ttl = $ttl ?? $this->defaultTtl;
        $cacheKey = $this->getKey($key);

        try {
            return Cache::remember($cacheKey, $ttl, $callback);
        } catch (\Throwable $e) {
            Log::error('Cache remember failed', [
                'key' => $cacheKey,
                'error' => $e->getMessage()
            ]);

            // Fallback to direct execution if cache fails
            return $callback();
        }
    }

    /**
     * Get cached data.
     */
    public function get(string $key, mixed $default = null): mixed
    {
        $cacheKey = $this->getKey($key);

        try {
            return Cache::get($cacheKey, $default);
        } catch (\Throwable $e) {
            Log::error('Cache get failed', [
                'key' => $cacheKey,
                'error' => $e->getMessage()
            ]);

            return $default;
        }
    }

    /**
     * Store data in cache.
     */
    public function put(string $key, mixed $value, ?int $ttl = null): bool
    {
        $ttl = $ttl ?? $this->defaultTtl;
        $cacheKey = $this->getKey($key);

        try {
            return Cache::put($cacheKey, $value, $ttl);
        } catch (\Throwable $e) {
            Log::error('Cache put failed', [
                'key' => $cacheKey,
                'error' => $e->getMessage()
            ]);

            return false;
        }
    }

    /**
     * Store data permanently.
     */
    public function forever(string $key, mixed $value): bool
    {
        $cacheKey = $this->getKey($key);

        try {
            return Cache::forever($cacheKey, $value);
        } catch (\Throwable $e) {
            Log::error('Cache forever failed', [
                'key' => $cacheKey,
                'error' => $e->getMessage()
            ]);

            return false;
        }
    }

    /**
     * Remove item from cache.
     */
    public function forget(string $key): bool
    {
        $cacheKey = $this->getKey($key);

        try {
            return Cache::forget($cacheKey);
        } catch (\Throwable $e) {
            Log::error('Cache forget failed', [
                'key' => $cacheKey,
                'error' => $e->getMessage()
            ]);

            return false;
        }
    }

    /**
     * Clear cache by pattern.
     */
    public function clearByPattern(string $pattern): int
    {
        try {
            $keys = Redis::keys($this->getKey($pattern));

            if (empty($keys)) {
                return 0;
            }

            return Redis::del($keys);
        } catch (\Throwable $e) {
            Log::error('Cache clear by pattern failed', [
                'pattern' => $pattern,
                'error' => $e->getMessage()
            ]);

            return 0;
        }
    }

    /**
     * Cache dashboard statistics.
     */
    public function cacheDashboardStats(int $companyId, array $stats): bool
    {
        $key = "dashboard:stats:company:{$companyId}";
        return $this->put($key, $stats, 300); // 5 minutes
    }

    /**
     * Get cached dashboard statistics.
     */
    public function getDashboardStats(int $companyId): ?array
    {
        $key = "dashboard:stats:company:{$companyId}";
        return $this->get($key);
    }

    /**
     * Cache machine data.
     */
    public function cacheMachine(int $machineId, array $data): bool
    {
        $key = "machine:{$machineId}";
        return $this->put($key, $data, 1800); // 30 minutes
    }

    /**
     * Get cached machine data.
     */
    public function getMachine(int $machineId): ?array
    {
        $key = "machine:{$machineId}";
        return $this->get($key);
    }

    /**
     * Cache company machines list.
     */
    public function cacheCompanyMachines(int $companyId, array $machines): bool
    {
        $key = "company:{$companyId}:machines";
        return $this->put($key, $machines, 900); // 15 minutes
    }

    /**
     * Get cached company machines.
     */
    public function getCompanyMachines(int $companyId): ?array
    {
        $key = "company:{$companyId}:machines";
        return $this->get($key);
    }

    /**
     * Cache user permissions.
     */
    public function cacheUserPermissions(int $userId, array $permissions): bool
    {
        $key = "user:{$userId}:permissions";
        return $this->put($key, $permissions, 1800); // 30 minutes
    }

    /**
     * Get cached user permissions.
     */
    public function getUserPermissions(int $userId): ?array
    {
        $key = "user:{$userId}:permissions";
        return $this->get($key);
    }

    /**
     * Cache control list data.
     */
    public function cacheControlList(int $controlListId, array $data): bool
    {
        $key = "control_list:{$controlListId}";
        return $this->put($key, $data, 600); // 10 minutes
    }

    /**
     * Get cached control list data.
     */
    public function getControlList(int $controlListId): ?array
    {
        $key = "control_list:{$controlListId}";
        return $this->get($key);
    }

    /**
     * Cache API response.
     */
    public function cacheApiResponse(string $endpoint, array $params, mixed $response): bool
    {
        $key = "api:" . md5($endpoint . serialize($params));
        return $this->put($key, $response, 300); // 5 minutes
    }

    /**
     * Get cached API response.
     */
    public function getApiResponse(string $endpoint, array $params): mixed
    {
        $key = "api:" . md5($endpoint . serialize($params));
        return $this->get($key);
    }

    /**
     * Cache recent activities.
     */
    public function cacheRecentActivities(int $companyId, array $activities): bool
    {
        $key = "activities:company:{$companyId}";
        return $this->put($key, $activities, 180); // 3 minutes
    }

    /**
     * Get cached recent activities.
     */
    public function getRecentActivities(int $companyId): ?array
    {
        $key = "activities:company:{$companyId}";
        return $this->get($key);
    }

    /**
     * Invalidate related caches when machine is updated.
     */
    public function invalidateMachineCache(int $machineId, int $companyId): void
    {
        $this->forget("machine:{$machineId}");
        $this->forget("company:{$companyId}:machines");
        $this->forget("dashboard:stats:company:{$companyId}");

        // Clear any API caches related to machines
        $this->clearByPattern("api:*machines*");
    }

    /**
     * Invalidate user-related caches.
     */
    public function invalidateUserCache(int $userId): void
    {
        $this->forget("user:{$userId}:permissions");

        // Clear any API caches related to this user
        $this->clearByPattern("api:*user:{$userId}*");
    }

    /**
     * Invalidate company-wide caches.
     */
    public function invalidateCompanyCache(int $companyId): void
    {
        $this->forget("company:{$companyId}:machines");
        $this->forget("dashboard:stats:company:{$companyId}");
        $this->forget("activities:company:{$companyId}");

        // Clear company-specific API caches
        $this->clearByPattern("api:*company:{$companyId}*");
    }

    /**
     * Cache session data for quick access.
     */
    public function cacheSessionData(string $sessionId, array $data): bool
    {
        $key = "session:{$sessionId}";
        return $this->put($key, $data, 7200); // 2 hours
    }

    /**
     * Get cached session data.
     */
    public function getSessionData(string $sessionId): ?array
    {
        $key = "session:{$sessionId}";
        return $this->get($key);
    }

    /**
     * Cache rate limiting data.
     */
    public function cacheRateLimit(string $identifier, int $attempts, int $ttl): bool
    {
        $key = "rate_limit:{$identifier}";
        return $this->put($key, $attempts, $ttl);
    }

    /**
     * Get rate limiting data.
     */
    public function getRateLimit(string $identifier): ?int
    {
        $key = "rate_limit:{$identifier}";
        return $this->get($key, 0);
    }

    /**
     * Increment rate limiting counter.
     */
    public function incrementRateLimit(string $identifier, int $ttl): int
    {
        $key = $this->getKey("rate_limit:{$identifier}");

        try {
            $current = Cache::get($key, 0);
            $new = $current + 1;
            Cache::put($key, $new, $ttl);
            return $new;
        } catch (\Throwable $e) {
            Log::error('Rate limit increment failed', [
                'identifier' => $identifier,
                'error' => $e->getMessage()
            ]);

            return 1;
        }
    }

    /**
     * Get cache statistics.
     */
    public function getStats(): array
    {
        try {
            $info = Redis::info('memory');

            return [
                'used_memory' => $info['used_memory'] ?? 0,
                'used_memory_human' => $info['used_memory_human'] ?? '0B',
                'keyspace_hits' => Redis::info('stats')['keyspace_hits'] ?? 0,
                'keyspace_misses' => Redis::info('stats')['keyspace_misses'] ?? 0,
                'total_commands_processed' => Redis::info('stats')['total_commands_processed'] ?? 0,
            ];
        } catch (\Throwable $e) {
            Log::error('Cache stats failed', ['error' => $e->getMessage()]);

            return [
                'used_memory' => 0,
                'used_memory_human' => '0B',
                'keyspace_hits' => 0,
                'keyspace_misses' => 0,
                'total_commands_processed' => 0,
            ];
        }
    }

    /**
     * Warm up commonly used caches.
     */
    public function warmUp(): void
    {
        Log::info('Starting cache warmup');

        try {
            // Warm up active companies
            $companies = \App\Models\Company::where('status', 'active')->get();

            foreach ($companies as $company) {
                // Cache company machines
                $machines = $company->machines()->active()->get()->toArray();
                $this->cacheCompanyMachines($company->id, $machines);

                // Cache dashboard stats (mock data for warmup)
                $stats = [
                    'total_machines' => $company->machines()->count(),
                    'active_machines' => $company->machines()->active()->count(),
                    'last_updated' => now()->toISOString()
                ];
                $this->cacheDashboardStats($company->id, $stats);
            }

            Log::info('Cache warmup completed');

        } catch (\Throwable $e) {
            Log::error('Cache warmup failed', ['error' => $e->getMessage()]);
        }
    }
}