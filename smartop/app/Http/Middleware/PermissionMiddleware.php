<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class PermissionMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, ...$permissions): Response
    {
        // Check if user is authenticated
        if (!auth()->check()) {
            return response()->json(['error' => 'Unauthenticated'], 401);
        }

        $user = auth()->user();

        // Check if user has any of the required permissions
        if (!empty($permissions)) {
            $hasPermission = false;
            
            foreach ($permissions as $permission) {
                if ($user->can($permission)) {
                    $hasPermission = true;
                    break;
                }
            }

            if (!$hasPermission) {
                return response()->json([
                    'error' => 'Bu işlem için yetkiniz yok.',
                    'required_permissions' => $permissions
                ], 403);
            }
        }

        return $next($request);
    }
}
