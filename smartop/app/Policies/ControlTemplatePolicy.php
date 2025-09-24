<?php

namespace App\Policies;

use App\Models\ControlTemplate;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class ControlTemplatePolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->can('control-templates.view');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, ControlTemplate $controlTemplate): bool
    {
        if ($user->hasRole('admin')) {
            return true;
        }

        // Users can only view templates from their company
        return $user->company_id === $controlTemplate->company_id && $user->can('control-templates.view');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->can('control-templates.create');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, ControlTemplate $controlTemplate): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('control-templates.update');
        }

        // Managers from the same company can update
        return $user->hasRole('manager') &&
               $user->company_id === $controlTemplate->company_id && 
               $user->can('control-templates.update');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, ControlTemplate $controlTemplate): bool
    {
        return false;
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, ControlTemplate $controlTemplate): bool
    {
        return false;
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, ControlTemplate $controlTemplate): bool
    {
        return false;
    }
}
