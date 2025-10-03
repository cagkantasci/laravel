<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use App\Services\ReportService;
use App\Http\Requests\BaseRequest;

class ReportController extends Controller
{
    private ReportService $reportService;

    public function __construct(ReportService $reportService)
    {
        $this->reportService = $reportService;
    }

    /**
     * Get available report types.
     */
    public function getReportTypes(): JsonResponse
    {
        try {
            $reportTypes = $this->reportService->getAvailableReportTypes();

            return response()->json([
                'success' => true,
                'data' => $reportTypes,
                'message' => 'Report types retrieved successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to get report types', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve report types'
            ], 500);
        }
    }

    /**
     * Generate machine performance report.
     */
    public function generateMachineReport(MachineReportRequest $request): JsonResponse
    {
        try {
            $companyId = auth()->user()->company_id;
            $userId = auth()->id();

            $result = $this->reportService->generateMachineReport(
                $companyId,
                $request->input('machine_ids', []),
                $request->input('date_from'),
                $request->input('date_to'),
                $request->input('format', 'pdf'),
                $userId
            );

            if (!$result['success']) {
                return response()->json($result, 400);
            }

            return response()->json([
                'success' => true,
                'data' => $result,
                'message' => 'Machine report generated successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to generate machine report', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate machine report'
            ], 500);
        }
    }

    /**
     * Generate control list compliance report.
     */
    public function generateControlListReport(ControlListReportRequest $request): JsonResponse
    {
        try {
            $companyId = auth()->user()->company_id;
            $userId = auth()->id();

            $filters = $request->only(['date_from', 'date_to', 'status', 'machine_ids']);

            $result = $this->reportService->generateControlListReport(
                $companyId,
                $filters,
                $request->input('format', 'pdf'),
                $userId
            );

            if (!$result['success']) {
                return response()->json($result, 400);
            }

            return response()->json([
                'success' => true,
                'data' => $result,
                'message' => 'Control list report generated successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to generate control list report', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate control list report'
            ], 500);
        }
    }

    /**
     * Generate user activity report.
     */
    public function generateUserActivityReport(UserActivityReportRequest $request): JsonResponse
    {
        try {
            $companyId = auth()->user()->company_id;
            $userId = auth()->id();

            $result = $this->reportService->generateUserActivityReport(
                $companyId,
                $request->input('user_ids', []),
                $request->input('date_from'),
                $request->input('date_to'),
                $request->input('format', 'pdf'),
                $userId
            );

            if (!$result['success']) {
                return response()->json($result, 400);
            }

            return response()->json([
                'success' => true,
                'data' => $result,
                'message' => 'User activity report generated successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to generate user activity report', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate user activity report'
            ], 500);
        }
    }

    /**
     * Download generated report.
     */
    public function downloadReport(Request $request, string $reportId): \Symfony\Component\HttpFoundation\BinaryFileResponse
    {
        try {
            $format = $request->query('format', 'pdf');
            $type = $request->query('type', 'machine');

            $fileName = "{$type}_report_{$reportId}.{$format}";
            $filePath = storage_path("app/reports/{$fileName}");

            if (!file_exists($filePath)) {
                abort(404, 'Report file not found');
            }

            $mimeType = $format === 'pdf' ? 'application/pdf' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

            return response()->download($filePath, $fileName, [
                'Content-Type' => $mimeType,
                'Content-Disposition' => "attachment; filename=\"{$fileName}\"",
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to download report', [
                'report_id' => $reportId,
                'error' => $e->getMessage()
            ]);

            abort(500, 'Failed to download report');
        }
    }

    /**
     * Get report history for the company.
     */
    public function getReportHistory(Request $request): JsonResponse
    {
        try {
            $companyId = auth()->user()->company_id;
            $page = $request->input('page', 1);
            $limit = $request->input('limit', 20);

            $reportsPath = storage_path('app/reports');
            $reports = [];

            if (is_dir($reportsPath)) {
                $files = glob($reportsPath . '/*_report_*.{pdf,xlsx}', GLOB_BRACE);
                $files = array_slice($files, ($page - 1) * $limit, $limit);

                foreach ($files as $file) {
                    $fileName = basename($file);
                    $fileInfo = pathinfo($file);

                    preg_match('/^(.+)_report_(.+)\.(.+)$/', $fileName, $matches);

                    if (count($matches) === 4) {
                        $reports[] = [
                            'id' => $matches[2],
                            'type' => $matches[1],
                            'format' => $matches[3],
                            'file_name' => $fileName,
                            'file_size' => filesize($file),
                            'created_at' => date('Y-m-d H:i:s', filemtime($file)),
                            'download_url' => route('reports.download', [
                                'reportId' => $matches[2],
                                'format' => $matches[3],
                                'type' => $matches[1]
                            ])
                        ];
                    }
                }
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'reports' => $reports,
                    'pagination' => [
                        'current_page' => $page,
                        'per_page' => $limit,
                        'total' => count($reports)
                    ]
                ],
                'message' => 'Report history retrieved successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to get report history', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve report history'
            ], 500);
        }
    }

    /**
     * Delete a report file.
     */
    public function deleteReport(string $reportId): JsonResponse
    {
        try {
            $reportsPath = storage_path('app/reports');
            $files = glob($reportsPath . "/*_report_{$reportId}.*");

            $deletedFiles = 0;
            foreach ($files as $file) {
                if (unlink($file)) {
                    $deletedFiles++;
                }
            }

            if ($deletedFiles === 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Report not found'
                ], 404);
            }

            Log::info('Report deleted', [
                'report_id' => $reportId,
                'deleted_files' => $deletedFiles,
                'user_id' => auth()->id()
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Report deleted successfully'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to delete report', [
                'report_id' => $reportId,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to delete report'
            ], 500);
        }
    }

    /**
     * Generate custom dashboard report.
     */
    public function generateDashboardReport(DashboardReportRequest $request): JsonResponse
    {
        try {
            $companyId = auth()->user()->company_id;
            $userId = auth()->id();

            $reportData = [
                'company_id' => $companyId,
                'widgets' => $request->input('widgets', []),
                'date_range' => $request->input('date_range'),
                'filters' => $request->input('filters', [])
            ];

            // Here you would implement custom dashboard report generation
            // For now, we'll return a placeholder response

            return response()->json([
                'success' => true,
                'data' => [
                    'report_id' => uniqid('dashboard_'),
                    'message' => 'Dashboard report generation started',
                    'estimated_time' => '2-3 minutes'
                ],
                'message' => 'Dashboard report generation initiated'
            ]);

        } catch (\Throwable $e) {
            Log::error('Failed to generate dashboard report', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate dashboard report'
            ], 500);
        }
    }
}

// Request validation classes
class MachineReportRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->can('generate_reports');
    }

    public function rules(): array
    {
        return [
            'machine_ids' => 'nullable|array',
            'machine_ids.*' => 'exists:machines,id',
            'date_from' => 'nullable|date|before_or_equal:date_to',
            'date_to' => 'nullable|date|after_or_equal:date_from',
            'format' => 'in:pdf,excel'
        ];
    }

    public function messages(): array
    {
        return [
            'machine_ids.*.exists' => 'Seçilen makine geçerli değil',
            'date_from.before_or_equal' => 'Başlangıç tarihi bitiş tarihinden önce olmalıdır',
            'date_to.after_or_equal' => 'Bitiş tarihi başlangıç tarihinden sonra olmalıdır',
            'format.in' => 'Geçerli format seçiniz (pdf veya excel)'
        ];
    }
}

class ControlListReportRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->can('generate_reports');
    }

    public function rules(): array
    {
        return [
            'date_from' => 'nullable|date|before_or_equal:date_to',
            'date_to' => 'nullable|date|after_or_equal:date_from',
            'status' => 'nullable|array',
            'status.*' => 'in:pending,in_progress,completed,failed',
            'machine_ids' => 'nullable|array',
            'machine_ids.*' => 'exists:machines,id',
            'format' => 'in:pdf,excel'
        ];
    }
}

class UserActivityReportRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->can('generate_reports');
    }

    public function rules(): array
    {
        return [
            'user_ids' => 'nullable|array',
            'user_ids.*' => 'exists:users,id',
            'date_from' => 'nullable|date|before_or_equal:date_to',
            'date_to' => 'nullable|date|after_or_equal:date_from',
            'format' => 'in:pdf,excel'
        ];
    }
}

class DashboardReportRequest extends BaseRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->can('generate_reports');
    }

    public function rules(): array
    {
        return [
            'widgets' => 'required|array|min:1',
            'widgets.*' => 'string|in:machines,control_lists,users,activities,performance',
            'date_range' => 'required|array',
            'date_range.from' => 'required|date',
            'date_range.to' => 'required|date|after_or_equal:date_range.from',
            'filters' => 'nullable|array'
        ];
    }
}