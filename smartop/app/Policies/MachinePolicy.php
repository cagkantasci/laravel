<?php

namespace App\Policies;

use App\Models\Machine;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class MachinePolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->can('machines.view');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Machine $machine): bool
    {
        if ($user->hasRole('admin')) {
            return true;
        }

        // Users can only view machines from their company
        return $user->company_id === $machine->company_id && $user->can('machines.view');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->can('machines.create');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Machine $machine): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('machines.update');
        }

        // Users can only update machines from their company
        return $user->company_id === $machine->company_id && $user->can('machines.update');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Machine $machine): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('machines.delete');
        }

        // Managers can delete machines from their company
        return $user->hasRole('manager') && 
               $user->company_id === $machine->company_id && 
               $user->can('machines.delete');
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, Machine $machine): bool
    {
        return $user->hasRole(['admin', 'manager']);
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, Machine $machine): bool
    {
        return $user->hasRole('admin') && $user->can('machines.delete');
    }
}
