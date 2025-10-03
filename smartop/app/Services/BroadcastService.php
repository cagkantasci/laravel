<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use App\Events\MachineStatusChanged;
use App\Events\ControlListStatusUpdated;
use App\Events\RealTimeNotification;
use App\Events\UserPresenceUpdated;
use App\Models\User;
use App\Models\Machine;
use App\Models\ControlList;

class BroadcastService
{
    /**
     * Broadcast machine status change.
     */
    public function broadcastMachineStatusChange(
        Machine $machine,
        string $oldStatus,
        string $newStatus,
        array $metadata = []
    ): void {
        try {
            event(new MachineStatusChanged($machine, $oldStatus, $newStatus, $metadata));

            Log::info('Machine status change broadcasted', [
                'machine_id' => $machine->id,
                'old_status' => $oldStatus,
                'new_status' => $newStatus
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to broadcast machine status change', [
                'machine_id' => $machine->id,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Broadcast control list status update.
     */
    public function broadcastControlListStatusUpdate(
        ControlList $controlList,
        string $oldStatus,
        string $newStatus,
        ?int $updatedBy = null,
        array $metadata = []
    ): void {
        try {
            event(new ControlListStatusUpdated(
                $controlList,
                $oldStatus,
                $newStatus,
                $updatedBy,
                $metadata
            ));

            Log::info('Control list status update broadcasted', [
                'control_list_id' => $controlList->id,
                'old_status' => $oldStatus,
                'new_status' => $newStatus,
                'updated_by' => $updatedBy
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to broadcast control list status update', [
                'control_list_id' => $controlList->id,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Send real-time notification to user.
     */
    public function sendNotificationToUser(
        int $userId,
        string $type,
        string $title,
        string $message,
        array $data = [],
        string $priority = 'normal'
    ): void {
        try {
            event(new RealTimeNotification($userId, $type, $title, $message, $data, $priority));

            Log::info('Real-time notification sent', [
                'user_id' => $userId,
                'type' => $type,
                'priority' => $priority
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to send real-time notification', [
                'user_id' => $userId,
                'type' => $type,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Broadcast user presence update.
     */
    public function broadcastUserPresenceUpdate(
        User $user,
        string $status,
        array $metadata = []
    ): void {
        try {
            event(new UserPresenceUpdated($user, $status, $metadata));

            Log::debug('User presence update broadcasted', [
                'user_id' => $user->id,
                'status' => $status
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to broadcast user presence update', [
                'user_id' => $user->id,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Broadcast dashboard data update.
     */
    public function broadcastDashboardUpdate(int $companyId, array $data): void
    {
        try {
            broadcast(new \App\Events\DashboardDataUpdated($companyId, $data));

            Log::info('Dashboard update broadcasted', [
                'company_id' => $companyId,
                'data_keys' => array_keys($data)
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to broadcast dashboard update', [
                'company_id' => $companyId,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Broadcast emergency alert.
     */
    public function broadcastEmergencyAlert(
        int $companyId,
        string $type,
        string $message,
        array $data = []
    ): void {
        try {
            $alertData = [
                'type' => $type,
                'message' => $message,
                'severity' => 'critical',
                'data' => $data,
                'timestamp' => now()->toISOString(),
                'requires_acknowledgment' => true
            ];

            broadcast(new \App\Events\EmergencyAlert($companyId, $alertData))
                ->toOthers();

            Log::warning('Emergency alert broadcasted', [
                'company_id' => $companyId,
                'type' => $type,
                'message' => $message
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to broadcast emergency alert', [
                'company_id' => $companyId,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Broadcast system maintenance notification.
     */
    public function broadcastSystemMaintenance(
        string $message,
        \DateTime $scheduledTime,
        int $estimatedDuration
    ): void {
        try {
            $maintenanceData = [
                'message' => $message,
                'scheduled_time' => $scheduledTime->format('c'),
                'estimated_duration' => $estimatedDuration,
                'type' => 'system_maintenance',
                'timestamp' => now()->toISOString()
            ];

            broadcast(new \App\Events\SystemMaintenance($maintenanceData));

            Log::info('System maintenance notification broadcasted', [
                'scheduled_time' => $scheduledTime->format('c'),
                'duration' => $estimatedDuration
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to broadcast system maintenance', [
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Broadcast report generation progress.
     */
    public function broadcastReportProgress(
        int $userId,
        string $reportId,
        int $progress,
        string $status = 'generating'
    ): void {
        try {
            $progressData = [
                'report_id' => $reportId,
                'progress' => $progress,
                'status' => $status,
                'timestamp' => now()->toISOString()
            ];

            $this->sendNotificationToUser(
                $userId,
                'report_progress',
                'Report Generation Progress',
                "Report generation is {$progress}% complete",
                $progressData,
                'low'
            );

        } catch (\Throwable $e) {
            Log::error('Failed to broadcast report progress', [
                'user_id' => $userId,
                'report_id' => $reportId,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Broadcast team chat message.
     */
    public function broadcastChatMessage(
        int $companyId,
        User $sender,
        string $message,
        array $metadata = []
    ): void {
        try {
            $chatData = [
                'sender' => [
                    'id' => $sender->id,
                    'name' => $sender->name,
                    'avatar' => $sender->profile_photo,
                    'role' => $sender->roles->first()?->name
                ],
                'message' => $message,
                'metadata' => $metadata,
                'timestamp' => now()->toISOString()
            ];

            broadcast(new \App\Events\ChatMessage($companyId, $chatData));

            Log::info('Chat message broadcasted', [
                'company_id' => $companyId,
                'sender_id' => $sender->id,
                'message_length' => strlen($message)
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to broadcast chat message', [
                'company_id' => $companyId,
                'sender_id' => $sender->id,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Broadcast bulk operation progress.
     */
    public function broadcastBulkOperationProgress(
        int $userId,
        string $operationType,
        int $processed,
        int $total,
        array $errors = []
    ): void {
        try {
            $progress = $total > 0 ? round(($processed / $total) * 100, 2) : 0;

            $progressData = [
                'operation_type' => $operationType,
                'processed' => $processed,
                'total' => $total,
                'progress' => $progress,
                'errors_count' => count($errors),
                'errors' => array_slice($errors, -5), // Last 5 errors
                'timestamp' => now()->toISOString()
            ];

            $this->sendNotificationToUser(
                $userId,
                'bulk_operation_progress',
                'Bulk Operation Progress',
                "{$operationType} operation is {$progress}% complete ({$processed}/{$total})",
                $progressData,
                'low'
            );

        } catch (\Throwable $e) {
            Log::error('Failed to broadcast bulk operation progress', [
                'user_id' => $userId,
                'operation_type' => $operationType,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Test broadcasting connectivity.
     */
    public function testBroadcast(): array
    {
        try {
            $testData = [
                'message' => 'Broadcasting test successful',
                'timestamp' => now()->toISOString(),
                'test_id' => uniqid('test_')
            ];

            broadcast(new \App\Events\TestBroadcast($testData));

            return [
                'success' => true,
                'message' => 'Test broadcast sent successfully',
                'data' => $testData
            ];

        } catch (\Throwable $e) {
            Log::error('Broadcast test failed', ['error' => $e->getMessage()]);

            return [
                'success' => false,
                'message' => 'Broadcast test failed: ' . $e->getMessage()
            ];
        }
    }
}