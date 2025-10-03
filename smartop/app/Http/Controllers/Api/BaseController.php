<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

abstract class BaseController extends Controller
{
    /**
     * Return a success response.
     */
    protected function success(
        mixed $data = null,
        string $message = 'Operation successful',
        int $statusCode = 200,
        array $meta = []
    ): JsonResponse {
        return ApiResponse::success($data, $message, $statusCode, $meta);
    }

    /**
     * Return an error response.
     */
    protected function error(
        string $message = 'An error occurred',
        array $errors = [],
        int $statusCode = 400,
        mixed $data = null,
        array $meta = []
    ): JsonResponse {
        return ApiResponse::error($message, $errors, $statusCode, $data, $meta);
    }

    /**
     * Return a validation error response.
     */
    protected function validationError(
        array $errors,
        string $message = 'Validation failed'
    ): JsonResponse {
        return ApiResponse::validationError($errors, $message);
    }

    /**
     * Return a created response.
     */
    protected function created(
        mixed $data = null,
        string $message = 'Resource created successfully'
    ): JsonResponse {
        return ApiResponse::created($data, $message);
    }

    /**
     * Return an updated response.
     */
    protected function updated(
        mixed $data = null,
        string $message = 'Resource updated successfully'
    ): JsonResponse {
        return ApiResponse::updated($data, $message);
    }

    /**
     * Return a deleted response.
     */
    protected function deleted(
        string $message = 'Resource deleted successfully'
    ): JsonResponse {
        return ApiResponse::deleted($message);
    }

    /**
     * Return a paginated response.
     */
    protected function paginated(
        $data,
        string $message = 'Data retrieved successfully',
        array $meta = []
    ): JsonResponse {
        return ApiResponse::paginated($data, $message, $meta);
    }

    /**
     * Return a not found response.
     */
    protected function notFound(
        string $message = 'Resource not found'
    ): JsonResponse {
        return ApiResponse::notFound($message);
    }

    /**
     * Return an unauthorized response.
     */
    protected function unauthorized(
        string $message = 'Unauthorized access'
    ): JsonResponse {
        return ApiResponse::unauthorized($message);
    }

    /**
     * Return a forbidden response.
     */
    protected function forbidden(
        string $message = 'Access forbidden'
    ): JsonResponse {
        return ApiResponse::forbidden($message);
    }

    /**
     * Validate request data with custom rules.
     */
    protected function validateRequest(Request $request, array $rules, array $messages = []): array
    {
        $validator = Validator::make($request->all(), $rules, $messages);

        if ($validator->fails()) {
            throw new ValidationException($validator);
        }

        return $validator->validated();
    }

    /**
     * Get pagination parameters from request.
     */
    protected function getPaginationParams(Request $request): array
    {
        $page = max(1, (int) $request->query('page', 1));
        $perPage = min(100, max(1, (int) $request->query('per_page', 15)));

        return [
            'page' => $page,
            'per_page' => $perPage,
        ];
    }

    /**
     * Get search parameters from request.
     */
    protected function getSearchParams(Request $request): array
    {
        return [
            'search' => $request->query('search'),
            'sort_by' => $request->query('sort_by'),
            'sort_order' => in_array($request->query('sort_order'), ['asc', 'desc'])
                ? $request->query('sort_order')
                : 'asc',
            'filters' => $this->parseFilters($request->query('filters', [])),
        ];
    }

    /**
     * Parse filters from request.
     */
    protected function parseFilters(array $filters): array
    {
        $parsed = [];

        foreach ($filters as $key => $value) {
            if (!empty($value)) {
                $parsed[$key] = $value;
            }
        }

        return $parsed;
    }

    /**
     * Apply search and filters to query builder.
     */
    protected function applySearchAndFilters($query, array $searchParams, array $searchableFields = [])
    {
        // Apply search
        if (!empty($searchParams['search']) && !empty($searchableFields)) {
            $searchTerm = $searchParams['search'];
            $query->where(function ($q) use ($searchableFields, $searchTerm) {
                foreach ($searchableFields as $field) {
                    $q->orWhere($field, 'LIKE', "%{$searchTerm}%");
                }
            });
        }

        // Apply sorting
        if (!empty($searchParams['sort_by'])) {
            $query->orderBy($searchParams['sort_by'], $searchParams['sort_order']);
        }

        // Apply filters
        foreach ($searchParams['filters'] as $field => $value) {
            if (is_array($value)) {
                $query->whereIn($field, $value);
            } else {
                $query->where($field, $value);
            }
        }

        return $query;
    }

    /**
     * Transform data using a resource class.
     */
    protected function transformData($data, string $resourceClass)
    {
        if (is_null($data)) {
            return null;
        }

        if ($data instanceof \Illuminate\Contracts\Pagination\LengthAwarePaginator) {
            return $resourceClass::collection($data);
        }

        if (is_iterable($data)) {
            return $resourceClass::collection(collect($data));
        }

        return new $resourceClass($data);
    }

    /**
     * Handle file upload.
     */
    protected function handleFileUpload(Request $request, string $fieldName, string $disk = 'public'): ?array
    {
        if (!$request->hasFile($fieldName)) {
            return null;
        }

        $file = $request->file($fieldName);

        if (!$file->isValid()) {
            throw ValidationException::withMessages([
                $fieldName => ['The uploaded file is invalid.']
            ]);
        }

        $path = $file->store('uploads', $disk);

        return [
            'original_name' => $file->getClientOriginalName(),
            'mime_type' => $file->getMimeType(),
            'size' => $file->getSize(),
            'path' => $path,
            'url' => asset('storage/' . $path),
        ];
    }

    /**
     * Get the authenticated user.
     */
    protected function getAuthUser()
    {
        return auth('sanctum')->user();
    }

    /**
     * Check if user has permission.
     */
    protected function checkPermission(string $permission): bool
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return false;
        }

        return $user->can($permission);
    }

    /**
     * Ensure user has permission or throw exception.
     */
    protected function requirePermission(string $permission): void
    {
        if (!$this->checkPermission($permission)) {
            throw new \App\Exceptions\AuthorizationException(
                "Permission required: {$permission}"
            );
        }
    }

    /**
     * Get user's company ID.
     */
    protected function getUserCompanyId(): ?int
    {
        $user = $this->getAuthUser();

        return $user?->company_id;
    }

    /**
     * Ensure user belongs to a company.
     */
    protected function requireCompany(): int
    {
        $companyId = $this->getUserCompanyId();

        if (!$companyId) {
            throw new \App\Exceptions\AuthorizationException(
                'User must belong to a company to access this resource'
            );
        }

        return $companyId;
    }

    /**
     * Log API activity.
     */
    protected function logActivity(string $action, array $data = []): void
    {
        $user = $this->getAuthUser();

        \Illuminate\Support\Facades\Log::info('API Activity', [
            'action' => $action,
            'user_id' => $user?->id,
            'company_id' => $user?->company_id,
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'data' => $data,
            'timestamp' => now(),
        ]);
    }

    /**
     * Cache response data.
     */
    protected function cacheResponse(string $key, callable $callback, int $ttl = 3600)
    {
        return cache()->remember($key, $ttl, $callback);
    }

    /**
     * Invalidate cache by pattern.
     */
    protected function invalidateCache(string $pattern): void
    {
        // Implementation depends on cache driver
        // For Redis: cache()->tags($pattern)->flush()
        // For file cache: need custom implementation
    }
}