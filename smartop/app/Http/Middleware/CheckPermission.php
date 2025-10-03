<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckPermission
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string $permission): Response
    {
        if (!auth()->check()) {
            return response()->json([
                'success' => false,
                'message' => 'Kimlik doğrulaması gerekli'
            ], 401);
        }

        if (!auth()->user()->can($permission)) {
            return response()->json([
                'success' => false,
                'message' => 'Bu işlem için yetkiniz yok',
                'required_permission' => $permission
            ], 403);
        }

        return $next($request);
    }
}
