<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use App\Http\Responses\ApiResponse;
use Illuminate\Support\Facades\Log;

class ApiErrorHandler
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        try {
            $response = $next($request);

            // Handle Laravel validation errors
            if ($response->status() === 422 && $request->expectsJson()) {
                $data = json_decode($response->getContent(), true);

                if (isset($data['errors'])) {
                    return ApiResponse::validationError(
                        $data['errors'],
                        $data['message'] ?? 'Validation failed'
                    );
                }
            }

            // Handle 404 errors for API routes
            if ($response->status() === 404 && $request->is('api/*')) {
                return ApiResponse::notFound('Endpoint not found');
            }

            // Handle 405 Method Not Allowed
            if ($response->status() === 405 && $request->is('api/*')) {
                return ApiResponse::error(
                    'Method not allowed',
                    ['method' => 'The ' . $request->method() . ' method is not allowed for this endpoint'],
                    405
                );
            }

            return $response;

        } catch (\Throwable $e) {
            return $this->handleException($e, $request);
        }
    }

    /**
     * Handle exceptions and convert them to API responses.
     */
    protected function handleException(\Throwable $e, Request $request): JsonResponse
    {
        // Log the exception
        Log::error('API Exception', [
            'exception' => get_class($e),
            'message' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'trace' => $e->getTraceAsString(),
            'url' => $request->fullUrl(),
            'method' => $request->method(),
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'user_id' => $request->user()?->id,
        ]);

        // Handle specific exception types
        switch (true) {
            case $e instanceof \Illuminate\Validation\ValidationException:
                return ApiResponse::validationError(
                    $e->errors(),
                    'Validation failed'
                );

            case $e instanceof \Illuminate\Auth\AuthenticationException:
                return ApiResponse::unauthorized('Authentication required');

            case $e instanceof \Illuminate\Auth\Access\AuthorizationException:
                return ApiResponse::forbidden('Access denied');

            case $e instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException:
                return ApiResponse::notFound('Resource not found');

            case $e instanceof \Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException:
                return ApiResponse::error(
                    'Method not allowed',
                    ['method' => 'HTTP method not allowed'],
                    405
                );

            case $e instanceof \Symfony\Component\HttpKernel\Exception\TooManyRequestsHttpException:
                $retryAfter = $e->getHeaders()['Retry-After'] ?? null;
                return ApiResponse::rateLimitExceeded(
                    $retryAfter,
                    'Too many requests'
                );

            case $e instanceof \Illuminate\Database\Eloquent\ModelNotFoundException:
                return ApiResponse::notFound('Resource not found');

            case $e instanceof \Illuminate\Database\QueryException:
                return $this->handleDatabaseException($e);

            case $e instanceof \Symfony\Component\HttpKernel\Exception\HttpException:
                return ApiResponse::error(
                    $e->getMessage() ?: 'HTTP error',
                    [],
                    $e->getStatusCode()
                );

            default:
                return $this->handleGenericException($e);
        }
    }

    /**
     * Handle database exceptions.
     */
    protected function handleDatabaseException(\Illuminate\Database\QueryException $e): JsonResponse
    {
        $errorCode = $e->errorInfo[1] ?? null;

        switch ($errorCode) {
            case 1062: // Duplicate entry
                return ApiResponse::error(
                    'Duplicate entry',
                    ['database' => 'A record with this value already exists'],
                    409
                );

            case 1452: // Foreign key constraint violation
                return ApiResponse::error(
                    'Related resource not found',
                    ['database' => 'Referenced resource does not exist'],
                    422
                );

            case 1048: // Column cannot be null
                return ApiResponse::error(
                    'Required field missing',
                    ['database' => 'Required field cannot be empty'],
                    422
                );

            default:
                Log::error('Database error', [
                    'code' => $errorCode,
                    'message' => $e->getMessage(),
                    'sql' => $e->getSql(),
                    'bindings' => $e->getBindings(),
                ]);

                if (app()->environment('production')) {
                    return ApiResponse::serverError('Database operation failed');
                }

                return ApiResponse::error(
                    'Database error',
                    ['database' => $e->getMessage()],
                    500
                );
        }
    }

    /**
     * Handle generic exceptions.
     */
    protected function handleGenericException(\Throwable $e): JsonResponse
    {
        if (app()->environment('production')) {
            return ApiResponse::serverError('An unexpected error occurred');
        }

        return ApiResponse::error(
            'Server error',
            [
                'exception' => get_class($e),
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ],
            500
        );
    }
}