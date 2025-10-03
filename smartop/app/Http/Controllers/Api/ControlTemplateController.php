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

    // Middleware is applied in routes/api.php

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

        // Map template_items to control_items for database
        if (isset($data['template_items'])) {
            $data['control_items'] = $data['template_items'];
            unset($data['template_items']);
        }

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
    public function show(Request $request, string $id)
    {
        $template = ControlTemplate::with(['company', 'creator'])->findOrFail($id);

        $this->authorize('view', $template);

        return response()->json([
            'success' => true,
            'data' => new ControlTemplateResource($template)
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $template = ControlTemplate::findOrFail($id);

        $this->authorize('update', $template);

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
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $validator->validated();

        // Map template_items to control_items for database
        if (isset($data['template_items'])) {
            $data['control_items'] = $data['template_items'];
            unset($data['template_items']);
        }

        $template->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Kontrol şablonu başarıyla güncellendi.',
            'data' => new ControlTemplateResource($template->load(['company', 'creator']))
        ]);
    }

    /**
     * Duplicate a control template.
     */
    public function duplicate(Request $request, string $id)
    {
        $template = ControlTemplate::findOrFail($id);

        $this->authorize('create', ControlTemplate::class);

        // Create a copy of the template
        $newTemplate = $template->replicate();
        $newTemplate->uuid = \Illuminate\Support\Str::uuid(); // Generate new UUID
        $newTemplate->name = $template->name . ' (Kopya)';
        $newTemplate->company_id = $request->get('user_company_id');
        $newTemplate->created_by = $request->user()->id;
        $newTemplate->save();

        return response()->json([
            'success' => true,
            'message' => 'Kontrol şablonu başarıyla kopyalandı.',
            'data' => new ControlTemplateResource($newTemplate->load(['company', 'creator']))
        ], 201);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        $template = ControlTemplate::findOrFail($id);

        $this->authorize('delete', $template);

        // Check if template is being used by any control lists
        if ($template->controlLists()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Bu şablon kullanımda olduğu için silinemez.'
            ], 422);
        }

        $template->delete();

        return response()->json([
            'success' => true,
            'message' => 'Kontrol şablonu başarıyla silindi.'
        ]);
    }
}
