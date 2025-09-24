<?php

namespace App\Policies;

use App\Models\ControlList;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class ControlListPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->can('control-lists.view');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, ControlList $controlList): bool
    {
        if ($user->hasRole('admin')) {
            return true;
        }

        // Users can only view control lists from their company
        return $user->company_id === $controlList->company_id && $user->can('control-lists.view');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->can('control-lists.create');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, ControlList $controlList): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('control-lists.update');
        }

        // Only the creator or managers from the same company can update
        return ($user->id === $controlList->user_id || $user->hasRole('manager')) &&
               $user->company_id === $controlList->company_id && 
               $user->can('control-lists.update');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, ControlList $controlList): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('control-lists.delete');
        }

        // Only managers from the same company can delete (not operators)
        return $user->hasRole('manager') &&
               $user->company_id === $controlList->company_id && 
               $user->can('control-lists.delete');
    }

    /**
     * Determine whether the user can approve the model.
     */
    public function approve(User $user, ControlList $controlList): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('control-lists.approve');
        }

        // Only managers from the same company can approve
        return $user->hasRole('manager') &&
               $user->company_id === $controlList->company_id && 
               $user->can('control-lists.approve') &&
               $controlList->canBeApproved();
    }

    /**
     * Determine whether the user can reject the model.
     */
    public function reject(User $user, ControlList $controlList): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('control-lists.reject');
        }

        // Only managers from the same company can reject
        return $user->hasRole('manager') &&
               $user->company_id === $controlList->company_id && 
               $user->can('control-lists.reject');
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, ControlList $controlList): bool
    {
        return $user->hasRole(['admin', 'manager']);
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, ControlList $controlList): bool
    {
        return $user->hasRole('admin') && $user->can('control-lists.delete');
    }
}
