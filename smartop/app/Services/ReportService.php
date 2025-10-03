<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Collection;
use App\Models\Machine;
use App\Models\ControlList;
use App\Models\User;
use App\Models\Company;
use Dompdf\Dompdf;
use Dompdf\Options;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\MachineReportExport;
use App\Exports\ControlListReportExport;
use App\Exports\UserActivityReportExport;
use Carbon\Carbon;

class ReportService
{
    private BroadcastService $broadcastService;

    public function __construct(BroadcastService $broadcastService)
    {
        $this->broadcastService = $broadcastService;
    }

    /**
     * Generate machine performance report.
     */
    public function generateMachineReport(
        int $companyId,
        array $machineIds = [],
        string $dateFrom = null,
        string $dateTo = null,
        string $format = 'pdf',
        ?int $userId = null
    ): array {
        try {
            $reportId = uniqid('machine_report_');

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 10, 'starting');
            }

            $dateFrom = $dateFrom ? Carbon::parse($dateFrom) : Carbon::now()->subMonth();
            $dateTo = $dateTo ? Carbon::parse($dateTo) : Carbon::now();

            $query = Machine::where('company_id', $companyId)
                ->with(['controlLists' => function($q) use ($dateFrom, $dateTo) {
                    $q->whereBetween('created_at', [$dateFrom, $dateTo])
                      ->with('controlItems');
                }]);

            if (!empty($machineIds)) {
                $query->whereIn('id', $machineIds);
            }

            $machines = $query->get();

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 30, 'collecting_data');
            }

            $reportData = $this->compileMachineReportData($machines, $dateFrom, $dateTo);

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 60, 'generating_document');
            }

            $filePath = $format === 'pdf'
                ? $this->generateMachineReportPDF($reportData, $reportId)
                : $this->generateMachineReportExcel($reportData, $reportId);

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 100, 'completed');
            }

            Log::info('Machine report generated successfully', [
                'company_id' => $companyId,
                'report_id' => $reportId,
                'format' => $format,
                'machines_count' => count($machines)
            ]);

            return [
                'success' => true,
                'report_id' => $reportId,
                'file_path' => $filePath,
                'format' => $format,
                'generated_at' => now()->toISOString(),
                'data_summary' => [
                    'machines_count' => count($machines),
                    'period' => [
                        'from' => $dateFrom->format('Y-m-d'),
                        'to' => $dateTo->format('Y-m-d')
                    ]
                ]
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to generate machine report', [
                'company_id' => $companyId,
                'error' => $e->getMessage()
            ]);

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId ?? 'unknown', 0, 'failed');
            }

            return [
                'success' => false,
                'message' => 'Report generation failed: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Generate control list compliance report.
     */
    public function generateControlListReport(
        int $companyId,
        array $filters = [],
        string $format = 'pdf',
        ?int $userId = null
    ): array {
        try {
            $reportId = uniqid('control_report_');

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 10, 'starting');
            }

            $dateFrom = isset($filters['date_from']) ? Carbon::parse($filters['date_from']) : Carbon::now()->subMonth();
            $dateTo = isset($filters['date_to']) ? Carbon::parse($filters['date_to']) : Carbon::now();

            $query = ControlList::whereHas('machine', function($q) use ($companyId) {
                $q->where('company_id', $companyId);
            })->with(['machine', 'controlItems', 'assignedUser'])
              ->whereBetween('created_at', [$dateFrom, $dateTo]);

            if (isset($filters['status']) && !empty($filters['status'])) {
                $query->whereIn('status', $filters['status']);
            }

            if (isset($filters['machine_ids']) && !empty($filters['machine_ids'])) {
                $query->whereIn('machine_id', $filters['machine_ids']);
            }

            $controlLists = $query->get();

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 40, 'analyzing_compliance');
            }

            $reportData = $this->compileControlListReportData($controlLists, $dateFrom, $dateTo);

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 70, 'generating_document');
            }

            $filePath = $format === 'pdf'
                ? $this->generateControlListReportPDF($reportData, $reportId)
                : $this->generateControlListReportExcel($reportData, $reportId);

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 100, 'completed');
            }

            Log::info('Control list report generated successfully', [
                'company_id' => $companyId,
                'report_id' => $reportId,
                'format' => $format
            ]);

            return [
                'success' => true,
                'report_id' => $reportId,
                'file_path' => $filePath,
                'format' => $format,
                'generated_at' => now()->toISOString(),
                'data_summary' => $reportData['summary']
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to generate control list report', [
                'company_id' => $companyId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Report generation failed: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Generate user activity report.
     */
    public function generateUserActivityReport(
        int $companyId,
        array $userIds = [],
        string $dateFrom = null,
        string $dateTo = null,
        string $format = 'pdf',
        ?int $userId = null
    ): array {
        try {
            $reportId = uniqid('activity_report_');

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 10, 'starting');
            }

            $dateFrom = $dateFrom ? Carbon::parse($dateFrom) : Carbon::now()->subMonth();
            $dateTo = $dateTo ? Carbon::parse($dateTo) : Carbon::now();

            $query = User::where('company_id', $companyId)
                ->with(['controlLists' => function($q) use ($dateFrom, $dateTo) {
                    $q->whereBetween('created_at', [$dateFrom, $dateTo]);
                }]);

            if (!empty($userIds)) {
                $query->whereIn('id', $userIds);
            }

            $users = $query->get();

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 50, 'analyzing_activities');
            }

            $reportData = $this->compileUserActivityReportData($users, $dateFrom, $dateTo);

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 80, 'generating_document');
            }

            $filePath = $format === 'pdf'
                ? $this->generateUserActivityReportPDF($reportData, $reportId)
                : $this->generateUserActivityReportExcel($reportData, $reportId);

            if ($userId) {
                $this->broadcastService->broadcastReportProgress($userId, $reportId, 100, 'completed');
            }

            return [
                'success' => true,
                'report_id' => $reportId,
                'file_path' => $filePath,
                'format' => $format,
                'generated_at' => now()->toISOString(),
                'data_summary' => $reportData['summary']
            ];

        } catch (\Throwable $e) {
            Log::error('Failed to generate user activity report', [
                'company_id' => $companyId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Report generation failed: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Compile machine report data.
     */
    private function compileMachineReportData(Collection $machines, Carbon $dateFrom, Carbon $dateTo): array
    {
        $data = [
            'header' => [
                'title' => 'Machine Performance Report',
                'generated_at' => now()->format('d/m/Y H:i'),
                'period' => $dateFrom->format('d/m/Y') . ' - ' . $dateTo->format('d/m/Y'),
                'total_machines' => $machines->count()
            ],
            'machines' => [],
            'summary' => [
                'total_control_lists' => 0,
                'completed_control_lists' => 0,
                'pending_control_lists' => 0,
                'failed_control_lists' => 0,
                'average_completion_rate' => 0
            ]
        ];

        foreach ($machines as $machine) {
            $controlLists = $machine->controlLists;
            $completed = $controlLists->where('status', 'completed')->count();
            $pending = $controlLists->where('status', 'pending')->count();
            $failed = $controlLists->where('status', 'failed')->count();
            $total = $controlLists->count();

            $machineData = [
                'id' => $machine->id,
                'name' => $machine->name,
                'code' => $machine->machine_code,
                'type' => $machine->machine_type,
                'location' => $machine->location,
                'status' => $machine->status,
                'control_lists' => [
                    'total' => $total,
                    'completed' => $completed,
                    'pending' => $pending,
                    'failed' => $failed,
                    'completion_rate' => $total > 0 ? round(($completed / $total) * 100, 2) : 0
                ],
                'last_maintenance' => $machine->last_maintenance_date?->format('d/m/Y'),
                'next_maintenance' => $machine->next_maintenance_date?->format('d/m/Y')
            ];

            $data['machines'][] = $machineData;
            $data['summary']['total_control_lists'] += $total;
            $data['summary']['completed_control_lists'] += $completed;
            $data['summary']['pending_control_lists'] += $pending;
            $data['summary']['failed_control_lists'] += $failed;
        }

        if ($data['summary']['total_control_lists'] > 0) {
            $data['summary']['average_completion_rate'] = round(
                ($data['summary']['completed_control_lists'] / $data['summary']['total_control_lists']) * 100, 2
            );
        }

        return $data;
    }

    /**
     * Compile control list report data.
     */
    private function compileControlListReportData(Collection $controlLists, Carbon $dateFrom, Carbon $dateTo): array
    {
        $data = [
            'header' => [
                'title' => 'Control List Compliance Report',
                'generated_at' => now()->format('d/m/Y H:i'),
                'period' => $dateFrom->format('d/m/Y') . ' - ' . $dateTo->format('d/m/Y'),
                'total_control_lists' => $controlLists->count()
            ],
            'control_lists' => [],
            'summary' => [
                'total' => $controlLists->count(),
                'completed' => $controlLists->where('status', 'completed')->count(),
                'pending' => $controlLists->where('status', 'pending')->count(),
                'failed' => $controlLists->where('status', 'failed')->count(),
                'compliance_rate' => 0,
                'average_completion_time' => 0
            ]
        ];

        $totalCompletionTime = 0;
        $completedCount = 0;

        foreach ($controlLists as $controlList) {
            $completionTime = null;
            if ($controlList->status === 'completed' && $controlList->completed_at) {
                $completionTime = $controlList->created_at->diffInMinutes($controlList->completed_at);
                $totalCompletionTime += $completionTime;
                $completedCount++;
            }

            $data['control_lists'][] = [
                'id' => $controlList->id,
                'machine_name' => $controlList->machine->name,
                'machine_code' => $controlList->machine->machine_code,
                'assigned_user' => $controlList->assignedUser->name ?? 'Unassigned',
                'status' => $controlList->status,
                'created_at' => $controlList->created_at->format('d/m/Y H:i'),
                'completed_at' => $controlList->completed_at?->format('d/m/Y H:i'),
                'completion_time_minutes' => $completionTime,
                'items_count' => $controlList->controlItems->count(),
                'completed_items' => $controlList->controlItems->where('status', 'completed')->count()
            ];
        }

        if ($data['summary']['total'] > 0) {
            $data['summary']['compliance_rate'] = round(
                ($data['summary']['completed'] / $data['summary']['total']) * 100, 2
            );
        }

        if ($completedCount > 0) {
            $data['summary']['average_completion_time'] = round($totalCompletionTime / $completedCount, 2);
        }

        return $data;
    }

    /**
     * Compile user activity report data.
     */
    private function compileUserActivityReportData(Collection $users, Carbon $dateFrom, Carbon $dateTo): array
    {
        $data = [
            'header' => [
                'title' => 'User Activity Report',
                'generated_at' => now()->format('d/m/Y H:i'),
                'period' => $dateFrom->format('d/m/Y') . ' - ' . $dateTo->format('d/m/Y'),
                'total_users' => $users->count()
            ],
            'users' => [],
            'summary' => [
                'total_users' => $users->count(),
                'active_users' => 0,
                'total_tasks_completed' => 0,
                'average_tasks_per_user' => 0
            ]
        ];

        foreach ($users as $user) {
            $controlLists = $user->controlLists;
            $completedTasks = $controlLists->where('status', 'completed')->count();
            $pendingTasks = $controlLists->where('status', 'pending')->count();
            $totalTasks = $controlLists->count();

            if ($totalTasks > 0) {
                $data['summary']['active_users']++;
            }

            $data['users'][] = [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->roles->first()?->name ?? 'User',
                'tasks' => [
                    'total' => $totalTasks,
                    'completed' => $completedTasks,
                    'pending' => $pendingTasks,
                    'completion_rate' => $totalTasks > 0 ? round(($completedTasks / $totalTasks) * 100, 2) : 0
                ],
                'last_activity' => $user->updated_at->format('d/m/Y H:i')
            ];

            $data['summary']['total_tasks_completed'] += $completedTasks;
        }

        if ($data['summary']['active_users'] > 0) {
            $data['summary']['average_tasks_per_user'] = round(
                $data['summary']['total_tasks_completed'] / $data['summary']['active_users'], 2
            );
        }

        return $data;
    }

    /**
     * Generate machine report PDF.
     */
    private function generateMachineReportPDF(array $data, string $reportId): string
    {
        $options = new Options();
        $options->set('defaultFont', 'DejaVu Sans');
        $options->set('isRemoteEnabled', true);

        $dompdf = new Dompdf($options);

        $html = view('reports.machine-report', compact('data'))->render();
        $dompdf->loadHtml($html);
        $dompdf->setPaper('A4', 'portrait');
        $dompdf->render();

        $fileName = "machine_report_{$reportId}.pdf";
        $filePath = storage_path("app/reports/{$fileName}");

        if (!file_exists(dirname($filePath))) {
            mkdir(dirname($filePath), 0755, true);
        }

        file_put_contents($filePath, $dompdf->output());

        return $filePath;
    }

    /**
     * Generate control list report PDF.
     */
    private function generateControlListReportPDF(array $data, string $reportId): string
    {
        $options = new Options();
        $options->set('defaultFont', 'DejaVu Sans');
        $options->set('isRemoteEnabled', true);

        $dompdf = new Dompdf($options);

        $html = view('reports.control-list-report', compact('data'))->render();
        $dompdf->loadHtml($html);
        $dompdf->setPaper('A4', 'portrait');
        $dompdf->render();

        $fileName = "control_list_report_{$reportId}.pdf";
        $filePath = storage_path("app/reports/{$fileName}");

        if (!file_exists(dirname($filePath))) {
            mkdir(dirname($filePath), 0755, true);
        }

        file_put_contents($filePath, $dompdf->output());

        return $filePath;
    }

    /**
     * Generate user activity report PDF.
     */
    private function generateUserActivityReportPDF(array $data, string $reportId): string
    {
        $options = new Options();
        $options->set('defaultFont', 'DejaVu Sans');
        $options->set('isRemoteEnabled', true);

        $dompdf = new Dompdf($options);

        $html = view('reports.user-activity-report', compact('data'))->render();
        $dompdf->loadHtml($html);
        $dompdf->setPaper('A4', 'portrait');
        $dompdf->render();

        $fileName = "user_activity_report_{$reportId}.pdf";
        $filePath = storage_path("app/reports/{$fileName}");

        if (!file_exists(dirname($filePath))) {
            mkdir(dirname($filePath), 0755, true);
        }

        file_put_contents($filePath, $dompdf->output());

        return $filePath;
    }

    /**
     * Generate machine report Excel.
     */
    private function generateMachineReportExcel(array $data, string $reportId): string
    {
        $fileName = "machine_report_{$reportId}.xlsx";
        $filePath = storage_path("app/reports/{$fileName}");

        if (!file_exists(dirname($filePath))) {
            mkdir(dirname($filePath), 0755, true);
        }

        Excel::store(new MachineReportExport($data), "reports/{$fileName}");

        return $filePath;
    }

    /**
     * Generate control list report Excel.
     */
    private function generateControlListReportExcel(array $data, string $reportId): string
    {
        $fileName = "control_list_report_{$reportId}.xlsx";
        $filePath = storage_path("app/reports/{$fileName}");

        if (!file_exists(dirname($filePath))) {
            mkdir(dirname($filePath), 0755, true);
        }

        Excel::store(new ControlListReportExport($data), "reports/{$fileName}");

        return $filePath;
    }

    /**
     * Generate user activity report Excel.
     */
    private function generateUserActivityReportExcel(array $data, string $reportId): string
    {
        $fileName = "user_activity_report_{$reportId}.xlsx";
        $filePath = storage_path("app/reports/{$fileName}");

        if (!file_exists(dirname($filePath))) {
            mkdir(dirname($filePath), 0755, true);
        }

        Excel::store(new UserActivityReportExport($data), "reports/{$fileName}");

        return $filePath;
    }

    /**
     * Get available report types.
     */
    public function getAvailableReportTypes(): array
    {
        return [
            'machine_performance' => [
                'name' => 'Machine Performance Report',
                'description' => 'Detailed analysis of machine performance and control list completion rates',
                'formats' => ['pdf', 'excel']
            ],
            'control_list_compliance' => [
                'name' => 'Control List Compliance Report',
                'description' => 'Compliance analysis and completion statistics for control lists',
                'formats' => ['pdf', 'excel']
            ],
            'user_activity' => [
                'name' => 'User Activity Report',
                'description' => 'User activity and task completion analysis',
                'formats' => ['pdf', 'excel']
            ]
        ];
    }
}