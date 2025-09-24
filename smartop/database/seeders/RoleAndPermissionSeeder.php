<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RoleAndPermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Create permissions
        $permissions = [
            // Company management
            'companies.view',
            'companies.create',
            'companies.update',
            'companies.delete',
            
            // User management
            'users.view',
            'users.create',
            'users.update',
            'users.delete',
            
            // Machine management
            'machines.view',
            'machines.create',
            'machines.update',
            'machines.delete',
            
            // Control lists
            'control-lists.view',
            'control-lists.create',
            'control-lists.update',
            'control-lists.delete',
            'control-lists.approve',
            'control-lists.reject',
            
            // Control templates
            'control-templates.view',
            'control-templates.create',
            'control-templates.update',
            'control-templates.delete',
            
            // Reports
            'reports.view',
            'reports.export',
            
            // System settings
            'settings.view',
            'settings.update',
            
            // Subscriptions
            'subscriptions.view',
            'subscriptions.manage',
            
            // Audit logs
            'audit-logs.view',
        ];

        foreach ($permissions as $permission) {
            Permission::create(['name' => $permission]);
        }

        // Create roles and assign permissions
        
        // Admin role - Full access
        $adminRole = Role::create(['name' => 'admin']);
        $adminRole->givePermissionTo(Permission::all());

        // Manager role - Company level management
        $managerRole = Role::create(['name' => 'manager']);
        $managerRole->givePermissionTo([
            // Company (own company only)
            'companies.view',
            'companies.update',
            
            // Users in their company
            'users.view',
            'users.create',
            'users.update',
            
            // Machines in their company
            'machines.view',
            'machines.create',
            'machines.update',
            'machines.delete',
            
            // Control lists
            'control-lists.view',
            'control-lists.approve',
            'control-lists.reject',
            
            // Control templates
            'control-templates.view',
            'control-templates.create',
            'control-templates.update',
            'control-templates.delete',
            
            // Reports
            'reports.view',
            'reports.export',
        ]);

        // Operator role - Limited access
        $operatorRole = Role::create(['name' => 'operator']);
        $operatorRole->givePermissionTo([
            // View assigned machines
            'machines.view',
            
            // Create and view their own control lists
            'control-lists.view',
            'control-lists.create',
            'control-lists.update',
            
            // View control templates
            'control-templates.view',
        ]);
    }
}
