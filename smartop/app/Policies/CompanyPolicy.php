<?php

namespace App\Policies;

use App\Models\Company;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class CompanyPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->can('view_companies');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Company $company): bool
    {
        if ($user->hasRole('admin')) {
            return true;
        }

        // Users can only view their own company
        return $user->company_id === $company->id && $user->can('view_companies');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->can('create_companies');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Company $company): bool
    {
        if ($user->hasRole('admin')) {
            return $user->can('edit_companies');
        }

        // Users can only update their own company
        return $user->company_id === $company->id && $user->can('edit_companies');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Company $company): bool
    {
        // Only admin can delete companies
        return $user->hasRole('admin') && $user->can('delete_companies');
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, Company $company): bool
    {
        return $user->hasRole('admin');
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, Company $company): bool
    {
        return $user->hasRole('admin') && $user->can('delete_companies');
    }
}
