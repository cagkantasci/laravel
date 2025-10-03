<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use App\Services\PushNotificationService;
use App\Http\Requests\BaseRequest;

class PushNotificationController extends Controller
{
    private PushNotificationService $pushNotificationService;

    public function __construct(PushNotificationService $pushNotificationService)
    {
        $this->pushNotificationService = $pushNotificationService;
    }

    /**
     * Register FCM token for user device.
     */
    public function registerToken(RegisterTokenRequest $request): JsonResponse
    {
        try {
            $result = $this->pushNotificationService->registerToken(
                auth()->id(),
                $request->input('fcm_token'),
                $request->input('platform'),
                $request->input('device_info', [])
            );

            return response()->json([
                'success' => $result['success'],
                'data' => $result,
                'message' => $result['message']
            ], $result['success'] ? 200 : 400);

        } catch (\Throwable $e) {
            Log::error('Failed to register FCM token', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to register token'
            ], 500);
        }
    }

    /**
     * Unregister FCM token.
     */
    public function unregisterToken(UnregisterTokenRequest $request): JsonResponse
    {
        try {
            $result = $this->pushNotificationService->unregisterToken(
                $request->input('fcm_token')
            );

            return response()->json([
                'success' => $result['success'],
                'message' => $result['message']
            ], $result['success'] ? 200 : 400);

        } catch (\Throwable $e) {
            Log::error('Failed to unregister FCM token', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to unregister token'
            ], 500);
        }
    }

    /**
     * Get user's registered devices.
     */
    public function getUserDevices(): JsonResponse
    {
        try {
            $result = $this->pushNotificationService->getUserDevices(auth()->id());

            return response()->json([
                'success' => $result['success'],
                'data' => $result['data'] ?? [],
                'message' => $result['message']
            ], $result['success'] ? 200 : 400);

        } catch (\Throwable $e) {
            Log::error('Failed to get user devices', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve devices'
            ], 500);
        }
    }

    /**
     * Send test notification to user.
     */
    public function sendTestNotification(): JsonResponse
    {
        try {
            $result = $this->pushNotificationService->testNotification(auth()->id());

            return response()->json([
                'success' => $result['success'],
                'data' => $result,
                'message' => $result['message']
            ], $result['success'] ? 200 : 400);

        } catch (\Throwable $e) {
            Log::error('Failed to send test notification', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to send test notification'
            ], 500);
        }
    }

    /**
     * Send notification to specific users (admin only).
     */
    public function sendNotificationToUsers(SendNotificationRequest $request): JsonResponse
    {
        try {
            $this->authorize('send_notifications');

            $result = $this->pushNotificationService->sendToUsers(
                $request->input('user_ids'),
                $request->input('title'),
                $request->input('body'),
                $request->input('data', []),
                $request->input('options', [])
            );

            return response()->json([
                'success' => $result['success'],
                'data' => $result,
                'message' => $result['message']
            ], $result['success'] ? 200 : 400);

        } catch (\Throwable $e) {
            Log::error('Failed to send notification to users', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to send notifications'
            ], 500);
        }
    }

    /**
     * Send notification to company (admin only).
     */
    public function sendNotificationToCompany(SendCompanyNotificationRequest $request): JsonResponse
    {
        try {
            $this->authorize('send_notifications');

            $companyId = auth()->user()->company_id;

            $result = $this->pushNotificationService->sendToCompany(
                $companyId,
                $request->input('title'),
                $request->input('body'),
                $request->input('data', []),
                $request->input('options', []),
                $request->input('exclude_user_ids', [])
            );

            return response()->json([
                'success' => $result['success'],
                'data' => $result,
                'message' => $result['message']
            ], $result['success'] ? 200 : 400);

        } catch (\Throwable $e) {
            Log::error('Failed to send notification to company', [
                'user_id' => auth()->id(),
                'company_id' => auth()->user()->company_id,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to send notifications'
            ], 500);
        }
    }

    /**
     * Send emergency notification (admin only).
     */
    public function sendEmergencyNotification(EmergencyNotificationRequest $request): JsonResponse
    {
        try {
            $this->authorize('send_emergency_notifications');

            $companyId = auth()->user()->company_id;

            $result = $this->pushNotificationService->sendEmergencyNotification(
                $companyId,
                $request->input('message'),
                $request->input('data', [])
            );

            return response()->json([
                'success' => $result['success'],
                'data' => $result,
                'message' => $result['message']
            ], $result['success'] ? 200 : 400);

        } catch (\Throwable $e) {
            Log::error('Failed to send emergency notification', [
                'user_id' => auth()->id(),
                'company_id' => auth()->user()->company_id,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to send emergency notification'
            ], 500);
        }
    }

    /**
     * Get notification statistics (admin only).
     */
    public function getNotificationStats(): JsonResponse
    {
        try {
            $this->authorize('view_notification_stats');

            $companyId = auth()->user()->company_id;

            // Get device statistics
            $deviceStats = \App\Models\UserDevice::whereHas('user', function($q) use ($companyId) {
                $q->where('company_id', $companyId);
            })->selectRaw('
                platform,
                COUNT(*) as total_devices,
                COUNT(CASE WHEN is_active = 1 THEN 1 END) as active_devices,
                COUNT(CASE WHEN fcm_token IS NOT NULL THEN 1 END) as devices_with_token
            ')->groupBy('platform')->get();

            $totalUsers = \App\Models\User::where('company_id', $companyId)->count();
            $usersWithDevices = \App\Models\User::where('company_id', $companyId)
                ->whereHas('devices', function($q) {
                    $q->where('is_active', true);
                })->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'device_stats' => $deviceStats,
                    'user_stats' => [
                        'total_users' => $totalUsers,
                        'users_with_devices' => $usersWithDevices,
                        'coverage_percentage' => $totalUsers > 0 ? round(($usersWithDevices / $totalUsers) * 100, 2) : 0
                    ]
                ],
                'message' => 'Notification statistics retrieved successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to get notification stats', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve notification statistics'
            ], 500);
        }
    }
}

// Request validation classes
class RegisterTokenRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'fcm_token' => 'required|string|min:10',
            'platform' => 'required|in:ios,android',
            'device_info' => 'nullable|array',
            'device_info.device_id' => 'nullable|string',
            'device_info.device_name' => 'nullable|string|max:255',
            'device_info.device_model' => 'nullable|string|max:255',
            'device_info.app_version' => 'nullable|string|max:50',
            'device_info.os_version' => 'nullable|string|max:50'
        ];
    }

    public function messages(): array
    {
        return [
            'fcm_token.required' => 'FCM token gereklidir',
            'fcm_token.min' => 'Geçerli bir FCM token sağlayın',
            'platform.required' => 'Platform bilgisi gereklidir',
            'platform.in' => 'Platform ios veya android olmalıdır'
        ];
    }
}

class UnregisterTokenRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'fcm_token' => 'required|string|min:10'
        ];
    }

    public function messages(): array
    {
        return [
            'fcm_token.required' => 'FCM token gereklidir'
        ];
    }
}

class SendNotificationRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->can('send_notifications');
    }

    public function rules(): array
    {
        return [
            'user_ids' => 'required|array|min:1',
            'user_ids.*' => 'exists:users,id',
            'title' => 'required|string|max:255',
            'body' => 'required|string|max:1000',
            'data' => 'nullable|array',
            'options' => 'nullable|array'
        ];
    }

    public function messages(): array
    {
        return [
            'user_ids.required' => 'En az bir kullanıcı seçmelisiniz',
            'user_ids.*.exists' => 'Seçilen kullanıcı geçerli değil',
            'title.required' => 'Bildirim başlığı gereklidir',
            'body.required' => 'Bildirim içeriği gereklidir'
        ];
    }
}

class SendCompanyNotificationRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->can('send_notifications');
    }

    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'body' => 'required|string|max:1000',
            'data' => 'nullable|array',
            'options' => 'nullable|array',
            'exclude_user_ids' => 'nullable|array',
            'exclude_user_ids.*' => 'exists:users,id'
        ];
    }
}

class EmergencyNotificationRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->can('send_emergency_notifications');
    }

    public function rules(): array
    {
        return [
            'message' => 'required|string|max:500',
            'data' => 'nullable|array'
        ];
    }

    public function messages(): array
    {
        return [
            'message.required' => 'Acil durum mesajı gereklidir',
            'message.max' => 'Acil durum mesajı en fazla 500 karakter olabilir'
        ];
    }
}