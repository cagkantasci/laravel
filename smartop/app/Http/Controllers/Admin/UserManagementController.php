<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Models\Company;
use App\Services\EmailNotificationService;
use App\Http\Requests\BaseRequest;
use Spatie\Permission\Models\Role;

class UserManagementController extends Controller
{
    private EmailNotificationService $emailService;

    public function __construct(EmailNotificationService $emailService)
    {
        $this->emailService = $emailService;
        // Middleware is applied in routes/api.php
    }

    /**
     * Get users list with pagination and filtering.
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $companyId = auth()->user()->company_id;
            $page = $request->input('page', 1);
            $perPage = $request->input('per_page', 20);
            $search = $request->input('search');
            $role = $request->input('role');
            $status = $request->input('status');

            $query = User::where('company_id', $companyId)
                ->with(['roles', 'company'])
                ->withCount(['controlLists', 'devices']);

            if ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%");
                });
            }

            if ($role) {
                $query->whereHas('roles', function ($q) use ($role) {
                    $q->where('name', $role);
                });
            }

            if ($status) {
                $query->where('status', $status);
            }

            $users = $query->orderBy('created_at', 'desc')
                ->paginate($perPage, ['*'], 'page', $page);

            $formattedUsers = $users->getCollection()->map(function ($user) {
                return [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'status' => $user->status,
                    'role' => $user->roles->pluck('name')->first() ?? 'operator',
                    'roles' => $user->roles->pluck('name')->toArray(),
                    'company' => $user->company ? ['id' => $user->company->id, 'name' => $user->company->name] : null,
                    'control_lists_count' => $user->control_lists_count,
                    'devices_count' => $user->devices_count,
                    'last_login_at' => $user->last_login_at?->toISOString(),
                    'created_at' => $user->created_at->toISOString(),
                    'is_current_user' => $user->id === auth()->id()
                ];
            });

            return response()->json([
                'success' => true,
                'data' => [
                    'users' => $formattedUsers,
                    'pagination' => [
                        'current_page' => $users->currentPage(),
                        'last_page' => $users->lastPage(),
                        'per_page' => $users->perPage(),
                        'total' => $users->total(),
                        'from' => $users->firstItem(),
                        'to' => $users->lastItem()
                    ],
                    'filters' => [
                        'search' => $search,
                        'role' => $role,
                        'status' => $status
                    ]
                ],
                'message' => 'Users retrieved successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to get users list', [
                'error' => $e->getMessage(),
                'user_id' => auth()->id()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve users'
            ], 500);
        }
    }

    /**
     * Get user details.
     */
    public function show(int $userId): JsonResponse
    {
        try {
            $companyId = auth()->user()->company_id;

            $user = User::where('company_id', $companyId)
                ->with(['roles', 'company', 'controlLists' => function ($q) {
                    $q->with('machine')->latest()->limit(10);
                }, 'devices'])
                ->findOrFail($userId);

            $userStats = [
                'total_control_lists' => $user->controlLists()->count(),
                'completed_control_lists' => $user->controlLists()->where('status', 'completed')->count(),
                'pending_control_lists' => $user->controlLists()->where('status', 'pending')->count(),
                'active_devices' => $user->devices()->where('is_active', true)->count(),
                'avg_completion_time' => $this->calculateAverageCompletionTime($user)
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'status' => $user->status,
                        'roles' => $user->roles->pluck('name')->toArray(),
                        'company' => [
                            'id' => $user->company->id,
                            'name' => $user->company->name
                        ],
                        'last_login_at' => $user->last_login_at?->toISOString(),
                        'created_at' => $user->created_at->toISOString(),
                        'updated_at' => $user->updated_at->toISOString()
                    ],
                    'statistics' => $userStats,
                    'recent_control_lists' => $user->controlLists->map(function ($cl) {
                        return [
                            'id' => $cl->id,
                            'machine_name' => $cl->machine->name,
                            'machine_code' => $cl->machine->machine_code,
                            'status' => $cl->status,
                            'created_at' => $cl->created_at->toISOString(),
                            'completed_at' => $cl->completed_at?->toISOString()
                        ];
                    }),
                    'devices' => $user->devices->map(function ($device) {
                        return [
                            'id' => $device->id,
                            'device_name' => $device->device_name,
                            'platform' => $device->platform,
                            'is_active' => $device->is_active,
                            'last_used_at' => $device->last_used_at?->toISOString()
                        ];
                    })
                ],
                'message' => 'User details retrieved successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to get user details', [
                'user_id' => $userId,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }
    }

    /**
     * Create new user.
     */
    public function store(CreateUserRequest $request): JsonResponse
    {
        try {
            DB::beginTransaction();

            $companyId = auth()->user()->company_id;

            $user = User::create([
                'name' => $request->input('name'),
                'email' => $request->input('email'),
                'password' => Hash::make($request->input('password')),
                'phone' => $request->input('phone'),
                'company_id' => $companyId,
                'status' => 'active'
            ]);

            // Assign role
            $role = $request->input('role', 'operator');
            $user->assignRole($role);

            DB::commit();

            // Send welcome email
            $this->emailService->sendWelcomeNotification($user);

            Log::info('User created', [
                'created_user_id' => $user->id,
                'created_by' => auth()->id(),
                'role' => $role
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'phone' => $user->phone,
                        'status' => $user->status,
                        'role' => $role,
                        'roles' => [$role],
                        'company' => $user->company ? ['id' => $user->company->id, 'name' => $user->company->name] : null,
                        'created_at' => $user->created_at->toISOString()
                    ]
                ],
                'message' => 'User created successfully'
            ], 201);

        } catch (\Throwable $e) {
            DB::rollBack();

            Log::error('Failed to create user', [
                'error' => $e->getMessage(),
                'created_by' => auth()->id()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to create user'
            ], 500);
        }
    }

    /**
     * Update user.
     */
    public function update(int $userId, UpdateUserRequest $request): JsonResponse
    {
        try {
            DB::beginTransaction();

            $companyId = auth()->user()->company_id;
            $user = User::where('company_id', $companyId)->findOrFail($userId);

            // Prevent self-role modification by non-admin
            if ($user->id === auth()->id() && !auth()->user()->hasRole('admin')) {
                if ($request->has('role') && !in_array($request->input('role'), auth()->user()->getRoleNames()->toArray())) {
                    return response()->json([
                        'success' => false,
                        'message' => 'You cannot change your own role'
                    ], 403);
                }
            }

            $updateData = $request->only(['name', 'email', 'status']);

            if ($request->filled('password')) {
                $updateData['password'] = Hash::make($request->input('password'));
            }

            $user->update($updateData);

            // Update role if provided
            if ($request->filled('role')) {
                $user->syncRoles([$request->input('role')]);
            }

            DB::commit();

            Log::info('User updated', [
                'updated_user_id' => $user->id,
                'updated_by' => auth()->id(),
                'changes' => $updateData
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'status' => $user->status,
                        'roles' => $user->roles->pluck('name')->toArray(),
                        'updated_at' => $user->updated_at->toISOString()
                    ]
                ],
                'message' => 'User updated successfully'
            ]);

        } catch (\Throwable $e) {
            DB::rollBack();

            Log::error('Failed to update user', [
                'user_id' => $userId,
                'error' => $e->getMessage(),
                'updated_by' => auth()->id()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to update user'
            ], 500);
        }
    }

    /**
     * Delete user.
     */
    public function destroy(int $userId): JsonResponse
    {
        try {
            $companyId = auth()->user()->company_id;
            $user = User::where('company_id', $companyId)->findOrFail($userId);

            // Prevent self-deletion
            if ($user->id === auth()->id()) {
                return response()->json([
                    'success' => false,
                    'message' => 'You cannot delete your own account'
                ], 403);
            }

            // Check if user has active control lists
            $activeControlLists = $user->controlLists()->whereIn('status', ['pending', 'in_progress'])->count();
            if ($activeControlLists > 0) {
                return response()->json([
                    'success' => false,
                    'message' => "User has {$activeControlLists} active control lists. Please reassign them before deletion."
                ], 422);
            }

            $userName = $user->name;
            $userEmail = $user->email;

            $user->delete();

            Log::warning('User deleted', [
                'deleted_user_id' => $userId,
                'deleted_user_name' => $userName,
                'deleted_user_email' => $userEmail,
                'deleted_by' => auth()->id()
            ]);

            return response()->json([
                'success' => true,
                'message' => 'User deleted successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to delete user', [
                'user_id' => $userId,
                'error' => $e->getMessage(),
                'deleted_by' => auth()->id()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }
    }

    /**
     * Get available roles.
     */
    public function getRoles(): JsonResponse
    {
        try {
            $roles = Role::all()->map(function ($role) {
                return [
                    'name' => $role->name,
                    'display_name' => ucwords(str_replace('_', ' ', $role->name)),
                    'users_count' => $role->users()->count()
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $roles,
                'message' => 'Roles retrieved successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to get roles', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve roles'
            ], 500);
        }
    }

    /**
     * Bulk update users.
     */
    public function bulkUpdate(BulkUpdateUsersRequest $request): JsonResponse
    {
        try {
            DB::beginTransaction();

            $companyId = auth()->user()->company_id;
            $userIds = $request->input('user_ids');
            $action = $request->input('action');
            $value = $request->input('value');

            $users = User::where('company_id', $companyId)
                ->whereIn('id', $userIds)
                ->where('id', '!=', auth()->id()) // Prevent self-modification
                ->get();

            if ($users->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'No valid users found for update'
                ], 422);
            }

            $updatedCount = 0;

            foreach ($users as $user) {
                switch ($action) {
                    case 'change_status':
                        $user->update(['status' => $value]);
                        $updatedCount++;
                        break;
                    case 'assign_role':
                        $user->syncRoles([$value]);
                        $updatedCount++;
                        break;
                }
            }

            DB::commit();

            Log::info('Bulk user update', [
                'action' => $action,
                'value' => $value,
                'user_ids' => $userIds,
                'updated_count' => $updatedCount,
                'updated_by' => auth()->id()
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'updated_count' => $updatedCount,
                    'action' => $action,
                    'value' => $value
                ],
                'message' => "Successfully updated {$updatedCount} users"
            ]);

        } catch (\Throwable $e) {
            DB::rollBack();

            Log::error('Failed to bulk update users', [
                'error' => $e->getMessage(),
                'updated_by' => auth()->id()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to update users'
            ], 500);
        }
    }

    /**
     * Send user invitation.
     */
    public function sendInvitation(SendInvitationRequest $request): JsonResponse
    {
        try {
            $email = $request->input('email');
            $role = $request->input('role', 'operator');
            $companyId = auth()->user()->company_id;

            // Check if user already exists
            $existingUser = User::where('email', $email)->first();
            if ($existingUser) {
                return response()->json([
                    'success' => false,
                    'message' => 'User with this email already exists'
                ], 422);
            }

            $invitationToken = \Str::random(64);

            // Store invitation in cache with expiration
            $invitationData = [
                'email' => $email,
                'role' => $role,
                'company_id' => $companyId,
                'invited_by' => auth()->id(),
                'expires_at' => now()->addDays(7)->toISOString()
            ];

            \Cache::put("invitation:{$invitationToken}", $invitationData, now()->addDays(7));

            // Send invitation email
            $this->emailService->sendUserInvitation(
                $email,
                $invitationToken,
                auth()->user(),
                $companyId,
                $role
            );

            Log::info('User invitation sent', [
                'email' => $email,
                'role' => $role,
                'invited_by' => auth()->id(),
                'token' => $invitationToken
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'email' => $email,
                    'role' => $role,
                    'expires_at' => $invitationData['expires_at']
                ],
                'message' => 'Invitation sent successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to send invitation', [
                'error' => $e->getMessage(),
                'invited_by' => auth()->id()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to send invitation'
            ], 500);
        }
    }

    /**
     * Calculate average completion time for user.
     */
    private function calculateAverageCompletionTime(User $user): ?float
    {
        $completedControlLists = $user->controlLists()
            ->where('status', 'completed')
            ->whereNotNull('completed_at')
            ->get(['created_at', 'completed_at']);

        if ($completedControlLists->isEmpty()) {
            return null;
        }

        $totalMinutes = $completedControlLists->sum(function ($cl) {
            return $cl->created_at->diffInMinutes($cl->completed_at);
        });

        return round($totalMinutes / $completedControlLists->count(), 2);
    }
}

// Request validation classes
class CreateUserRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->hasAnyRole(['admin', 'manager']);
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'nullable|string|max:20',
            'role' => 'required|in:admin,manager,supervisor,operator,maintenance_technician'
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'İsim gereklidir',
            'email.required' => 'E-posta gereklidir',
            'email.unique' => 'Bu e-posta adresi zaten kullanılıyor',
            'password.required' => 'Şifre gereklidir',
            'password.min' => 'Şifre en az 8 karakter olmalıdır',
            'password.confirmed' => 'Şifre onayı eşleşmiyor',
            'role.required' => 'Rol seçimi gereklidir'
        ];
    }
}

class UpdateUserRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->hasAnyRole(['admin', 'manager']);
    }

    public function rules(): array
    {
        $userId = $this->route('userId');

        return [
            'name' => 'sometimes|string|max:255',
            'email' => "sometimes|email|unique:users,email,{$userId}",
            'password' => 'sometimes|string|min:8|confirmed',
            'status' => 'sometimes|in:active,inactive,suspended',
            'role' => 'sometimes|in:admin,manager,supervisor,operator,maintenance_technician'
        ];
    }
}

class BulkUpdateUsersRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->hasAnyRole(['admin', 'manager']);
    }

    public function rules(): array
    {
        return [
            'user_ids' => 'required|array|min:1',
            'user_ids.*' => 'exists:users,id',
            'action' => 'required|in:change_status,assign_role',
            'value' => 'required|string'
        ];
    }
}

class SendInvitationRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->hasAnyRole(['admin', 'manager']);
    }

    public function rules(): array
    {
        return [
            'email' => 'required|email',
            'role' => 'required|in:admin,manager,supervisor,operator,maintenance_technician'
        ];
    }
}