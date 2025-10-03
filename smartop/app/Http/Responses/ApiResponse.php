<?php

namespace App\Http\Responses;

use Illuminate\Http\JsonResponse;

class ApiResponse
{
    /**
     * Return a success response.
     */
    public static function success(
        mixed $data = null,
        string $message = 'Operation successful',
        int $statusCode = 200,
        array $meta = []
    ): JsonResponse {
        $response = [
            'success' => true,
            'message' => $message,
            'data' => $data,
            'meta' => $meta,
            'timestamp' => now()->toISOString(),
            'version' => config('app.version', '1.0.0'),
        ];

        return response()->json($response, $statusCode);
    }

    /**
     * Return an error response.
     */
    public static function error(
        string $message = 'An error occurred',
        array $errors = [],
        int $statusCode = 400,
        mixed $data = null,
        array $meta = []
    ): JsonResponse {
        $response = [
            'success' => false,
            'message' => $message,
            'errors' => $errors,
            'data' => $data,
            'meta' => $meta,
            'timestamp' => now()->toISOString(),
            'version' => config('app.version', '1.0.0'),
        ];

        return response()->json($response, $statusCode);
    }

    /**
     * Return a validation error response.
     */
    public static function validationError(
        array $errors,
        string $message = 'Validation failed'
    ): JsonResponse {
        return self::error($message, $errors, 422);
    }

    /**
     * Return an unauthorized response.
     */
    public static function unauthorized(
        string $message = 'Unauthorized access'
    ): JsonResponse {
        return self::error($message, [], 401);
    }

    /**
     * Return a forbidden response.
     */
    public static function forbidden(
        string $message = 'Access forbidden'
    ): JsonResponse {
        return self::error($message, [], 403);
    }

    /**
     * Return a not found response.
     */
    public static function notFound(
        string $message = 'Resource not found'
    ): JsonResponse {
        return self::error($message, [], 404);
    }

    /**
     * Return a server error response.
     */
    public static function serverError(
        string $message = 'Internal server error'
    ): JsonResponse {
        return self::error($message, [], 500);
    }

    /**
     * Return a paginated response.
     */
    public static function paginated(
        $data,
        string $message = 'Data retrieved successfully',
        array $meta = []
    ): JsonResponse {
        $paginationMeta = [];

        if (method_exists($data, 'total')) {
            $paginationMeta = [
                'pagination' => [
                    'total' => $data->total(),
                    'per_page' => $data->perPage(),
                    'current_page' => $data->currentPage(),
                    'last_page' => $data->lastPage(),
                    'from' => $data->firstItem(),
                    'to' => $data->lastItem(),
                    'has_more_pages' => $data->hasMorePages(),
                ]
            ];
        }

        $finalMeta = array_merge($meta, $paginationMeta);

        return self::success($data->items(), $message, 200, $finalMeta);
    }

    /**
     * Return a created response.
     */
    public static function created(
        mixed $data = null,
        string $message = 'Resource created successfully'
    ): JsonResponse {
        return self::success($data, $message, 201);
    }

    /**
     * Return an updated response.
     */
    public static function updated(
        mixed $data = null,
        string $message = 'Resource updated successfully'
    ): JsonResponse {
        return self::success($data, $message, 200);
    }

    /**
     * Return a deleted response.
     */
    public static function deleted(
        string $message = 'Resource deleted successfully'
    ): JsonResponse {
        return self::success(null, $message, 200);
    }

    /**
     * Return a no content response.
     */
    public static function noContent(): JsonResponse
    {
        return response()->json(null, 204);
    }

    /**
     * Return a rate limit exceeded response.
     */
    public static function rateLimitExceeded(
        int $retryAfter = null,
        string $message = 'Rate limit exceeded'
    ): JsonResponse {
        $meta = [];
        if ($retryAfter) {
            $meta['retry_after'] = $retryAfter;
        }

        return self::error($message, [], 429, null, $meta);
    }

    /**
     * Return a maintenance mode response.
     */
    public static function maintenance(
        string $message = 'Service temporarily unavailable'
    ): JsonResponse {
        return self::error($message, [], 503);
    }

    /**
     * Return a custom status response.
     */
    public static function custom(
        bool $success,
        string $message,
        mixed $data = null,
        array $errors = [],
        int $statusCode = 200,
        array $meta = []
    ): JsonResponse {
        $response = [
            'success' => $success,
            'message' => $message,
            'data' => $data,
            'errors' => $errors,
            'meta' => $meta,
            'timestamp' => now()->toISOString(),
            'version' => config('app.version', '1.0.0'),
        ];

        return response()->json($response, $statusCode);
    }

    /**
     * Return a batch operation response.
     */
    public static function batch(
        array $results,
        string $message = 'Batch operation completed',
        int $successCount = 0,
        int $errorCount = 0
    ): JsonResponse {
        $meta = [
            'batch_summary' => [
                'total' => count($results),
                'successful' => $successCount,
                'failed' => $errorCount,
                'success_rate' => count($results) > 0 ? ($successCount / count($results)) * 100 : 0,
            ]
        ];

        return self::success($results, $message, 200, $meta);
    }

    /**
     * Return a partial content response.
     */
    public static function partialContent(
        mixed $data,
        string $message = 'Partial content retrieved',
        array $meta = []
    ): JsonResponse {
        return self::success($data, $message, 206, $meta);
    }
}