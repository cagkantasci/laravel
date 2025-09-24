<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ControlTemplate;
use App\Http\Resources\ControlTemplateResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class ControlTemplateController extends Controller
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
        $this->authorize('viewAny', ControlTemplate::class);

        $user = $request->user();
        $companyId = $request->get('user_company_id');

        $query = ControlTemplate::with(['company:id,name', 'creator:id,name']);

        // Apply company filter for non-admin users
        if (!$user->hasRole('admin')) {
            $query->where('company_id', $companyId);
        }

        // Apply filters
        if ($request->has('category')) {
            $query->where('category', $request->get('category'));
        }

        if ($request->has('machine_type')) {
            $query->byMachineType($request->get('machine_type'));
        }

        if ($request->has('active')) {
            $active = $request->boolean('active');
            $query->where('is_active', $active);
        }

        if ($request->has('search')) {
            $search = $request->get('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('category', 'like', "%{$search}%");
            });
        }

        $templates = $query->paginate(15);

        return response()->json([
            'success' => true,
            'data' => ControlTemplateResource::collection($templates->items()),
            'pagination' => [
                'current_page' => $templates->currentPage(),
                'per_page' => $templates->perPage(),
                'total' => $templates->total(),
                'last_page' => $templates->lastPage(),
            ]
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $this->authorize('create', ControlTemplate::class);

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'required|string|max:100',
            'machine_types' => 'nullable|array',
            'machine_types.*' => 'string|max:100',
            'template_items' => 'required|array|min:1',
            'template_items.*.title' => 'required|string|max:255',
            'template_items.*.description' => 'nullable|string',
            'template_items.*.type' => 'required|in:checkbox,text,number,select,photo',
            'template_items.*.required' => 'boolean',
            'template_items.*.options' => 'nullable|array',
            'estimated_duration' => 'nullable|integer|min:1',
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $validator->validated();
        $data['company_id'] = $request->get('user_company_id');
        $data['created_by'] = $request->user()->id;

        $template = ControlTemplate::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Kontrol şablonu başarıyla oluşturuldu.',
            'data' => new ControlTemplateResource($template->load(['company', 'creator']))
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(ControlTemplate $controlTemplate)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
