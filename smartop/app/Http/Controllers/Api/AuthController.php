<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(RegisterRequest $request)
    {
        try {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'phone' => $request->phone,
                'identity_number' => $request->identity_number,
                'birth_date' => $request->birth_date,
                'gender' => $request->gender,
                'company_id' => $request->company_id,
                'status' => 'active',
            ]);

            // Assign default role
            $user->assignRole('operator');

            // Log registration
            Log::info('User registered', [
                'user_id' => $user->id,
                'email' => $user->email,
                'ip' => $request->ip()
            ]);

            $token = $user->createToken('SmartOp API Token', ['*'], now()->addDays(30))->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'User registered successfully',
                'data' => [
                    'user' => $user->load('roles', 'company'),
                    'token' => $token,
                    'token_type' => 'Bearer',
                    'expires_at' => now()->addDays(30)->toISOString(),
                ]
            ], 201);

        } catch (\Exception $e) {
            Log::error('Registration failed', [
                'email' => $request->email,
                'error' => $e->getMessage(),
                'ip' => $request->ip()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Registration failed. Please try again.',
                'errors' => null,
                'data' => null
            ], 500);
        }
    }

    /**
     * Login user
     */
    public function login(LoginRequest $request)
    {
        $email = $request->email;
        $ip = $request->ip();
        $key = 'login_attempts:' . $ip . ':' . $email;

        // Check for too many failed attempts
        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);

            Log::warning('Login rate limit exceeded', [
                'email' => $email,
                'ip' => $ip,
                'retry_after' => $seconds
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Too many login attempts. Please try again later.',
                'errors' => ['email' => 'Rate limit exceeded'],
                'retry_after' => $seconds,
                'data' => null
            ], 429);
        }

        if (!Auth::attempt($request->only('email', 'password'))) {
            // Increment failed attempts
            RateLimiter::hit($key, 900); // 15 minutes lockout

            Log::warning('Failed login attempt', [
                'email' => $email,
                'ip' => $ip
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Invalid login credentials',
                'errors' => ['email' => 'Invalid credentials'],
                'data' => null
            ], 401);
        }

        $user = Auth::user();

        // Check if user is active
        if ($user->status !== 'active') {
            Log::warning('Login attempt with inactive account', [
                'user_id' => $user->id,
                'email' => $email,
                'status' => $user->status,
                'ip' => $ip
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Account is not active',
                'errors' => ['account' => 'Account not active'],
                'data' => null
            ], 403);
        }

        // Clear failed attempts on successful login
        RateLimiter::clear($key);

        // Update last login
        $user->updateLastLogin();

        // Log successful login
        Log::info('User logged in', [
            'user_id' => $user->id,
            'email' => $user->email,
            'ip' => $ip
        ]);

        // Revoke old tokens if requested
        if ($request->remember_me !== true) {
            $user->tokens()->delete();
        }

        $token = $user->createToken('SmartOp API Token', ['*'], now()->addDays(30))->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => $user->load('roles', 'company'),
                'token' => $token,
                'token_type' => 'Bearer',
                'expires_at' => now()->addDays(30)->toISOString(),
            ]
        ]);
    }

    /**
     * Get authenticated user profile
     */
    public function profile(Request $request)
    {
        $user = $request->user()->load('roles', 'company');

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'permissions' => $user->getAllPermissions()->pluck('name'),
            ]
        ]);
    }

    /**
     * Update user profile
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|nullable|string|max:20',
            'birth_date' => 'sometimes|nullable|date',
            'gender' => 'sometimes|nullable|in:male,female,other',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $user->update($request->only(['name', 'phone', 'birth_date', 'gender']));

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'user' => $user->fresh()->load('roles', 'company')
            ]
        ]);
    }

    /**
     * Change password
     */
    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Current password is incorrect'
            ], 400);
        }

        $user->update([
            'password' => Hash::make($request->new_password)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully'
        ]);
    }

    /**
     * Logout user (Revoke current token)
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout successful'
        ]);
    }

    /**
     * Logout from all devices (Revoke all tokens)
     */
    public function logoutAll(Request $request)
    {
        $request->user()->tokens()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out from all devices'
        ]);
    }
}
