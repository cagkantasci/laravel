<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\User;
use App\Models\Company;
use App\Models\Machine;

/*
|--------------------------------------------------------------------------
| Broadcast Channels
|--------------------------------------------------------------------------
|
| Here you may register all of the event broadcasting channels that your
| application supports. The given channel authorization callbacks are
| used to check if an authenticated user can listen to the channel.
|
*/

// Private channel for authenticated users
Broadcast::channel('user.{userId}', function (User $user, int $userId) {
    return $user->id === $userId;
});

// Company-wide channel - only company members can join
Broadcast::channel('company.{companyId}', function (User $user, int $companyId) {
    return $user->company_id === $companyId ? [
        'id' => $user->id,
        'name' => $user->name,
        'email' => $user->email,
        'role' => $user->roles->first()?->name ?? 'user',
        'last_seen' => now()->toISOString(),
    ] : false;
});

// Machine-specific channel - only company members can join
Broadcast::channel('machine.{machineId}', function (User $user, int $machineId) {
    $machine = Machine::find($machineId);

    if (!$machine) {
        return false;
    }

    return $user->company_id === $machine->company_id ? [
        'id' => $user->id,
        'name' => $user->name,
        'role' => $user->roles->first()?->name ?? 'user',
    ] : false;
});

// Admin-only channel
Broadcast::channel('admin.{companyId}', function (User $user, int $companyId) {
    return $user->company_id === $companyId && $user->hasRole(['admin', 'manager']) ? [
        'id' => $user->id,
        'name' => $user->name,
        'role' => $user->roles->first()?->name,
    ] : false;
});

// Global notifications channel for system-wide announcements
Broadcast::channel('system.notifications', function (User $user) {
    return [
        'id' => $user->id,
        'name' => $user->name,
        'company_id' => $user->company_id,
    ];
});

// Maintenance channel - only maintenance staff and managers
Broadcast::channel('maintenance.{companyId}', function (User $user, int $companyId) {
    return $user->company_id === $companyId &&
           $user->hasAnyRole(['admin', 'manager', 'maintenance_technician']) ? [
        'id' => $user->id,
        'name' => $user->name,
        'role' => $user->roles->first()?->name,
    ] : false;
});

// Control list channel - operators and supervisors
Broadcast::channel('control-lists.{companyId}', function (User $user, int $companyId) {
    return $user->company_id === $companyId ? [
        'id' => $user->id,
        'name' => $user->name,
        'role' => $user->roles->first()?->name,
    ] : false;
});

// Real-time dashboard updates
Broadcast::channel('dashboard.{companyId}', function (User $user, int $companyId) {
    return $user->company_id === $companyId ? [
        'id' => $user->id,
        'name' => $user->name,
        'role' => $user->roles->first()?->name,
        'permissions' => $user->getAllPermissions()->pluck('name'),
    ] : false;
});

// Reporting channel - for real-time report generation updates
Broadcast::channel('reports.{userId}', function (User $user, int $userId) {
    return $user->id === $userId;
});

// Chat/messaging channel for team communication
Broadcast::channel('chat.{companyId}', function (User $user, int $companyId) {
    return $user->company_id === $companyId ? [
        'id' => $user->id,
        'name' => $user->name,
        'avatar' => $user->profile_photo,
        'role' => $user->roles->first()?->name,
        'status' => 'online',
        'joined_at' => now()->toISOString(),
    ] : false;
});

// Emergency alerts channel - critical notifications
Broadcast::channel('emergency.{companyId}', function (User $user, int $companyId) {
    return $user->company_id === $companyId ? [
        'id' => $user->id,
        'name' => $user->name,
        'role' => $user->roles->first()?->name,
        'can_acknowledge' => $user->hasAnyRole(['admin', 'manager', 'supervisor']),
    ] : false;
});