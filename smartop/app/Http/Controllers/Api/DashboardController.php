<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\User;
use App\Models\Machine;
use App\Models\ControlList;
use App\Models\ControlTemplate;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:sanctum');
        $this->middleware('company');
    }

    /**
     * Get dashboard statistics
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $companyId = $request->get('user_company_id');

        if ($user->hasRole('admin')) {
            return $this->getAdminDashboard();
        } elseif ($user->hasRole('manager')) {
            return $this->getManagerDashboard($companyId);
        } else {
            return $this->getOperatorDashboard($user->id, $companyId);
        }
    }

    /**
     * Admin Dashboard
     */
    private function getAdminDashboard()
    {
        $totalCompanies = Company::count();
        $activeCompanies = Company::where('status', 'active')->count();
        $totalUsers = User::count();
        $activeUsers = User::where('status', 'active')->count();
        $totalMachines = Machine::count();
        $activeMachines = Machine::where('status', 'active')->count();
        $totalControlLists = ControlList::count();
        $pendingApprovals = ControlList::where('status', 'completed')->count();

        // Control Lists by Status
        $controlListsByStatus = ControlList::select('status', DB::raw('count(*) as count'))
            ->groupBy('status')
            ->pluck('count', 'status')
            ->toArray();

        // Recent Activity
        $recentControlLists = ControlList::with(['machine:id,name', 'user:id,name', 'company:id,name'])
            ->latest()
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'overview' => [
                    'total_companies' => $totalCompanies,
                    'active_companies' => $activeCompanies,
                    'total_users' => $totalUsers,
                    'active_users' => $activeUsers,
                    'total_machines' => $totalMachines,
                    'active_machines' => $activeMachines,
                    'total_control_lists' => $totalControlLists,
                    'pending_approvals' => $pendingApprovals,
                ],
                'charts' => [
                    'control_lists_by_status' => $controlListsByStatus,
                ],
                'recent_activity' => $recentControlLists,
            ]
        ]);
    }

    /**
     * Manager Dashboard
     */
    private function getManagerDashboard($companyId)
    {
        $totalUsers = User::where('company_id', $companyId)->count();
        $activeUsers = User::where('company_id', $companyId)->where('status', 'active')->count();
        $totalMachines = Machine::where('company_id', $companyId)->count();
        $activeMachines = Machine::where('company_id', $companyId)->where('status', 'active')->count();
        $totalControlLists = ControlList::where('company_id', $companyId)->count();
        $pendingApprovals = ControlList::where('company_id', $companyId)->where('status', 'completed')->count();
        $overdueControlLists = ControlList::where('company_id', $companyId)->overdue()->count();

        // Control Lists by Priority
        $controlListsByPriority = ControlList::where('company_id', $companyId)
            ->select('priority', DB::raw('count(*) as count'))
            ->groupBy('priority')
            ->pluck('count', 'priority')
            ->toArray();

        // Control Lists by Status
        $controlListsByStatus = ControlList::where('company_id', $companyId)
            ->select('status', DB::raw('count(*) as count'))
            ->groupBy('status')
            ->pluck('count', 'status')
            ->toArray();

        // Upcoming Control Lists
        $upcomingControlLists = ControlList::where('company_id', $companyId)
            ->with(['machine:id,name', 'user:id,name'])
            ->where('scheduled_date', '>=', now())
            ->where('scheduled_date', '<=', now()->addDays(7))
            ->whereIn('status', ['pending', 'in_progress'])
            ->orderBy('scheduled_date')
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'overview' => [
                    'total_users' => $totalUsers,
                    'active_users' => $activeUsers,
                    'total_machines' => $totalMachines,
                    'active_machines' => $activeMachines,
                    'total_control_lists' => $totalControlLists,
                    'pending_approvals' => $pendingApprovals,
                    'overdue_control_lists' => $overdueControlLists,
                ],
                'charts' => [
                    'control_lists_by_priority' => $controlListsByPriority,
                    'control_lists_by_status' => $controlListsByStatus,
                ],
                'upcoming_control_lists' => $upcomingControlLists,
            ]
        ]);
    }

    /**
     * Operator Dashboard
     */
    private function getOperatorDashboard($userId, $companyId)
    {
        $myControlLists = ControlList::where('user_id', $userId)->count();
        $myPendingControlLists = ControlList::where('user_id', $userId)->pending()->count();
        $myCompletedControlLists = ControlList::where('user_id', $userId)->completed()->count();
        $myOverdueControlLists = ControlList::where('user_id', $userId)->overdue()->count();

        // My Control Lists by Status
        $myControlListsByStatus = ControlList::where('user_id', $userId)
            ->select('status', DB::raw('count(*) as count'))
            ->groupBy('status')
            ->pluck('count', 'status')
            ->toArray();

        // My Tasks for Today
        $todayTasks = ControlList::where('user_id', $userId)
            ->with(['machine:id,name,location'])
            ->scheduledForToday()
            ->whereIn('status', ['pending', 'in_progress'])
            ->orderBy('priority')
            ->get();

        // My Recent Control Lists
        $recentControlLists = ControlList::where('user_id', $userId)
            ->with(['machine:id,name', 'approver:id,name'])
            ->latest()
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'overview' => [
                    'my_control_lists' => $myControlLists,
                    'my_pending_control_lists' => $myPendingControlLists,
                    'my_completed_control_lists' => $myCompletedControlLists,
                    'my_overdue_control_lists' => $myOverdueControlLists,
                ],
                'charts' => [
                    'my_control_lists_by_status' => $myControlListsByStatus,
                ],
                'today_tasks' => $todayTasks,
                'recent_control_lists' => $recentControlLists,
            ]
        ]);
    }

    /**
     * Get reports data
     */
    public function reports(Request $request)
    {
        $user = $request->user();
        $companyId = $request->get('user_company_id');

        // Base query
        $query = ControlList::query();
        
        // Apply company filter for non-admin users
        if (!$user->hasRole('admin')) {
            $query->where('company_id', $companyId);
        }

        // Apply date filters
        if ($request->has('start_date')) {
            $query->whereDate('created_at', '>=', $request->get('start_date'));
        }

        if ($request->has('end_date')) {
            $query->whereDate('created_at', '<=', $request->get('end_date'));
        }

        // Control Lists Summary
        $summary = [
            'total' => $query->count(),
            'completed' => $query->clone()->completed()->count(),
            'approved' => $query->clone()->approved()->count(),
            'pending' => $query->clone()->pending()->count(),
            'overdue' => $query->clone()->overdue()->count(),
        ];

        // Performance by User
        $userPerformance = $query->clone()
            ->with('user:id,name')
            ->select('user_id', 
                DB::raw('count(*) as total_tasks'),
                DB::raw('count(case when status = "completed" then 1 end) as completed_tasks'),
                DB::raw('count(case when status = "approved" then 1 end) as approved_tasks')
            )
            ->groupBy('user_id')
            ->having('total_tasks', '>', 0)
            ->get()
            ->map(function ($item) {
                $item->completion_rate = $item->total_tasks > 0 
                    ? round(($item->completed_tasks / $item->total_tasks) * 100, 2) 
                    : 0;
                $item->approval_rate = $item->completed_tasks > 0 
                    ? round(($item->approved_tasks / $item->completed_tasks) * 100, 2) 
                    : 0;
                return $item;
            });

        // Machine Performance
        $machinePerformance = $query->clone()
            ->with('machine:id,name,type')
            ->select('machine_id',
                DB::raw('count(*) as total_controls'),
                DB::raw('count(case when status = "completed" then 1 end) as completed_controls'),
                DB::raw('avg(case when completed_date is not null and scheduled_date is not null then timestampdiff(hour, scheduled_date, completed_date) end) as avg_completion_time')
            )
            ->groupBy('machine_id')
            ->having('total_controls', '>', 0)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'summary' => $summary,
                'user_performance' => $userPerformance,
                'machine_performance' => $machinePerformance,
            ]
        ]);
    }
}
