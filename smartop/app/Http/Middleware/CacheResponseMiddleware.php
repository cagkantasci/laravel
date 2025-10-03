<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Services\CacheService;
use Illuminate\Support\Facades\Log;

class CacheResponseMiddleware
{
    protected CacheService $cacheService;
    protected array $cacheableRoutes = [
        'api/machines',
        'api/companies',
        'api/dashboard',
        'api/control-templates',
    ];

    protected array $cacheableMethods = ['GET'];
    protected int $defaultTtl = 300; // 5 minutes

    public function __construct(CacheService $cacheService)
    {
        $this->cacheService = $cacheService;
    }

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, ?string $ttl = null): Response
    {
        // Only cache GET requests
        if (!in_array($request->method(), $this->cacheableMethods)) {
            return $next($request);
        }

        // Check if route is cacheable
        if (!$this->shouldCache($request)) {
            return $next($request);
        }

        // Generate cache key
        $cacheKey = $this->generateCacheKey($request);

        // Try to get cached response
        $cachedResponse = $this->cacheService->get($cacheKey);

        if ($cachedResponse !== null) {
            Log::debug('Cache hit', ['key' => $cacheKey]);

            return response($cachedResponse['content'])
                ->withHeaders($cachedResponse['headers'])
                ->setStatusCode($cachedResponse['status']);
        }

        // Process request
        $response = $next($request);

        // Cache successful responses
        if ($this->shouldCacheResponse($response)) {
            $ttlValue = $ttl ? (int) $ttl : $this->defaultTtl;

            $cacheData = [
                'content' => $response->getContent(),
                'headers' => $this->getCacheableHeaders($response),
                'status' => $response->getStatusCode(),
                'cached_at' => now()->toISOString()
            ];

            $this->cacheService->put($cacheKey, $cacheData, $ttlValue);

            Log::debug('Response cached', [
                'key' => $cacheKey,
                'ttl' => $ttlValue,
                'size' => strlen($response->getContent())
            ]);

            // Add cache headers
            $response->headers->set('X-Cache-Status', 'MISS');
            $response->headers->set('X-Cache-Key', md5($cacheKey));
        }

        return $response;
    }

    /**
     * Determine if request should be cached.
     */
    protected function shouldCache(Request $request): bool
    {
        $path = $request->path();

        foreach ($this->cacheableRoutes as $route) {
            if (str_starts_with($path, $route)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Determine if response should be cached.
     */
    protected function shouldCacheResponse(Response $response): bool
    {
        // Only cache successful responses
        if ($response->getStatusCode() !== 200) {
            return false;
        }

        // Don't cache if response has no-cache headers
        $cacheControl = $response->headers->get('Cache-Control', '');
        if (str_contains($cacheControl, 'no-cache') || str_contains($cacheControl, 'no-store')) {
            return false;
        }

        // Don't cache large responses (> 1MB)
        $contentLength = strlen($response->getContent());
        if ($contentLength > 1024 * 1024) {
            return false;
        }

        return true;
    }

    /**
     * Generate cache key for request.
     */
    protected function generateCacheKey(Request $request): string
    {
        $parts = [
            'api_response',
            $request->path(),
            $request->method(),
            md5($request->getQueryString() ?? ''),
        ];

        // Include user context for personalized responses
        if ($user = $request->user()) {
            $parts[] = 'user_' . $user->id;
            $parts[] = 'company_' . ($user->company_id ?? 'none');
        }

        return implode(':', $parts);
    }

    /**
     * Get cacheable headers from response.
     */
    protected function getCacheableHeaders(Response $response): array
    {
        $cacheableHeaders = [
            'Content-Type',
            'Content-Encoding',
            'Vary',
            'ETag',
            'Last-Modified',
        ];

        $headers = [];
        foreach ($cacheableHeaders as $header) {
            if ($response->headers->has($header)) {
                $headers[$header] = $response->headers->get($header);
            }
        }

        // Add custom cache headers
        $headers['X-Cache-Status'] = 'HIT';
        $headers['X-Cache-Created'] = now()->toISOString();

        return $headers;
    }
}