<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ControlList;
use App\Http\Resources\ControlListResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class ControlListController extends Controller
{
    use AuthorizesRequests;

    public function __construct()
    {
        $this->middleware('auth:sanctum');
        $this->middleware('company');
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $this->authorize('viewAny', ControlList::class);

        $user = $request->user();
        $companyId = $request->get('user_company_id');

        $query = ControlList::with(['company:id,name', 'machine:id,name,type,location', 
                                  'controlTemplate:id,name,category', 'user:id,name', 'approver:id,name']);

        // Apply company filter for non-admin users
        if (!$user->hasRole('admin')) {
            $query->where('company_id', $companyId);
        }

        // Apply filters
        if ($request->has('status')) {
            $query->where('status', $request->get('status'));
        }

        if ($request->has('priority')) {
            $query->where('priority', $request->get('priority'));
        }

        if ($request->has('machine_id')) {
            $query->where('machine_id', $request->get('machine_id'));
        }

        if ($request->has('user_id')) {
            $query->where('user_id', $request->get('user_id'));
        }

        if ($request->has('overdue') && $request->boolean('overdue')) {
            $query->overdue();
        }

        if ($request->has('today') && $request->boolean('today')) {
            $query->scheduledForToday();
        }

        if ($request->has('search')) {
            $search = $request->get('search');
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('notes', 'like', "%{$search}%");
            });
        }

        // Order by priority and scheduled date
        $query->orderByRaw("
            CASE priority 
                WHEN 'critical' THEN 1 
                WHEN 'high' THEN 2 
                WHEN 'medium' THEN 3 
                WHEN 'low' THEN 4 
            END, scheduled_date ASC
        ");

        $controlLists = $query->paginate(15);

        return response()->json([
            'success' => true,
            'data' => ControlListResource::collection($controlLists->items()),
            'pagination' => [
                'current_page' => $controlLists->currentPage(),
                'per_page' => $controlLists->perPage(),
                'total' => $controlLists->total(),
                'last_page' => $controlLists->lastPage(),
            ]
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $this->authorize('create', ControlList::class);

        $validator = Validator::make($request->all(), [
            'machine_id' => 'required|exists:machines,id',
            'control_template_id' => 'nullable|exists:control_templates,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'control_items' => 'required|array|min:1',
            'control_items.*.title' => 'required|string|max:255',
            'control_items.*.type' => 'required|in:checkbox,text,number,select,photo',
            'control_items.*.required' => 'boolean',
            'priority' => 'required|in:low,medium,high,critical',
            'scheduled_date' => 'required|date|after_or_equal:today',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $validator->validated();
        $data['company_id'] = $request->get('user_company_id');
        $data['user_id'] = $request->user()->id;
        $data['status'] = 'pending';

        $controlList = ControlList::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Kontrol listesi başarıyla oluşturuldu.',
            'data' => new ControlListResource($controlList->load(['company', 'machine', 'controlTemplate', 'user']))
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(ControlList $controlList)
    {
        $this->authorize('view', $controlList);

        $controlList->load(['company', 'machine', 'controlTemplate', 'user', 'approver']);

        return response()->json([
            'success' => true,
            'data' => new ControlListResource($controlList)
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, ControlList $controlList)
    {
        $this->authorize('update', $controlList);

        $validator = Validator::make($request->all(), [
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'control_items' => 'sometimes|required|array|min:1',
            'control_items.*.title' => 'required|string|max:255',
            'control_items.*.type' => 'required|in:checkbox,text,number,select,photo',
            'control_items.*.value' => 'nullable',
            'control_items.*.completed' => 'boolean',
            'priority' => 'sometimes|required|in:low,medium,high,critical',
            'scheduled_date' => 'sometimes|required|date',
            'status' => 'sometimes|required|in:draft,pending,in_progress,completed',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $validator->validated();

        // Auto-update status based on completion
        if (isset($data['control_items'])) {
            $completedItems = collect($data['control_items'])->filter(function ($item) {
                return isset($item['completed']) && $item['completed'] === true;
            })->count();

            $totalItems = count($data['control_items']);
            
            if ($completedItems === $totalItems && $totalItems > 0) {
                $data['status'] = 'completed';
                $data['completed_date'] = now();
            } elseif ($completedItems > 0) {
                $data['status'] = 'in_progress';
            }
        }

        $controlList->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Kontrol listesi güncellendi.',
            'data' => new ControlListResource($controlList->fresh(['company', 'machine', 'controlTemplate', 'user', 'approver']))
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(ControlList $controlList)
    {
        $this->authorize('delete', $controlList);

        $controlList->delete();

        return response()->json([
            'success' => true,
            'message' => 'Kontrol listesi başarıyla silindi.'
        ]);
    }

    /**
     * Approve the control list.
     */
    public function approve(Request $request, ControlList $controlList)
    {
        $this->authorize('approve', $controlList);

        $validator = Validator::make($request->all(), [
            'notes' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $controlList->approve($request->user(), $request->get('notes'));

        return response()->json([
            'success' => true,
            'message' => 'Kontrol listesi onaylandı.',
            'data' => new ControlListResource($controlList->fresh(['company', 'machine', 'controlTemplate', 'user', 'approver']))
        ]);
    }

    /**
     * Reject the control list.
     */
    public function reject(Request $request, ControlList $controlList)
    {
        $this->authorize('reject', $controlList);

        $validator = Validator::make($request->all(), [
            'reason' => 'required|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $controlList->reject($request->user(), $request->get('reason'));

        return response()->json([
            'success' => true,
            'message' => 'Kontrol listesi reddedildi.',
            'data' => new ControlListResource($controlList->fresh(['company', 'machine', 'controlTemplate', 'user', 'approver']))
        ]);
    }
}
