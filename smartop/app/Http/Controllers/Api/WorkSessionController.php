<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MachineWorkSession;
use App\Models\Machine;
use App\Models\ControlList;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class WorkSessionController extends Controller
{
    /**
     * Get all work sessions (for admin/manager)
     */
    public function index(Request $request)
    {
        $query = MachineWorkSession::with(['machine', 'operator', 'controlList', 'approver'])
            ->forCompany($request->user()->company_id);

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by operator
        if ($request->has('operator_id')) {
            $query->where('operator_id', $request->operator_id);
        }

        // Filter by date range
        if ($request->has('start_date')) {
            $query->whereDate('start_time', '>=', $request->start_date);
        }
        if ($request->has('end_date')) {
            $query->whereDate('start_time', '<=', $request->end_date);
        }

        $sessions = $query->orderBy('start_time', 'desc')->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $sessions
        ]);
    }

    /**
     * Get operator's own work sessions
     */
    public function mySession(Request $request)
    {
        $sessions = MachineWorkSession::with(['machine', 'controlList', 'approver'])
            ->forOperator($request->user()->id)
            ->orderBy('start_time', 'desc')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $sessions
        ]);
    }

    /**
     * Get active session for operator
     */
    public function activeSession(Request $request)
    {
        $session = MachineWorkSession::with(['machine', 'controlList'])
            ->forOperator($request->user()->id)
            ->inProgress()
            ->first();

        return response()->json([
            'success' => true,
            'data' => $session
        ]);
    }

    /**
     * Start a new work session
     */
    public function start(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'machine_id' => 'required|exists:machines,id',
            'start_time' => 'required|date',
            'location' => 'nullable|string|max:255',
            'start_notes' => 'nullable|string',
            'control_list_id' => 'nullable|exists:control_lists,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Check if operator has an active session
        $activeSession = MachineWorkSession::forOperator($request->user()->id)
            ->inProgress()
            ->first();

        if ($activeSession) {
            return response()->json([
                'success' => false,
                'message' => 'Zaten aktif bir çalışma seansınız var. Önce onu bitirmelisiniz.'
            ], 400);
        }

        $session = MachineWorkSession::create([
            'machine_id' => $request->machine_id,
            'operator_id' => $request->user()->id,
            'company_id' => $request->user()->company_id,
            'control_list_id' => $request->control_list_id,
            'start_time' => $request->start_time,
            'location' => $request->location,
            'start_notes' => $request->start_notes,
            'status' => 'in_progress'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Çalışma seansı başlatıldı',
            'data' => $session->load(['machine', 'controlList'])
        ], 201);
    }

    /**
     * End work session
     */
    public function end(Request $request, $id)
    {
        $session = MachineWorkSession::findOrFail($id);

        // Check if operator owns this session
        if ($session->operator_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Bu seansı sonlandırma yetkiniz yok'
            ], 403);
        }

        if (!$session->isInProgress()) {
            return response()->json([
                'success' => false,
                'message' => 'Bu seans zaten sonlandırılmış'
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'end_time' => 'required|date|after:' . $session->start_time,
            'end_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $session->end_time = $request->end_time;
        $session->end_notes = $request->end_notes;
        $session->status = 'completed';
        $session->save();

        return response()->json([
            'success' => true,
            'message' => 'Çalışma seansı sonlandırıldı',
            'data' => $session->fresh(['machine', 'controlList'])
        ]);
    }

    /**
     * Approve work session (manager)
     */
    public function approve(Request $request, $id)
    {
        $session = MachineWorkSession::findOrFail($id);

        // Check if user has permission to approve
        if (!$request->user()->hasRole(['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Onaylama yetkiniz yok'
            ], 403);
        }

        if ($session->company_id !== $request->user()->company_id) {
            return response()->json([
                'success' => false,
                'message' => 'Bu seansı onaylama yetkiniz yok'
            ], 403);
        }

        $session->approve($request->user()->id, $request->approval_notes);

        return response()->json([
            'success' => true,
            'message' => 'Çalışma seansı onaylandı',
            'data' => $session->fresh(['machine', 'operator', 'approver'])
        ]);
    }

    /**
     * Reject work session (manager)
     */
    public function reject(Request $request, $id)
    {
        $session = MachineWorkSession::findOrFail($id);

        // Check if user has permission to reject
        if (!$request->user()->hasRole(['admin', 'manager'])) {
            return response()->json([
                'success' => false,
                'message' => 'Reddetme yetkiniz yok'
            ], 403);
        }

        if ($session->company_id !== $request->user()->company_id) {
            return response()->json([
                'success' => false,
                'message' => 'Bu seansı reddetme yetkiniz yok'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'approval_notes' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Red nedeni gereklidir',
                'errors' => $validator->errors()
            ], 422);
        }

        $session->reject($request->user()->id, $request->approval_notes);

        return response()->json([
            'success' => true,
            'message' => 'Çalışma seansı reddedildi',
            'data' => $session->fresh(['machine', 'operator', 'approver'])
        ]);
    }

    /**
     * Get work session statistics
     */
    public function statistics(Request $request)
    {
        $query = MachineWorkSession::forCompany($request->user()->company_id);

        // Filter by date range if provided
        if ($request->has('start_date')) {
            $query->whereDate('start_time', '>=', $request->start_date);
        }
        if ($request->has('end_date')) {
            $query->whereDate('start_time', '<=', $request->end_date);
        }

        $stats = [
            'total_sessions' => (clone $query)->count(),
            'in_progress' => (clone $query)->where('status', 'in_progress')->count(),
            'completed' => (clone $query)->where('status', 'completed')->count(),
            'approved' => (clone $query)->where('status', 'approved')->count(),
            'rejected' => (clone $query)->where('status', 'rejected')->count(),
            'total_hours' => (clone $query)->whereNotNull('duration_minutes')->sum('duration_minutes') / 60,
        ];

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }
}
