<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Company;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        // Create or get demo company
        $company = Company::firstOrCreate(
            ['tax_number' => '1234567890'],
            [
                'name' => 'SmartOp Demo Company',
                'trade_name' => 'SmartOp Teknoloji',
                'tax_office' => 'Beşiktaş V.D.',
                'email' => 'demo@smartop.com',
                'phone' => '+90 555 123 4567',
                'address' => 'Demo Mahallesi, SmartOp Sokak No:1',
                'city' => 'İstanbul',
                'district' => 'Beşiktaş',
                'postal_code' => '34357',
                'website' => 'https://smartop.com',
                'status' => 'active',
                'subscription_plan' => json_encode([
                    'type' => 'premium',
                    'features' => ['unlimited_machines', 'advanced_reports', 'api_access']
                ]),
                'subscription_expires_at' => now()->addYear(),
            ]
        );

        // Create or update admin user
        $admin = User::updateOrCreate(
            ['email' => 'admin@smartop.com'],
            [
                'name' => 'Admin User',
                'password' => Hash::make('password'),
                'company_id' => $company->id,
                'status' => 'active',
                'phone' => '+90 555 111 1111',
            ]
        );

        // Assign admin role
        if (!$admin->hasRole('admin')) {
            $admin->assignRole('admin');
        }

        // Create or update manager user
        $manager = User::updateOrCreate(
            ['email' => 'manager@smartop.com'],
            [
                'name' => 'Manager User',
                'password' => Hash::make('password'),
                'company_id' => $company->id,
                'status' => 'active',
                'phone' => '+90 555 222 2222',
            ]
        );

        // Assign manager role
        if (!$manager->hasRole('manager')) {
            $manager->assignRole('manager');
        }

        // Create or update operator user
        $operator = User::updateOrCreate(
            ['email' => 'operator@smartop.com'],
            [
                'name' => 'Operator User',
                'password' => Hash::make('password'),
                'company_id' => $company->id,
                'status' => 'active',
                'phone' => '+90 555 333 3333',
            ]
        );

        // Assign operator role
        if (!$operator->hasRole('operator')) {
            $operator->assignRole('operator');
        }
    }
}
