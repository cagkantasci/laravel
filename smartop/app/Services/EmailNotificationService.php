<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Collection;
use App\Models\User;
use App\Models\Machine;
use App\Models\ControlList;
use App\Mail\MachineStatusNotification;
use App\Mail\ControlListAssignedNotification;
use App\Mail\ControlListCompletedNotification;
use App\Mail\EmergencyAlertNotification;
use App\Mail\MaintenanceReminderNotification;
use App\Mail\WeeklyReportNotification;
use App\Mail\UserInvitationNotification;
use App\Mail\WelcomeNotification;
use App\Jobs\SendEmailJob;

class EmailNotificationService
{
    /**
     * Send machine status change notification.
     */
    public function sendMachineStatusNotification(
        Machine $machine,
        string $oldStatus,
        string $newStatus,
        array $recipients = []
    ): array {
        try {
            if (empty($recipients)) {
                $recipients = $this->getCompanyAdmins($machine->company_id);
            }

            $emailData = [
                'machine' => $machine,
                'old_status' => $oldStatus,
                'new_status' => $newStatus,
                'timestamp' => now()
            ];

            foreach ($recipients as $recipient) {
                SendEmailJob::dispatch(
                    $recipient,
                    MachineStatusNotification::class,
                    $emailData,
                    'machine_status'
                )->onQueue('emails');
            }

            Log::info('Machine status email notifications queued', [
                'machine_id' => $machine->id,
                'recipients_count' => count($recipients),
                'old_status' => $oldStatus,
                'new_status' => $newStatus
            ]);

            return [
                'success' => true,
                'message' => 'Machine status notifications sent successfully',
                'recipients_count' => count($recipients)
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to send machine status notification', [
                'machine_id' => $machine->id,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send machine status notifications: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Send control list assigned notification.
     */
    public function sendControlListAssignedNotification(
        ControlList $controlList,
        User $assignedUser
    ): array {
        try {
            $emailData = [
                'control_list' => $controlList,
                'machine' => $controlList->machine,
                'assigned_user' => $assignedUser,
                'due_date' => $controlList->due_date,
                'priority' => $controlList->priority ?? 'normal'
            ];

            SendEmailJob::dispatch(
                $assignedUser->email,
                ControlListAssignedNotification::class,
                $emailData,
                'control_list'
            )->onQueue('emails');

            // Also notify supervisors
            $supervisors = $this->getCompanySupervisors($controlList->machine->company_id);
            foreach ($supervisors as $supervisor) {
                if ($supervisor !== $assignedUser->email) {
                    SendEmailJob::dispatch(
                        $supervisor,
                        ControlListAssignedNotification::class,
                        $emailData,
                        'control_list'
                    )->onQueue('emails');
                }
            }

            Log::info('Control list assigned email notification queued', [
                'control_list_id' => $controlList->id,
                'assigned_user_id' => $assignedUser->id,
                'machine_id' => $controlList->machine_id
            ]);

            return [
                'success' => true,
                'message' => 'Control list assignment notification sent successfully'
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to send control list assigned notification', [
                'control_list_id' => $controlList->id,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send control list assignment notification: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Send control list completed notification.
     */
    public function sendControlListCompletedNotification(
        ControlList $controlList,
        User $completedBy
    ): array {
        try {
            $emailData = [
                'control_list' => $controlList,
                'machine' => $controlList->machine,
                'completed_by' => $completedBy,
                'completed_at' => $controlList->completed_at,
                'completion_time' => $controlList->created_at->diffInMinutes($controlList->completed_at),
                'items_count' => $controlList->controlItems->count(),
                'passed_items' => $controlList->controlItems->where('status', 'completed')->count()
            ];

            // Notify supervisors and managers
            $supervisors = $this->getCompanySupervisors($controlList->machine->company_id);
            foreach ($supervisors as $supervisor) {
                SendEmailJob::dispatch(
                    $supervisor,
                    ControlListCompletedNotification::class,
                    $emailData,
                    'control_list'
                )->onQueue('emails');
            }

            Log::info('Control list completed email notification queued', [
                'control_list_id' => $controlList->id,
                'completed_by_id' => $completedBy->id,
                'machine_id' => $controlList->machine_id
            ]);

            return [
                'success' => true,
                'message' => 'Control list completion notification sent successfully'
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to send control list completed notification', [
                'control_list_id' => $controlList->id,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send control list completion notification: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Send emergency alert notification.
     */
    public function sendEmergencyAlertNotification(
        int $companyId,
        string $alertType,
        string $message,
        array $data = []
    ): array {
        try {
            $recipients = $this->getAllCompanyUsers($companyId);

            $emailData = [
                'alert_type' => $alertType,
                'message' => $message,
                'data' => $data,
                'timestamp' => now(),
                'severity' => 'critical'
            ];

            foreach ($recipients as $recipient) {
                SendEmailJob::dispatch(
                    $recipient,
                    EmergencyAlertNotification::class,
                    $emailData,
                    'emergency'
                )->onQueue('high-priority');
            }

            Log::warning('Emergency alert email notifications queued', [
                'company_id' => $companyId,
                'alert_type' => $alertType,
                'recipients_count' => count($recipients)
            ]);

            return [
                'success' => true,
                'message' => 'Emergency alert notifications sent successfully',
                'recipients_count' => count($recipients)
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to send emergency alert notification', [
                'company_id' => $companyId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send emergency alert notifications: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Send maintenance reminder notifications.
     */
    public function sendMaintenanceReminders(): array
    {
        try {
            $upcomingMaintenance = Machine::where('next_maintenance_date', '<=', now()->addDays(7))
                ->where('next_maintenance_date', '>=', now())
                ->with('company')
                ->get();

            $notificationsSent = 0;

            foreach ($upcomingMaintenance as $machine) {
                $recipients = $this->getMaintenanceTeam($machine->company_id);

                $emailData = [
                    'machine' => $machine,
                    'maintenance_date' => $machine->next_maintenance_date,
                    'days_until_maintenance' => now()->diffInDays($machine->next_maintenance_date),
                    'maintenance_type' => $machine->maintenance_type ?? 'General Maintenance'
                ];

                foreach ($recipients as $recipient) {
                    SendEmailJob::dispatch(
                        $recipient,
                        MaintenanceReminderNotification::class,
                        $emailData,
                        'maintenance'
                    )->onQueue('emails');
                    $notificationsSent++;
                }
            }

            Log::info('Maintenance reminder notifications sent', [
                'machines_count' => $upcomingMaintenance->count(),
                'notifications_sent' => $notificationsSent
            ]);

            return [
                'success' => true,
                'message' => 'Maintenance reminders sent successfully',
                'machines_count' => $upcomingMaintenance->count(),
                'notifications_sent' => $notificationsSent
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to send maintenance reminders', [
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send maintenance reminders: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Send weekly report notification.
     */
    public function sendWeeklyReport(int $companyId): array
    {
        try {
            $recipients = $this->getCompanyManagers($companyId);

            // Collect weekly statistics
            $weekStart = now()->startOfWeek();
            $weekEnd = now()->endOfWeek();

            $statistics = [
                'period' => [
                    'start' => $weekStart->format('Y-m-d'),
                    'end' => $weekEnd->format('Y-m-d')
                ],
                'machines' => [
                    'total' => Machine::where('company_id', $companyId)->count(),
                    'active' => Machine::where('company_id', $companyId)->where('status', 'active')->count(),
                    'maintenance' => Machine::where('company_id', $companyId)->where('status', 'maintenance')->count()
                ],
                'control_lists' => [
                    'total' => ControlList::whereHas('machine', function($q) use ($companyId) {
                        $q->where('company_id', $companyId);
                    })->whereBetween('created_at', [$weekStart, $weekEnd])->count(),
                    'completed' => ControlList::whereHas('machine', function($q) use ($companyId) {
                        $q->where('company_id', $companyId);
                    })->whereBetween('created_at', [$weekStart, $weekEnd])
                      ->where('status', 'completed')->count(),
                    'pending' => ControlList::whereHas('machine', function($q) use ($companyId) {
                        $q->where('company_id', $companyId);
                    })->whereBetween('created_at', [$weekStart, $weekEnd])
                      ->where('status', 'pending')->count()
                ]
            ];

            $emailData = [
                'company_id' => $companyId,
                'statistics' => $statistics,
                'period' => "Week of " . $weekStart->format('M d, Y')
            ];

            foreach ($recipients as $recipient) {
                SendEmailJob::dispatch(
                    $recipient,
                    WeeklyReportNotification::class,
                    $emailData,
                    'reports'
                )->onQueue('emails');
            }

            Log::info('Weekly report notifications queued', [
                'company_id' => $companyId,
                'recipients_count' => count($recipients)
            ]);

            return [
                'success' => true,
                'message' => 'Weekly report notifications sent successfully',
                'recipients_count' => count($recipients)
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to send weekly report', [
                'company_id' => $companyId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send weekly report: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Send user invitation notification.
     */
    public function sendUserInvitation(
        string $email,
        string $invitationToken,
        User $invitedBy,
        int $companyId,
        string $role = 'user'
    ): array {
        try {
            $emailData = [
                'email' => $email,
                'invitation_token' => $invitationToken,
                'invited_by' => $invitedBy,
                'company_id' => $companyId,
                'role' => $role,
                'invitation_url' => config('app.frontend_url') . "/invitation/{$invitationToken}",
                'expires_at' => now()->addDays(7)
            ];

            SendEmailJob::dispatch(
                $email,
                UserInvitationNotification::class,
                $emailData,
                'invitations'
            )->onQueue('emails');

            Log::info('User invitation email queued', [
                'email' => $email,
                'invited_by' => $invitedBy->id,
                'company_id' => $companyId,
                'role' => $role
            ]);

            return [
                'success' => true,
                'message' => 'User invitation sent successfully'
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to send user invitation', [
                'email' => $email,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send user invitation: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Send welcome notification to new user.
     */
    public function sendWelcomeNotification(User $user): array
    {
        try {
            $emailData = [
                'user' => $user,
                'company' => $user->company,
                'login_url' => config('app.frontend_url') . '/login',
                'support_email' => config('mail.support_email', 'support@smartop.com')
            ];

            SendEmailJob::dispatch(
                $user->email,
                WelcomeNotification::class,
                $emailData,
                'welcome'
            )->onQueue('emails');

            Log::info('Welcome email queued', [
                'user_id' => $user->id,
                'email' => $user->email
            ]);

            return [
                'success' => true,
                'message' => 'Welcome notification sent successfully'
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to send welcome notification', [
                'user_id' => $user->id,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send welcome notification: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Get company administrators.
     */
    private function getCompanyAdmins(int $companyId): array
    {
        return User::where('company_id', $companyId)
            ->whereHas('roles', function($q) {
                $q->whereIn('name', ['admin', 'manager']);
            })
            ->where('status', 'active')
            ->pluck('email')
            ->toArray();
    }

    /**
     * Get company supervisors.
     */
    private function getCompanySupervisors(int $companyId): array
    {
        return User::where('company_id', $companyId)
            ->whereHas('roles', function($q) {
                $q->whereIn('name', ['admin', 'manager', 'supervisor']);
            })
            ->where('status', 'active')
            ->pluck('email')
            ->toArray();
    }

    /**
     * Get company managers.
     */
    private function getCompanyManagers(int $companyId): array
    {
        return User::where('company_id', $companyId)
            ->whereHas('roles', function($q) {
                $q->whereIn('name', ['admin', 'manager']);
            })
            ->where('status', 'active')
            ->pluck('email')
            ->toArray();
    }

    /**
     * Get maintenance team members.
     */
    private function getMaintenanceTeam(int $companyId): array
    {
        return User::where('company_id', $companyId)
            ->whereHas('roles', function($q) {
                $q->whereIn('name', ['admin', 'manager', 'maintenance_technician']);
            })
            ->where('status', 'active')
            ->pluck('email')
            ->toArray();
    }

    /**
     * Get all company users.
     */
    private function getAllCompanyUsers(int $companyId): array
    {
        return User::where('company_id', $companyId)
            ->where('status', 'active')
            ->pluck('email')
            ->toArray();
    }

    /**
     * Test email notification.
     */
    public function sendTestEmail(string $email): array
    {
        try {
            $emailData = [
                'message' => 'This is a test email from SmartOP system.',
                'timestamp' => now(),
                'test_id' => uniqid('test_')
            ];

            Mail::to($email)->send(new \App\Mail\TestNotification($emailData));

            Log::info('Test email sent', ['email' => $email]);

            return [
                'success' => true,
                'message' => 'Test email sent successfully'
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to send test email', [
                'email' => $email,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to send test email: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Get email statistics.
     */
    public function getEmailStatistics(int $companyId, int $days = 30): array
    {
        try {
            $dateFrom = now()->subDays($days);

            // This would typically come from a dedicated email logs table
            // For now, we'll return a placeholder structure
            return [
                'success' => true,
                'data' => [
                    'period' => [
                        'from' => $dateFrom->format('Y-m-d'),
                        'to' => now()->format('Y-m-d'),
                        'days' => $days
                    ],
                    'statistics' => [
                        'total_sent' => 0, // Would count from email logs
                        'delivered' => 0,
                        'bounced' => 0,
                        'failed' => 0,
                        'delivery_rate' => 0
                    ],
                    'by_type' => [
                        'machine_status' => 0,
                        'control_list' => 0,
                        'emergency' => 0,
                        'maintenance' => 0,
                        'reports' => 0,
                        'invitations' => 0
                    ]
                ],
                'message' => 'Email statistics retrieved successfully'
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to get email statistics', [
                'company_id' => $companyId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Failed to retrieve email statistics: ' . $e->getMessage()
            ];
        }
    }
}