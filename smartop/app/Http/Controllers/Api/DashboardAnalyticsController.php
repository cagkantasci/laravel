<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\User;
use App\Models\Machine;
use App\Models\Subscription;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardAnalyticsController extends Controller
{
    /**
     * Get comprehensive financial and system analytics
     */
    public function getAnalytics(Request $request)
    {
        $startDate = $request->get('start_date', now()->startOfMonth()->toDateString());
        $endDate = $request->get('end_date', now()->toDateString());
        
        $currentMonth = Carbon::parse($startDate);
        $previousMonth = $currentMonth->copy()->subMonth();
        
        return response()->json([
            'success' => true,
            'data' => [
                'financial_summary' => $this->getFinancialSummary($startDate, $endDate),
                'monthly_trends' => $this->getMonthlyTrends($currentMonth, $previousMonth),
                'system_metrics' => $this->getSystemMetrics(),
                'subscription_breakdown' => $this->getSubscriptionBreakdown(),
                'revenue_trends' => $this->getRevenueTrends(),
                'customer_metrics' => $this->getCustomerMetrics()
            ]
        ]);
    }

    /**
     * Calculate financial summary based on subscriptions
     */
    private function getFinancialSummary($startDate, $endDate)
    {
        // Calculate revenue from active subscriptions
        $activeSubscriptions = Subscription::where('status', 'active')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->get();

        $totalRevenue = $activeSubscriptions->sum('monthly_price');
        
        // Calculate projected annual revenue
        $monthlyRecurring = Subscription::where('status', 'active')->sum('monthly_price');
        $annualRevenue = $monthlyRecurring * 12;

        // Calculate churn and growth
        $previousMonthRevenue = Subscription::where('status', 'active')
            ->whereMonth('created_at', Carbon::parse($startDate)->subMonth()->month)
            ->sum('monthly_price');

        $growthRate = $previousMonthRevenue > 0 
            ? (($totalRevenue - $previousMonthRevenue) / $previousMonthRevenue) * 100 
            : 0;

        return [
            'current_month_revenue' => $totalRevenue,
            'monthly_recurring_revenue' => $monthlyRecurring,
            'projected_annual_revenue' => $annualRevenue,
            'growth_rate' => round($growthRate, 2),
            'currency' => 'TRY'
        ];
    }

    /**
     * Get monthly trends comparison
     */
    private function getMonthlyTrends($currentMonth, $previousMonth)
    {
        $currentData = $this->getMonthData($currentMonth);
        $previousData = $this->getMonthData($previousMonth);

        return [
            'current_month' => $currentData,
            'previous_month' => $previousData,
            'trends' => [
                'revenue_change' => $this->calculatePercentageChange($previousData['revenue'], $currentData['revenue']),
                'customers_change' => $this->calculatePercentageChange($previousData['new_customers'], $currentData['new_customers']),
                'subscriptions_change' => $this->calculatePercentageChange($previousData['new_subscriptions'], $currentData['new_subscriptions'])
            ]
        ];
    }

    /**
     * Get data for specific month
     */
    private function getMonthData($month)
    {
        $startOfMonth = $month->copy()->startOfMonth();
        $endOfMonth = $month->copy()->endOfMonth();

        $revenue = Subscription::where('status', 'active')
            ->whereBetween('created_at', [$startOfMonth, $endOfMonth])
            ->sum('monthly_price');

        $newCustomers = Company::whereBetween('created_at', [$startOfMonth, $endOfMonth])
            ->count();

        $newSubscriptions = Subscription::whereBetween('created_at', [$startOfMonth, $endOfMonth])
            ->count();

        return [
            'month' => $month->format('Y-m'),
            'revenue' => $revenue,
            'new_customers' => $newCustomers,
            'new_subscriptions' => $newSubscriptions
        ];
    }

    /**
     * Get system-wide metrics
     */
    private function getSystemMetrics()
    {
        return [
            'total_companies' => Company::where('status', 'active')->count(),
            'total_users' => User::count(),
            'total_machines' => Machine::count(),
            'active_subscriptions' => Subscription::where('status', 'active')->count(),
            'trial_companies' => Company::where('status', 'trial')->count(),
            'inactive_companies' => Company::where('status', 'inactive')->count()
        ];
    }

    /**
     * Get subscription plan breakdown
     */
    private function getSubscriptionBreakdown()
    {
        $planBreakdown = Subscription::where('status', 'active')
            ->select('plan_name', DB::raw('count(*) as count'), DB::raw('sum(monthly_price) as revenue'))
            ->groupBy('plan_name')
            ->get();

        $planDetails = [
            'starter' => ['name' => 'Başlangıç', 'price' => 299, 'color' => '#3B82F6'],
            'professional' => ['name' => 'Profesyonel', 'price' => 799, 'color' => '#10B981'],
            'enterprise' => ['name' => 'Kurumsal', 'price' => 1499, 'color' => '#8B5CF6']
        ];

        return $planBreakdown->map(function ($plan) use ($planDetails) {
            $details = $planDetails[$plan->plan_name] ?? ['name' => $plan->plan_name, 'price' => 0, 'color' => '#6B7280'];
            
            return [
                'plan_name' => $plan->plan_name,
                'plan_display_name' => $details['name'],
                'subscribers' => $plan->count,
                'revenue' => $plan->revenue,
                'base_price' => $details['price'],
                'color' => $details['color']
            ];
        });
    }

    /**
     * Get revenue trends for charts
     */
    private function getRevenueTrends()
    {
        $months = [];
        $revenues = [];

        // Get last 12 months data
        for ($i = 11; $i >= 0; $i--) {
            $month = now()->subMonths($i);
            $monthStart = $month->copy()->startOfMonth();
            $monthEnd = $month->copy()->endOfMonth();

            $monthRevenue = Subscription::where('status', 'active')
                ->where(function ($query) use ($monthStart, $monthEnd) {
                    $query->whereBetween('created_at', [$monthStart, $monthEnd])
                          ->orWhere(function ($q) use ($monthStart) {
                              $q->where('created_at', '<', $monthStart)
                                ->where('expires_at', '>', $monthStart);
                          });
                })
                ->sum('monthly_price');

            $months[] = $month->format('M Y');
            $revenues[] = $monthRevenue;
        }

        return [
            'months' => $months,
            'revenues' => $revenues
        ];
    }

    /**
     * Get customer acquisition and retention metrics
     */
    private function getCustomerMetrics()
    {
        $thisMonth = now()->startOfMonth();
        $lastMonth = now()->subMonth()->startOfMonth();

        return [
            'new_customers_this_month' => Company::where('created_at', '>=', $thisMonth)->count(),
            'new_customers_last_month' => Company::whereBetween('created_at', [
                $lastMonth, 
                $lastMonth->copy()->endOfMonth()
            ])->count(),
            'churn_rate' => $this->calculateChurnRate(),
            'customer_lifetime_value' => $this->calculateCustomerLifetimeValue(),
            'average_revenue_per_user' => $this->calculateARPU()
        ];
    }

    /**
     * Calculate churn rate
     */
    private function calculateChurnRate()
    {
        $startOfMonth = now()->startOfMonth();
        $activeAtStart = Subscription::where('status', 'active')
            ->where('created_at', '<', $startOfMonth)
            ->count();

        $cancelledThisMonth = Subscription::where('status', 'cancelled')
            ->where('updated_at', '>=', $startOfMonth)
            ->count();

        return $activeAtStart > 0 ? round(($cancelledThisMonth / $activeAtStart) * 100, 2) : 0;
    }

    /**
     * Calculate Customer Lifetime Value
     */
    private function calculateCustomerLifetimeValue()
    {
        $avgMonthlyRevenue = Subscription::where('status', 'active')->avg('monthly_price');
        $avgLifetimeMonths = 24; // Assume 2 years average

        return round($avgMonthlyRevenue * $avgLifetimeMonths, 2);
    }

    /**
     * Calculate Average Revenue Per User
     */
    private function calculateARPU()
    {
        $totalRevenue = Subscription::where('status', 'active')->sum('monthly_price');
        $totalCustomers = Company::where('status', 'active')->count();

        return $totalCustomers > 0 ? round($totalRevenue / $totalCustomers, 2) : 0;
    }

    /**
     * Calculate percentage change
     */
    private function calculatePercentageChange($old, $new)
    {
        if ($old == 0) {
            return $new > 0 ? 100 : 0;
        }

        return round((($new - $old) / $old) * 100, 2);
    }
}