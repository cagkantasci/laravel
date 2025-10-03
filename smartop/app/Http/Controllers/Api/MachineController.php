<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Machine;
use App\Http\Resources\MachineResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class MachineController extends Controller
{
    use AuthorizesRequests;

    // Middleware is applied in routes/api.php

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $this->authorize('viewAny', Machine::class);

        $user = $request->user();
        $companyId = $request->get('user_company_id');

        // Operator sadece atanan makineleri görür
        if ($user->hasRole('operator')) {
            $query = $user->assignedMachines()->with('company:id,name');
        } else {
            $query = Machine::with('company:id,name');

            // Apply company filter for non-admin users
            if (!$user->hasRole('admin')) {
                $query->where('company_id', $companyId);
            }
        }

        // Apply filters
        if ($request->has('type')) {
            $query->where('type', $request->get('type'));
        }

        if ($request->has('status')) {
            $query->where('status', $request->get('status'));
        }

        if ($request->has('search')) {
            $search = $request->get('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('model', 'like', "%{$search}%")
                  ->orWhere('serial_number', 'like', "%{$search}%");
            });
        }

        $machines = $query->paginate(15);

        return response()->json([
            'success' => true,
            'data' => MachineResource::collection($machines->items()),
            'pagination' => [
                'current_page' => $machines->currentPage(),
                'per_page' => $machines->perPage(),
                'total' => $machines->total(),
                'last_page' => $machines->lastPage(),
            ]
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $this->authorize('create', Machine::class);

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'type' => 'required|string|max:100',
            'model' => 'nullable|string|max:255',
            'serial_number' => 'nullable|string|max:100|unique:machines',
            'manufacturer' => 'nullable|string|max:255',
            'production_date' => 'nullable|date',
            'installation_date' => 'nullable|date',
            'specifications' => 'nullable|array',
            'location' => 'nullable|string|max:255',
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

        $machine = Machine::create($data);
        $machine->generateQrCode();

        return response()->json([
            'success' => true,
            'message' => 'Makine başarıyla oluşturuldu.',
            'data' => new MachineResource($machine)
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, Machine $machine)
    {
        $this->authorize('view', $machine);

        $user = $request->user();

        // Operator sadece atanan makineleri görebilir
        if ($user->hasRole('operator')) {
            $assignedMachineIds = $user->assignedMachines()->pluck('id')->toArray();
            if (!in_array($machine->id, $assignedMachineIds)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bu makineye erişim yetkiniz yok.'
                ], 403);
            }
        }

        $machine->load('company:id,name');

        return response()->json([
            'success' => true,
            'data' => new MachineResource($machine)
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Machine $machine)
    {
        $this->authorize('update', $machine);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'type' => 'sometimes|required|string|max:100',
            'model' => 'nullable|string|max:255',
            'serial_number' => 'nullable|string|max:100|unique:machines,serial_number,' . $machine->id,
            'manufacturer' => 'nullable|string|max:255',
            'production_date' => 'nullable|date',
            'installation_date' => 'nullable|date',
            'specifications' => 'nullable|array',
            'status' => 'sometimes|in:active,inactive,maintenance,decommissioned',
            'location' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $machine->update($validator->validated());

        return response()->json([
            'success' => true,
            'message' => 'Makine bilgileri güncellendi.',
            'data' => new MachineResource($machine)
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Machine $machine)
    {
        $this->authorize('delete', $machine);

        $machine->delete();

        return response()->json([
            'success' => true,
            'message' => 'Makine başarıyla silindi.'
        ]);
    }

    /**
     * Generate QR code for machine
     */
    public function generateQrCode(Machine $machine)
    {
        $this->authorize('update', $machine);

        $qrCode = $machine->generateQrCode();

        return response()->json([
            'success' => true,
            'message' => 'QR kod oluşturuldu.',
            'data' => [
                'qr_code' => $qrCode,
                'machine_id' => $machine->id,
            ]
        ]);
    }
}
