<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Subscription;
use App\Models\Company;
use Carbon\Carbon;
use Illuminate\Support\Str;

class SubscriptionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $companies = Company::all();
        
        if ($companies->isEmpty()) {
            $this->command->warn('No companies found. Please run CompanySeeder first.');
            return;
        }

        $plans = [
            'starter' => [
                'monthly_price' => 299,
                'max_machines' => 10,
                'max_managers' => 2,
                'max_operators' => 20,
                'features' => ['basic_reporting', 'mobile_app', 'email_support']
            ],
            'professional' => [
                'monthly_price' => 799,
                'max_machines' => 50,
                'max_managers' => 5,
                'max_operators' => 100,
                'features' => ['advanced_reporting', 'api_access', 'priority_support', 'qr_integration']
            ],
            'enterprise' => [
                'monthly_price' => 1499,
                'max_machines' => -1, // unlimited
                'max_managers' => -1, // unlimited
                'max_operators' => -1, // unlimited
                'features' => ['custom_features', '24x7_support', 'dedicated_manager', 'sla_guarantee']
            ]
        ];

        foreach ($companies as $company) {
            // Randomly assign a plan
            $planName = array_rand($plans);
            $planDetails = $plans[$planName];
            
            // Random start date in the last 6 months
            $startDate = Carbon::now()->subMonths(rand(1, 6));
            $expiresAt = $startDate->copy()->addYear();
            $nextBillingDate = $startDate->copy()->addMonth();

            // Some companies might have expired or cancelled subscriptions
            $status = 'active';
            if (rand(1, 100) <= 10) { // 10% chance of inactive/expired
                $status = rand(1, 2) === 1 ? 'expired' : 'cancelled';
                $expiresAt = Carbon::now()->subDays(rand(1, 30));
            } elseif (rand(1, 100) <= 5) { // 5% chance of trial
                $status = 'active';
                $startDate = Carbon::now()->subDays(rand(1, 14));
                $expiresAt = $startDate->copy()->addDays(14);
                $planName = 'starter'; // Trials usually start with basic plan
            }

            Subscription::create([
                'uuid' => Str::uuid(),
                'company_id' => $company->id,
                'plan_name' => $planName,
                'monthly_price' => $planDetails['monthly_price'],
                'max_machines' => $planDetails['max_machines'],
                'max_managers' => $planDetails['max_managers'],
                'max_operators' => $planDetails['max_operators'],
                'features' => json_encode($planDetails['features']),
                'status' => $status,
                'starts_at' => $startDate->toDateString(),
                'expires_at' => $expiresAt->toDateString(),
                'next_billing_date' => $status === 'active' ? $nextBillingDate->toDateString() : null,
                'billing_cycle' => 'monthly',
                'payment_details' => json_encode([
                    'method' => 'credit_card',
                    'last_four' => '****' . str_pad(rand(1000, 9999), 4, '0', STR_PAD_LEFT)
                ]),
                'created_at' => $startDate,
                'updated_at' => $startDate,
            ]);
        }

        $this->command->info('Subscription data seeded successfully!');
    }
}
