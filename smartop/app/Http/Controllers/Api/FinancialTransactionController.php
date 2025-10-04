<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FinancialTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class FinancialTransactionController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth:sanctum', 'role:admin|manager']);
    }

    /**
     * Display a listing of financial transactions
     */
    public function index(Request $request)
    {
        $user = Auth::user();
        $companyId = $user->company_id;

        $query = FinancialTransaction::where('company_id', $companyId)
            ->with(['user:id,name,email']);

        // Filters
        if ($request->has('type') && in_array($request->type, ['income', 'expense'])) {
            $query->where('type', $request->type);
        }

        if ($request->has('category')) {
            $query->byCategory($request->category);
        }

        if ($request->has('start_date') && $request->has('end_date')) {
            $query->byDateRange($request->start_date, $request->end_date);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('reference_number', 'like', "%{$search}%");
            });
        }

        $transactions = $query->orderBy('transaction_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $transactions,
        ]);
    }

    /**
     * Store a newly created financial transaction
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:income,expense',
            'category' => 'required|string|max:255',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'amount' => 'required|numeric|min:0.01',
            'currency' => 'nullable|string|size:3',
            'transaction_date' => 'required|date',
            'status' => 'nullable|in:pending,completed,cancelled',
            'reference_number' => 'nullable|string|max:255',
            'payment_method' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = Auth::user();
        
        $transaction = FinancialTransaction::create([
            'company_id' => $user->company_id,
            'user_id' => $user->id,
            'type' => $request->type,
            'category' => $request->category,
            'title' => $request->title,
            'description' => $request->description,
            'amount' => $request->amount,
            'currency' => $request->get('currency', 'TRY'),
            'transaction_date' => $request->transaction_date,
            'status' => $request->get('status', 'completed'),
            'reference_number' => $request->reference_number,
            'payment_method' => $request->payment_method,
            'metadata' => $request->metadata,
        ]);

        $transaction->load('user:id,name,email');

        return response()->json([
            'success' => true,
            'message' => 'Financial transaction created successfully',
            'data' => $transaction,
        ], 201);
    }

    /**
     * Display the specified financial transaction
     */
    public function show(string $uuid)
    {
        $user = Auth::user();
        
        $transaction = FinancialTransaction::where('company_id', $user->company_id)
            ->where('uuid', $uuid)
            ->with(['user:id,name,email'])
            ->first();

        if (!$transaction) {
            return response()->json([
                'success' => false,
                'message' => 'Financial transaction not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $transaction,
        ]);
    }

    /**
     * Update the specified financial transaction
     */
    public function update(Request $request, string $uuid)
    {
        $user = Auth::user();
        
        $transaction = FinancialTransaction::where('company_id', $user->company_id)
            ->where('uuid', $uuid)
            ->first();

        if (!$transaction) {
            return response()->json([
                'success' => false,
                'message' => 'Financial transaction not found',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'type' => 'sometimes|required|in:income,expense',
            'category' => 'sometimes|required|string|max:255',
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'amount' => 'sometimes|required|numeric|min:0.01',
            'currency' => 'nullable|string|size:3',
            'transaction_date' => 'sometimes|required|date',
            'status' => 'nullable|in:pending,completed,cancelled',
            'reference_number' => 'nullable|string|max:255',
            'payment_method' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors(),
            ], 422);
        }

        $transaction->update($request->only([
            'type', 'category', 'title', 'description', 'amount', 'currency',
            'transaction_date', 'status', 'reference_number', 'payment_method', 'metadata'
        ]));

        $transaction->load('user:id,name,email');

        return response()->json([
            'success' => true,
            'message' => 'Financial transaction updated successfully',
            'data' => $transaction,
        ]);
    }

    /**
     * Remove the specified financial transaction
     */
    public function destroy(string $uuid)
    {
        $user = Auth::user();
        
        $transaction = FinancialTransaction::where('company_id', $user->company_id)
            ->where('uuid', $uuid)
            ->first();

        if (!$transaction) {
            return response()->json([
                'success' => false,
                'message' => 'Financial transaction not found',
            ], 404);
        }

        $transaction->delete();

        return response()->json([
            'success' => true,
            'message' => 'Financial transaction deleted successfully',
        ]);
    }

    /**
     * Get financial summary statistics
     */
    public function summary(Request $request)
    {
        $user = Auth::user();
        $companyId = $user->company_id;

        $startDate = $request->get('start_date', Carbon::now()->startOfMonth());
        $endDate = $request->get('end_date', Carbon::now()->endOfMonth());

        $transactions = FinancialTransaction::where('company_id', $companyId)
            ->byDateRange($startDate, $endDate)
            ->where('status', 'completed');

        $totalIncome = $transactions->clone()->income()->sum('amount');
        $totalExpense = $transactions->clone()->expense()->sum('amount');
        $netProfit = $totalIncome - $totalExpense;

        // Category breakdown
        $incomeByCategory = $transactions->clone()->income()
            ->selectRaw('category, SUM(amount) as total')
            ->groupBy('category')
            ->pluck('total', 'category');

        $expenseByCategory = $transactions->clone()->expense()
            ->selectRaw('category, SUM(amount) as total')
            ->groupBy('category')
            ->pluck('total', 'category');

        return response()->json([
            'success' => true,
            'data' => [
                'period' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                ],
                'summary' => [
                    'total_income' => $totalIncome,
                    'total_expense' => $totalExpense,
                    'net_profit' => $netProfit,
                    'currency' => 'TRY',
                ],
                'income_by_category' => $incomeByCategory,
                'expense_by_category' => $expenseByCategory,
            ],
        ]);
    }

    /**
     * Get available categories
     */
    public function categories()
    {
        $user = Auth::user();
        
        $categories = FinancialTransaction::where('company_id', $user->company_id)
            ->select('category', 'type')
            ->distinct()
            ->get()
            ->groupBy('type');

        return response()->json([
            'success' => true,
            'data' => [
                'income_categories' => $categories->get('income', collect())->pluck('category')->values(),
                'expense_categories' => $categories->get('expense', collect())->pluck('category')->values(),
            ],
        ]);
    }
}
