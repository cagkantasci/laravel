<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Public auth routes
Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::get('profile', [AuthController::class, 'profile']);
    Route::put('profile', [AuthController::class, 'updateProfile']);
    Route::post('change-password', [AuthController::class, 'changePassword']);
    Route::post('logout', [AuthController::class, 'logout']);
    Route::post('logout-all', [AuthController::class, 'logoutAll']);

    // Test route to verify authentication
    Route::get('user', function (Request $request) {
        return response()->json([
            'success' => true,
            'data' => [
                'user' => $request->user()->load('roles', 'company'),
                'permissions' => $request->user()->getAllPermissions()->pluck('name'),
            ]
        ]);
    });

    // Company routes
    Route::apiResource('companies', \App\Http\Controllers\Api\CompanyController::class);

    // Routes that require company middleware
    Route::middleware('company')->group(function () {
        // Machine routes
        Route::apiResource('machines', \App\Http\Controllers\Api\MachineController::class);
        Route::post('machines/{machine}/qr-code', [\App\Http\Controllers\Api\MachineController::class, 'generateQrCode']);

        // Control Template routes
        Route::apiResource('control-templates', \App\Http\Controllers\Api\ControlTemplateController::class);
        Route::post('control-templates/{controlTemplate}/duplicate', [\App\Http\Controllers\Api\ControlTemplateController::class, 'duplicate']);
        Route::post('control-templates/{controlTemplate}/create-control-list', [\App\Http\Controllers\Api\ControlTemplateController::class, 'createControlList']);

        // Control List routes
        Route::get('control-lists/my-lists', [\App\Http\Controllers\Api\ControlListController::class, 'myLists']);
        Route::apiResource('control-lists', \App\Http\Controllers\Api\ControlListController::class);
        Route::post('control-lists/{controlList}/start', [\App\Http\Controllers\Api\ControlListController::class, 'start']);
        Route::post('control-lists/{controlList}/complete', [\App\Http\Controllers\Api\ControlListController::class, 'complete']);
        Route::put('control-lists/{controlList}/items/{itemId}', [\App\Http\Controllers\Api\ControlListController::class, 'updateItem']);
        Route::post('control-lists/{controlList}/approve', [\App\Http\Controllers\Api\ControlListController::class, 'approve']);
        Route::post('control-lists/{controlList}/reject', [\App\Http\Controllers\Api\ControlListController::class, 'reject']);
        Route::post('control-lists/{controlList}/revert', [\App\Http\Controllers\Api\ControlListController::class, 'revert']);

        // Work Session routes
        Route::get('work-sessions', [\App\Http\Controllers\Api\WorkSessionController::class, 'index']);
        Route::get('work-sessions/my-sessions', [\App\Http\Controllers\Api\WorkSessionController::class, 'mySessions']);
        Route::get('work-sessions/active', [\App\Http\Controllers\Api\WorkSessionController::class, 'activeSession']);
        Route::get('work-sessions/statistics', [\App\Http\Controllers\Api\WorkSessionController::class, 'statistics']);
        Route::post('work-sessions/start', [\App\Http\Controllers\Api\WorkSessionController::class, 'start']);
        Route::post('work-sessions/{id}/end', [\App\Http\Controllers\Api\WorkSessionController::class, 'end']);
        Route::post('work-sessions/{id}/approve', [\App\Http\Controllers\Api\WorkSessionController::class, 'approve']);
        Route::post('work-sessions/{id}/reject', [\App\Http\Controllers\Api\WorkSessionController::class, 'reject']);
    });

    // Approval routes (for managers and admins)
    Route::middleware(['role:manager,admin'])->group(function () {
        Route::get('approvals', [\App\Http\Controllers\Api\ApprovalController::class, 'index']);
        Route::get('approvals/statistics', [\App\Http\Controllers\Api\ApprovalController::class, 'statistics']);
        Route::post('approvals/{id}/approve', [\App\Http\Controllers\Api\ApprovalController::class, 'approve']);
        Route::post('approvals/{id}/reject', [\App\Http\Controllers\Api\ApprovalController::class, 'reject']);
    });

    // Dashboard routes
    Route::get('dashboard', [\App\Http\Controllers\Api\DashboardController::class, 'index']);
    Route::get('reports', [\App\Http\Controllers\Api\DashboardController::class, 'reports']);
    
    // Admin only routes
    Route::middleware('role:admin')->group(function () {
        Route::prefix('admin')->group(function () {
            Route::get('dashboard', function () {
                return response()->json([
                    'success' => true,
                    'message' => 'Admin dashboard',
                    'data' => [
                        'total_companies' => \App\Models\Company::count(),
                        'total_users' => \App\Models\User::count(),
                        'active_users' => \App\Models\User::where('status', 'active')->count(),
                    ]
                ]);
            });
        });
    });

    // Manager routes
    Route::middleware(['role:manager,admin'])->group(function () {
        Route::prefix('manager')->group(function () {
            Route::get('dashboard', function (Request $request) {
                $user = $request->user();
                $companyId = $user->hasRole('admin') ? null : $user->company_id;
                
                $query = \App\Models\User::query();
                if ($companyId) {
                    $query->where('company_id', $companyId);
                }

                return response()->json([
                    'success' => true,
                    'message' => 'Manager dashboard',
                    'data' => [
                        'company_users' => $query->count(),
                        'active_users' => $query->where('status', 'active')->count(),
                    ]
                ]);
            });
        });
    });
});

// Health check
Route::get('health', function () {
    return response()->json([
        'success' => true,
        'message' => 'SmartOp API is running',
        'timestamp' => now(),
    ]);
});