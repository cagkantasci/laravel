<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ControlList;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use App\Mail\ControlListApproved;
use App\Mail\ControlListRejected;

class ApprovalController extends Controller
{
    /**
     * Get all pending approvals for the authenticated user's company
     */
    public function index(Request $request)
    {
        $user = auth()->user();

        // Only managers and admins can view approvals
        if (!$user->hasAnyRole(['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Bu işlem için yetkiniz yok.'
            ], 403);
        }

        $query = ControlList::with(['user', 'machine', 'approver'])
            ->where('status', 'completed'); // Only show completed lists waiting for approval

        // If manager, only show from their company
        if ($user->hasRole('manager')) {
            $query->where('company_id', $user->company_id);
        }

        // Filter by status if provided
        if ($request->has('status') && in_array($request->status, ['completed', 'approved', 'rejected'])) {
            $query->where('status', $request->status);
        }

        // Filter by priority if provided
        if ($request->has('priority')) {
            $query->where('priority', $request->priority);
        }

        // Search by machine name or operator name
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->whereHas('machine', function($mq) use ($search) {
                    $mq->where('name', 'like', "%{$search}%")
                      ->orWhere('code', 'like', "%{$search}%");
                })
                ->orWhereHas('user', function($uq) use ($search) {
                    $uq->where('name', 'like', "%{$search}%");
                });
            });
        }

        $approvals = $query->orderBy('priority', 'desc')
                           ->orderBy('completed_date', 'asc')
                           ->paginate($request->per_page ?? 15);

        // Transform data for frontend
        $approvals->getCollection()->transform(function ($control) {
            return [
                'id' => $control->id,
                'uuid' => $control->uuid,
                'machine_id' => $control->machine_id,
                'machine_name' => $control->machine->name ?? '',
                'machine_code' => $control->machine->code ?? '',
                'operator_id' => $control->user_id,
                'operator_name' => $control->user->name ?? '',
                'operator_email' => $control->user->email ?? '',
                'control_list_title' => $control->title,
                'submitted_at' => $control->completed_date ?? $control->created_at,
                'status' => $control->status,
                'priority' => $control->priority === 'critical' ? 'urgent' : 'normal',
                'completion_rate' => $this->calculateCompletionRate($control->control_items),
                'total_items' => count($control->control_items ?? []),
                'passed_items' => $this->countPassedItems($control->control_items),
                'failed_items' => $this->countFailedItems($control->control_items),
                'control_items' => $this->transformControlItems($control->control_items),
                'notes' => $control->notes,
                'rejection_reason' => $control->rejection_reason,
                'approved_by' => $control->approver->name ?? null,
                'approved_at' => $control->approved_at,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $approvals->items(),
            'pagination' => [
                'current_page' => $approvals->currentPage(),
                'per_page' => $approvals->perPage(),
                'total' => $approvals->total(),
                'last_page' => $approvals->lastPage(),
            ]
        ]);
    }

    /**
     * Approve a control list
     */
    public function approve(Request $request, $id)
    {
        $user = auth()->user();

        // Only managers and admins can approve
        if (!$user->hasAnyRole(['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Bu işlem için yetkiniz yok.'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'notes' => 'nullable|string|max:1000'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $controlList = ControlList::findOrFail($id);

        // Check if manager has permission for this company
        if ($user->hasRole('manager') && $controlList->company_id !== $user->company_id) {
            return response()->json([
                'success' => false,
                'message' => 'Bu kontrol listesi için yetkiniz yok.'
            ], 403);
        }

        // Check if control list can be approved
        if ($controlList->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'Bu kontrol listesi onaylanamaz. Durum: ' . $controlList->status
            ], 400);
        }

        DB::beginTransaction();
        try {
            // Approve the control list
            $controlList->approve($user, $request->notes);

            // Send email notification to operator
            try {
                Mail::to($controlList->user->email)
                    ->send(new ControlListApproved($controlList));
            } catch (\Exception $e) {
                \Log::error('Email gönderilirken hata: ' . $e->getMessage());
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Kontrol listesi başarıyla onaylandı.',
                'data' => $controlList->fresh()
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Onaylama sırasında hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Reject a control list
     */
    public function reject(Request $request, $id)
    {
        $user = auth()->user();

        // Only managers and admins can reject
        if (!$user->hasAnyRole(['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Bu işlem için yetkiniz yok.'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'reason' => 'required|string|max:1000'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $controlList = ControlList::findOrFail($id);

        // Check if manager has permission for this company
        if ($user->hasRole('manager') && $controlList->company_id !== $user->company_id) {
            return response()->json([
                'success' => false,
                'message' => 'Bu kontrol listesi için yetkiniz yok.'
            ], 403);
        }

        // Check if control list can be rejected
        if ($controlList->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'Bu kontrol listesi reddedilemez. Durum: ' . $controlList->status
            ], 400);
        }

        DB::beginTransaction();
        try {
            // Reject the control list
            $controlList->reject($user, $request->reason);

            // Send email notification to operator
            try {
                Mail::to($controlList->user->email)
                    ->send(new ControlListRejected($controlList));
            } catch (\Exception $e) {
                \Log::error('Email gönderilirken hata: ' . $e->getMessage());
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Kontrol listesi reddedildi.',
                'data' => $controlList->fresh()
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Reddetme sırasında hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get approval statistics
     */
    public function statistics(Request $request)
    {
        $user = auth()->user();

        if (!$user->hasAnyRole(['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Bu işlem için yetkiniz yok.'
            ], 403);
        }

        $query = ControlList::query();

        if ($user->hasRole('manager')) {
            $query->where('company_id', $user->company_id);
        }

        $stats = [
            'pending' => (clone $query)->where('status', 'completed')->count(),
            'approved_today' => (clone $query)->where('status', 'approved')
                ->whereDate('approved_at', today())->count(),
            'rejected_today' => (clone $query)->where('status', 'rejected')
                ->whereDate('approved_at', today())->count(),
            'urgent' => (clone $query)->where('status', 'completed')
                ->where('priority', 'critical')->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }

    /**
     * Helper methods
     */
    private function calculateCompletionRate($items)
    {
        if (!$items || !is_array($items) || count($items) === 0) {
            return 0;
        }

        $completed = collect($items)->filter(function($item) {
            return isset($item['status']) && in_array($item['status'], ['pass', 'fail']);
        })->count();

        return round(($completed / count($items)) * 100);
    }

    private function countPassedItems($items)
    {
        if (!$items || !is_array($items)) {
            return 0;
        }

        return collect($items)->filter(function($item) {
            return isset($item['status']) && $item['status'] === 'pass';
        })->count();
    }

    private function countFailedItems($items)
    {
        if (!$items || !is_array($items)) {
            return 0;
        }

        return collect($items)->filter(function($item) {
            return isset($item['status']) && $item['status'] === 'fail';
        })->count();
    }

    private function transformControlItems($items)
    {
        if (!$items || !is_array($items)) {
            return [];
        }

        return collect($items)->map(function($item, $index) {
            return [
                'id' => $item['id'] ?? $index + 1,
                'title' => $item['title'] ?? '',
                'description' => $item['description'] ?? '',
                'status' => $item['status'] ?? 'na',
                'priority' => $item['priority'] ?? 'medium',
                'category' => $item['category'] ?? 'Genel',
                'notes' => $item['notes'] ?? null,
                'photo_url' => $item['photo_url'] ?? null,
            ];
        })->toArray();
    }
}
