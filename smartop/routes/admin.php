<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\UserManagementController;

/*
|--------------------------------------------------------------------------
| Admin API Routes
|--------------------------------------------------------------------------
|
| Here you can register admin API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group and requires authentication.
|
*/

// User Management Routes
Route::prefix('users')->name('admin.users.')->group(function () {
    Route::get('/', [UserManagementController::class, 'index'])->name('index');
    Route::post('/', [UserManagementController::class, 'store'])->name('store');
    Route::get('/{userId}', [UserManagementController::class, 'show'])->name('show');
    Route::put('/{userId}', [UserManagementController::class, 'update'])->name('update');
    Route::delete('/{userId}', [UserManagementController::class, 'destroy'])->name('destroy');

    Route::get('/roles/list', [UserManagementController::class, 'getRoles'])->name('roles');
    Route::post('/bulk-update', [UserManagementController::class, 'bulkUpdate'])->name('bulk-update');
    Route::post('/send-invitation', [UserManagementController::class, 'sendInvitation'])->name('send-invitation');
});