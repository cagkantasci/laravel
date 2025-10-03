<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolePermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Create permissions
        $permissions = [
            // Dashboard
            'view_dashboard',
            'view_analytics',

            // Companies
            'view_companies',
            'create_companies',
            'edit_companies',
            'delete_companies',

            // Users
            'view_users',
            'create_users',
            'edit_users',
            'delete_users',
            'manage_user_roles',
            'edit_own_profile',

            // Machines
            'view_machines',
            'create_machines',
            'edit_machines',
            'delete_machines',
            'view_machine_qr',
            'assign_machines',

            // Control Templates
            'view_control_templates',
            'create_control_templates',
            'edit_control_templates',
            'delete_control_templates',

            // Control Lists
            'view_control_lists',
            'create_control_lists',
            'edit_control_lists',
            'delete_control_lists',
            'assign_control_lists',
            'fill_control_lists',
            'approve_control_lists',
            'reject_control_lists',

            // Work Sessions
            'view_work_sessions',
            'create_work_sessions',
            'edit_work_sessions',
            'delete_work_sessions',
            'approve_work_sessions',
            'reject_work_sessions',
            'view_own_work_sessions',

            // Reports
            'view_reports',
            'export_reports',
            'view_machine_reports',
            'view_user_reports',

            // Settings
            'view_settings',
            'edit_settings',

            // Pricing
            'view_pricing',
            'manage_pricing',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission, 'guard_name' => 'web']);
        }

        // Create roles and assign permissions

        // Admin - Full access
        $admin = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'web']);
        $admin->givePermissionTo(Permission::all());

        // Manager - Company management
        $manager = Role::firstOrCreate(['name' => 'manager', 'guard_name' => 'web']);
        $manager->syncPermissions([
            // Dashboard
            'view_dashboard',
            'view_analytics',

            // Users (within company)
            'view_users',
            'create_users',
            'edit_users',

            // Machines
            'view_machines',
            'create_machines',
            'edit_machines',
            'view_machine_qr',

            // Control Templates
            'view_control_templates',
            'create_control_templates',
            'edit_control_templates',
            'delete_control_templates',

            // Control Lists
            'view_control_lists',
            'create_control_lists',
            'edit_control_lists',
            'assign_control_lists',
            'approve_control_lists',
            'reject_control_lists',

            // Work Sessions
            'view_work_sessions',
            'approve_work_sessions',
            'reject_work_sessions',

            // Reports
            'view_reports',
            'export_reports',
            'view_machine_reports',
            'view_user_reports',

            // Settings
            'view_settings',
        ]);

        // Operator - Very limited access (only assigned machines, work sessions, control lists)
        $operator = Role::firstOrCreate(['name' => 'operator', 'guard_name' => 'web']);
        $operator->syncPermissions([
            // NO Dashboard access

            // Machines (only assigned machines)
            'view_machines',

            // Control Lists (fill only)
            'view_control_lists',
            'fill_control_lists',

            // Work Sessions (own only)
            'view_own_work_sessions',
            'create_work_sessions',

            // Profile
            'edit_own_profile',
        ]);

        $this->command->info('Roles and permissions created successfully!');

        // Display role permissions
        $this->command->info("\n=== Role Permissions ===");
        $this->command->info("\nAdmin: " . $admin->permissions->count() . " permissions (all)");
        $this->command->info("\nManager permissions:");
        foreach ($manager->permissions as $perm) {
            $this->command->info("  - " . $perm->name);
        }
        $this->command->info("\nOperator permissions:");
        foreach ($operator->permissions as $perm) {
            $this->command->info("  - " . $perm->name);
        }
    }
}
