<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CompanyMiddleware
{
    /**
     * Handle an incoming request.
     * Multi-tenant security: Users can only access their company's data
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check if user is authenticated
        if (!auth()->check()) {
            return response()->json(['error' => 'Unauthenticated'], 401);
        }

        $user = auth()->user();

        // Admin users can access all companies
        if ($user->hasRole('admin')) {
            return $next($request);
        }

        // Check if user has a company assigned
        if (!$user->company_id) {
            return response()->json([
                'error' => 'Kullanıcının bir şirketi bulunmamaktadır.'
            ], 403);
        }

        // Add company filter to the request for multi-tenant queries
        $request->merge(['user_company_id' => $user->company_id]);

        return $next($request);
    }
}
