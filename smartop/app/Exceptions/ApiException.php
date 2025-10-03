<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Http\JsonResponse;
use App\Http\Responses\ApiResponse;

abstract class ApiException extends Exception
{
    protected array $errors = [];
    protected array $meta = [];
    protected int $statusCode = 500;

    public function __construct(
        string $message = '',
        array $errors = [],
        array $meta = [],
        ?\Throwable $previous = null
    ) {
        $this->errors = $errors;
        $this->meta = $meta;
        parent::__construct($message, $this->statusCode, $previous);
    }

    /**
     * Report the exception.
     */
    public function report(): bool
    {
        return false;
    }

    /**
     * Render the exception as an HTTP response.
     */
    public function render(): JsonResponse
    {
        return ApiResponse::error(
            message: $this->getMessage(),
            errors: $this->errors,
            statusCode: $this->statusCode,
            meta: $this->meta
        );
    }

    /**
     * Get the exception errors.
     */
    public function getErrors(): array
    {
        return $this->errors;
    }

    /**
     * Get the exception meta data.
     */
    public function getMeta(): array
    {
        return $this->meta;
    }

    /**
     * Get the HTTP status code.
     */
    public function getStatusCode(): int
    {
        return $this->statusCode;
    }
}

class ValidationException extends ApiException
{
    protected int $statusCode = 422;

    public function __construct(
        array $errors,
        string $message = 'Validation failed',
        array $meta = []
    ) {
        parent::__construct($message, $errors, $meta);
    }
}

class AuthenticationException extends ApiException
{
    protected int $statusCode = 401;

    public function __construct(
        string $message = 'Authentication failed',
        array $meta = []
    ) {
        parent::__construct($message, [], $meta);
    }
}

class AuthorizationException extends ApiException
{
    protected int $statusCode = 403;

    public function __construct(
        string $message = 'Access forbidden',
        array $meta = []
    ) {
        parent::__construct($message, [], $meta);
    }
}

class NotFoundException extends ApiException
{
    protected int $statusCode = 404;

    public function __construct(
        string $message = 'Resource not found',
        array $meta = []
    ) {
        parent::__construct($message, [], $meta);
    }
}

class ConflictException extends ApiException
{
    protected int $statusCode = 409;

    public function __construct(
        string $message = 'Resource conflict',
        array $errors = [],
        array $meta = []
    ) {
        parent::__construct($message, $errors, $meta);
    }
}

class RateLimitException extends ApiException
{
    protected int $statusCode = 429;

    public function __construct(
        string $message = 'Rate limit exceeded',
        int $retryAfter = null,
        array $meta = []
    ) {
        if ($retryAfter) {
            $meta['retry_after'] = $retryAfter;
        }
        parent::__construct($message, [], $meta);
    }
}

class ServerException extends ApiException
{
    protected int $statusCode = 500;

    public function __construct(
        string $message = 'Internal server error',
        array $meta = []
    ) {
        parent::__construct($message, [], $meta);
    }

    public function report(): bool
    {
        return true; // Log server errors
    }
}

class ServiceUnavailableException extends ApiException
{
    protected int $statusCode = 503;

    public function __construct(
        string $message = 'Service temporarily unavailable',
        array $meta = []
    ) {
        parent::__construct($message, [], $meta);
    }
}

class BusinessLogicException extends ApiException
{
    protected int $statusCode = 422;

    public function __construct(
        string $message,
        array $errors = [],
        array $meta = []
    ) {
        parent::__construct($message, $errors, $meta);
    }
}

class ExternalServiceException extends ApiException
{
    protected int $statusCode = 502;

    public function __construct(
        string $message = 'External service error',
        array $meta = []
    ) {
        parent::__construct($message, [], $meta);
    }

    public function report(): bool
    {
        return true; // Log external service errors
    }
}