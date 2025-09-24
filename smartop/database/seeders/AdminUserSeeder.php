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
        // Create a demo company
        $company = Company::create([
            'name' => 'SmartOp Demo Company',
            'trade_name' => 'SmartOp Teknoloji',
            'tax_number' => '1234567890',
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
        ]);

        // Create admin user
        $admin = User::create([
            'name' => 'Admin User',
            'email' => 'admin@smartop.com',
            'password' => Hash::make('password'),
            'company_id' => $company->id,
            'status' => 'active',
            'phone' => '+90 555 111 1111',
        ]);

        // Assign admin role
        $admin->assignRole('admin');

        // Create a manager user
        $manager = User::create([
            'name' => 'Manager User',
            'email' => 'manager@smartop.com',
            'password' => Hash::make('password'),
            'company_id' => $company->id,
            'status' => 'active',
            'phone' => '+90 555 222 2222',
        ]);

        // Assign manager role
        $manager->assignRole('manager');

        // Create an operator user
        $operator = User::create([
            'name' => 'Operator User',
            'email' => 'operator@smartop.com',
            'password' => Hash::make('password'),
            'company_id' => $company->id,
            'status' => 'active',
            'phone' => '+90 555 333 3333',
        ]);

        // Assign operator role
        $operator->assignRole('operator');
    }
}
