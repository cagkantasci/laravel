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
        return $user->can('view_control_lists');
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
        return $user->company_id === $controlList->company_id && $user->can('view_control_lists');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->can('create_control_lists');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, ControlList $controlList): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('edit_control_lists');
        }

        // Only the creator or managers from the same company can update
        return ($user->id === $controlList->user_id || $user->hasRole('manager')) &&
               $user->company_id === $controlList->company_id &&
               $user->can('edit_control_lists');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, ControlList $controlList): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('delete_control_lists');
        }

        // Only managers from the same company can delete (not operators)
        return $user->hasRole('manager') &&
               $user->company_id === $controlList->company_id &&
               $user->can('delete_control_lists');
    }

    /**
     * Determine whether the user can approve the model.
     */
    public function approve(User $user, ControlList $controlList): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('approve_control_lists');
        }

        // Only managers from the same company can approve
        return $user->hasRole('manager') &&
               $user->company_id === $controlList->company_id &&
               $user->can('approve_control_lists') &&
               $controlList->canBeApproved();
    }

    /**
     * Determine whether the user can reject the model.
     */
    public function reject(User $user, ControlList $controlList): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('reject_control_lists');
        }

        // Only managers from the same company can reject
        return $user->hasRole('manager') &&
               $user->company_id === $controlList->company_id &&
               $user->can('reject_control_lists');
    }

    /**
     * Determine whether the user can revert approval/rejection.
     */
    public function revert(User $user, ControlList $controlList): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('approve_control_lists');
        }

        // Only managers from the same company can revert
        return $user->hasRole('manager') &&
               $user->company_id === $controlList->company_id &&
               $user->can('approve_control_lists');
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
        return $user->hasRole('admin') && $user->can('delete_control_lists');
    }

    /**
     * Determine whether the user can start the control list.
     * Only operators assigned to the control list can start it.
     */
    public function start(User $user, ControlList $controlList): bool
    {
        // Admin can start any control list
        if ($user->hasRole('admin')) {
            return true;
        }

        // Only the assigned user (operator) can start the control list
        return $user->id === $controlList->user_id &&
               $user->company_id === $controlList->company_id &&
               $controlList->status === 'pending';
    }

    /**
     * Determine whether the user can complete the control list.
     * Only operators assigned to the control list can complete it.
     */
    public function complete(User $user, ControlList $controlList): bool
    {
        // Admin can complete any control list
        if ($user->hasRole('admin')) {
            return true;
        }

        // Only the assigned user (operator) can complete the control list
        return $user->id === $controlList->user_id &&
               $user->company_id === $controlList->company_id &&
               in_array($controlList->status, ['pending', 'in_progress']);
    }

    /**
     * Determine whether the user can update control list items.
     * Only operators assigned to the control list can update items.
     */
    public function updateItems(User $user, ControlList $controlList): bool
    {
        // Admin can update any control list items
        if ($user->hasRole('admin')) {
            return true;
        }

        // Only the assigned user (operator) can update items
        return $user->id === $controlList->user_id &&
               $user->company_id === $controlList->company_id &&
               in_array($controlList->status, ['pending', 'in_progress']);
    }
}
