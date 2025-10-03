<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use App\Models\User;
use App\Models\UserDevice;

class PushNotificationService
{
    private string $fcmServerKey;
    private string $fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    public function __construct()
    {
        $this->fcmServerKey = config('services.fcm.server_key', '');
    }

    /**
     * Send push notification to a single user.
     */
    public function sendToUser(
        int $userId,
        string $title,
        string $body,
        array $data = [],
        array $options = []
    ): array {
        try {
            $user = User::find($userId);
            if (!$user) {
                throw new \Exception("User not found: {$userId}");
            }

            $devices = UserDevice::where('user_id', $userId)
                ->where('is_active', true)
                ->whereNotNull('fcm_token')
                ->get();

            if ($devices->isEmpty()) {
                Log::warning('No active devices found for user', ['user_id' => $userId]);
                return [
                    'success' => false,
                    'message' => 'No active devices found for user',
                    'sent_count' => 0
                ];
            }

            $tokens = $devices->pluck('fcm_token')->toArray();
            return $this->sendToTokens($tokens, $title, $body, $data, $options);

        } catch (\Throwable $e) {
            Log::error('Failed to send push notification to user', [
                'user_id' => $userId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send notification: ' . $e->getMessage(),
                'sent_count' => 0
            ];
        }
    }

    /**
     * Send push notification to multiple users.
     */
    public function sendToUsers(
        array $userIds,
        string $title,
        string $body,
        array $data = [],
        array $options = []
    ): array {
        try {
            $devices = UserDevice::whereIn('user_id', $userIds)
                ->where('is_active', true)
                ->whereNotNull('fcm_token')
                ->get();

            if ($devices->isEmpty()) {
                Log::warning('No active devices found for users', ['user_ids' => $userIds]);
                return [
                    'success' => false,
                    'message' => 'No active devices found for users',
                    'sent_count' => 0
                ];
            }

            $tokens = $devices->pluck('fcm_token')->unique()->toArray();
            return $this->sendToTokens($tokens, $title, $body, $data, $options);

        } catch (\Throwable $e) {
            Log::error('Failed to send push notification to users', [
                'user_ids' => $userIds,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send notifications: ' . $e->getMessage(),
                'sent_count' => 0
            ];
        }
    }

    /**
     * Send push notification to company users.
     */
    public function sendToCompany(
        int $companyId,
        string $title,
        string $body,
        array $data = [],
        array $options = [],
        array $excludeUserIds = []
    ): array {
        try {
            $query = UserDevice::whereHas('user', function($q) use ($companyId) {
                $q->where('company_id', $companyId);
            })->where('is_active', true)->whereNotNull('fcm_token');

            if (!empty($excludeUserIds)) {
                $query->whereNotIn('user_id', $excludeUserIds);
            }

            $devices = $query->get();

            if ($devices->isEmpty()) {
                Log::warning('No active devices found for company', ['company_id' => $companyId]);
                return [
                    'success' => false,
                    'message' => 'No active devices found for company',
                    'sent_count' => 0
                ];
            }

            $tokens = $devices->pluck('fcm_token')->unique()->toArray();
            return $this->sendToTokens($tokens, $title, $body, $data, $options);

        } catch (\Throwable $e) {
            Log::error('Failed to send push notification to company', [
                'company_id' => $companyId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send notifications: ' . $e->getMessage(),
                'sent_count' => 0
            ];
        }
    }

    /**
     * Send push notification to specific FCM tokens.
     */
    public function sendToTokens(
        array $tokens,
        string $title,
        string $body,
        array $data = [],
        array $options = []
    ): array {
        try {
            if (empty($tokens)) {
                throw new \Exception('No FCM tokens provided');
            }

            if (empty($this->fcmServerKey)) {
                throw new \Exception('FCM server key not configured');
            }

            $payload = $this->buildPayload($tokens, $title, $body, $data, $options);
            $response = $this->sendFcmRequest($payload);

            $successCount = $response['success'] ?? 0;
            $failureCount = $response['failure'] ?? 0;

            Log::info('Push notification sent', [
                'tokens_count' => count($tokens),
                'success_count' => $successCount,
                'failure_count' => $failureCount
            ]);

            // Handle invalid tokens
            if (isset($response['results'])) {
                $this->handleInvalidTokens($tokens, $response['results']);
            }

            return [
                'success' => true,
                'message' => 'Notifications sent successfully',
                'sent_count' => $successCount,
                'failed_count' => $failureCount,
                'total_tokens' => count($tokens)
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to send push notifications', [
                'tokens_count' => count($tokens),
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send notifications: ' . $e->getMessage(),
                'sent_count' => 0
            ];
        }
    }

    /**
     * Send emergency notification.
     */
    public function sendEmergencyNotification(
        int $companyId,
        string $message,
        array $data = []
    ): array {
        $options = [
            'priority' => 'high',
            'sound' => 'emergency',
            'badge' => 1,
            'android' => [
                'priority' => 'high',
                'notification' => [
                    'channel_id' => 'emergency',
                    'sound' => 'emergency'
                ]
            ],
            'apns' => [
                'payload' => [
                    'aps' => [
                        'sound' => 'emergency.wav',
                        'badge' => 1
                    ]
                ]
            ]
        ];

        return $this->sendToCompany(
            $companyId,
            'EMERGENCY ALERT',
            $message,
            array_merge($data, ['type' => 'emergency']),
            $options
        );
    }

    /**
     * Send machine status notification.
     */
    public function sendMachineStatusNotification(
        int $companyId,
        string $machineName,
        string $status,
        array $data = []
    ): array {
        $title = 'Machine Status Update';
        $body = "Machine {$machineName} status changed to {$status}";

        $options = [
            'priority' => $status === 'failed' ? 'high' : 'normal',
            'android' => [
                'notification' => [
                    'channel_id' => 'machine_status'
                ]
            ]
        ];

        return $this->sendToCompany(
            $companyId,
            $title,
            $body,
            array_merge($data, ['type' => 'machine_status']),
            $options
        );
    }

    /**
     * Send control list notification.
     */
    public function sendControlListNotification(
        int $userId,
        string $action,
        string $machineCode,
        array $data = []
    ): array {
        $titles = [
            'assigned' => 'New Control List Assigned',
            'completed' => 'Control List Completed',
            'failed' => 'Control List Failed'
        ];

        $bodies = [
            'assigned' => "You have been assigned a new control list for machine {$machineCode}",
            'completed' => "Control list for machine {$machineCode} has been completed",
            'failed' => "Control list for machine {$machineCode} has failed"
        ];

        $title = $titles[$action] ?? 'Control List Update';
        $body = $bodies[$action] ?? "Control list update for machine {$machineCode}";

        $options = [
            'priority' => $action === 'assigned' ? 'high' : 'normal',
            'android' => [
                'notification' => [
                    'channel_id' => 'control_lists'
                ]
            ]
        ];

        return $this->sendToUser(
            $userId,
            $title,
            $body,
            array_merge($data, ['type' => 'control_list', 'action' => $action]),
            $options
        );
    }

    /**
     * Build FCM payload.
     */
    private function buildPayload(
        array $tokens,
        string $title,
        string $body,
        array $data = [],
        array $options = []
    ): array {
        $payload = [
            'registration_ids' => $tokens,
            'notification' => [
                'title' => $title,
                'body' => $body,
                'sound' => $options['sound'] ?? 'default',
                'badge' => $options['badge'] ?? 1
            ],
            'data' => array_merge($data, [
                'timestamp' => now()->toISOString(),
                'click_action' => $options['click_action'] ?? 'FLUTTER_NOTIFICATION_CLICK'
            ]),
            'priority' => $options['priority'] ?? 'normal'
        ];

        // Android specific options
        if (isset($options['android'])) {
            $payload['android'] = $options['android'];
        }

        // iOS specific options
        if (isset($options['apns'])) {
            $payload['apns'] = $options['apns'];
        }

        return $payload;
    }

    /**
     * Send FCM request.
     */
    private function sendFcmRequest(array $payload): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'key=' . $this->fcmServerKey,
            'Content-Type' => 'application/json'
        ])->post($this->fcmUrl, $payload);

        if (!$response->successful()) {
            throw new \Exception('FCM request failed: ' . $response->body());
        }

        return $response->json();
    }

    /**
     * Handle invalid FCM tokens.
     */
    private function handleInvalidTokens(array $tokens, array $results): void
    {
        $invalidTokens = [];

        foreach ($results as $index => $result) {
            if (isset($result['error'])) {
                $error = $result['error'];
                if (in_array($error, ['InvalidRegistration', 'NotRegistered'])) {
                    $invalidTokens[] = $tokens[$index];
                }
            }
        }

        if (!empty($invalidTokens)) {
            UserDevice::whereIn('fcm_token', $invalidTokens)
                ->update(['is_active' => false, 'updated_at' => now()]);

            Log::info('Deactivated invalid FCM tokens', [
                'count' => count($invalidTokens),
                'tokens' => $invalidTokens
            ]);
        }
    }

    /**
     * Register FCM token for user device.
     */
    public function registerToken(
        int $userId,
        string $fcmToken,
        string $platform,
        array $deviceInfo = []
    ): array {
        try {
            $device = UserDevice::updateOrCreate(
                [
                    'user_id' => $userId,
                    'device_id' => $deviceInfo['device_id'] ?? null,
                    'platform' => $platform
                ],
                [
                    'fcm_token' => $fcmToken,
                    'device_name' => $deviceInfo['device_name'] ?? null,
                    'device_model' => $deviceInfo['device_model'] ?? null,
                    'app_version' => $deviceInfo['app_version'] ?? null,
                    'os_version' => $deviceInfo['os_version'] ?? null,
                    'is_active' => true,
                    'last_used_at' => now()
                ]
            );

            Log::info('FCM token registered', [
                'user_id' => $userId,
                'device_id' => $device->id,
                'platform' => $platform
            ]);

            return [
                'success' => true,
                'message' => 'Token registered successfully',
                'device_id' => $device->id
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to register FCM token', [
                'user_id' => $userId,
                'platform' => $platform,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to register token: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Unregister FCM token.
     */
    public function unregisterToken(string $fcmToken): array
    {
        try {
            $updated = UserDevice::where('fcm_token', $fcmToken)
                ->update(['is_active' => false, 'updated_at' => now()]);

            Log::info('FCM token unregistered', [
                'token' => substr($fcmToken, 0, 10) . '...',
                'devices_updated' => $updated
            ]);

            return [
                'success' => true,
                'message' => 'Token unregistered successfully'
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to unregister FCM token', [
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to unregister token: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Get user's active devices.
     */
    public function getUserDevices(int $userId): array
    {
        try {
            $devices = UserDevice::where('user_id', $userId)
                ->where('is_active', true)
                ->orderBy('last_used_at', 'desc')
                ->get()
                ->map(function ($device) {
                    return [
                        'id' => $device->id,
                        'device_name' => $device->device_name,
                        'device_model' => $device->device_model,
                        'platform' => $device->platform,
                        'app_version' => $device->app_version,
                        'os_version' => $device->os_version,
                        'last_used_at' => $device->last_used_at?->toISOString(),
                        'registered_at' => $device->created_at->toISOString()
                    ];
                });

            return [
                'success' => true,
                'data' => $devices,
                'message' => 'User devices retrieved successfully'
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to get user devices', [
                'user_id' => $userId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to retrieve devices: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Test push notification.
     */
    public function testNotification(int $userId): array
    {
        return $this->sendToUser(
            $userId,
            'Test Notification',
            'This is a test notification from SmartOP system.',
            ['type' => 'test', 'test_id' => uniqid()],
            ['priority' => 'normal']
        );
    }
}