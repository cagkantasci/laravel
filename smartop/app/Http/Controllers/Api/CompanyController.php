<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Http\Resources\CompanyResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class CompanyController extends Controller
{
    use AuthorizesRequests;

    // Middleware artık route tanımında yapılıyor (Laravel 11)
    // public function __construct()
    // {
    //     $this->middleware('auth:sanctum');
    //     $this->middleware('company')->except(['show']);
    // }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $this->authorize('viewAny', Company::class);

        $user = auth()->user();
        
        if ($user->hasRole('admin')) {
            // Admin can see all companies
            $companies = Company::with(['users:id,name,email,company_id'])
                ->paginate(15);
        } else {
            // Non-admin users can only see their own company
            $companies = Company::where('id', $user->company_id)
                ->with(['users:id,name,email,company_id'])
                ->paginate(15);
        }

        return response()->json([
            'success' => true,
            'data' => CompanyResource::collection($companies->items()),
            'pagination' => [
                'current_page' => $companies->currentPage(),
                'per_page' => $companies->perPage(),
                'total' => $companies->total(),
                'last_page' => $companies->lastPage(),
            ]
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $this->authorize('create', Company::class);

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'trade_name' => 'nullable|string|max:255',
            'tax_number' => 'required|string|max:20|unique:companies',
            'tax_office' => 'nullable|string|max:255',
            'email' => 'nullable|email|max:255',
            'phone' => 'nullable|string|max:20',
            'address' => 'nullable|string',
            'city' => 'nullable|string|max:100',
            'district' => 'nullable|string|max:100',
            'postal_code' => 'nullable|string|max:10',
            'website' => 'nullable|url|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $company = Company::create($validator->validated());

        return response()->json([
            'success' => true,
            'message' => 'Şirket başarıyla oluşturuldu.',
            'data' => new CompanyResource($company)
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Company $company)
    {
        $this->authorize('view', $company);

        $company->load(['users:id,name,email,company_id,status']);

        return response()->json([
            'success' => true,
            'data' => new CompanyResource($company)
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Company $company)
    {
        $this->authorize('update', $company);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'trade_name' => 'nullable|string|max:255',
            'tax_number' => 'sometimes|required|string|max:20|unique:companies,tax_number,' . $company->id,
            'tax_office' => 'nullable|string|max:255',
            'email' => 'nullable|email|max:255',
            'phone' => 'nullable|string|max:20',
            'address' => 'nullable|string',
            'city' => 'nullable|string|max:100',
            'district' => 'nullable|string|max:100',
            'postal_code' => 'nullable|string|max:10',
            'website' => 'nullable|url|max:255',
            'status' => 'sometimes|in:active,inactive,suspended',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $company->update($validator->validated());

        return response()->json([
            'success' => true,
            'message' => 'Şirket bilgileri güncellendi.',
            'data' => new CompanyResource($company)
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Company $company)
    {
        $this->authorize('delete', $company);

        $company->delete();

        return response()->json([
            'success' => true,
            'message' => 'Şirket başarıyla silindi.'
        ]);
    }
}
