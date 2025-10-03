<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;
use Illuminate\Support\Str;

class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens, HasRoles, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'uuid',
        'name',
        'email',
        'password',
        'phone',
        'identity_number',
        'birth_date',
        'gender',
        'profile_photo',
        'company_id',
        'status',
        'last_login_at',
        'preferences',
    ];

    /**
     * The attributes that should be hidden for serialization.
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'birth_date' => 'date',
            'last_login_at' => 'datetime',
            'preferences' => 'array',
            'deleted_at' => 'datetime',
        ];
    }

    /**
     * Boot method to generate UUID
     */
    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($model) {
            if (!$model->uuid) {
                $model->uuid = Str::uuid();
            }
        });
    }

    /**
     * Relationships
     */
    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function controlLists()
    {
        return $this->hasMany(ControlList::class, 'user_id');
    }

    public function approvedControlLists()
    {
        return $this->hasMany(ControlList::class, 'approved_by');
    }

    public function assignedMachines()
    {
        return $this->belongsToMany(Machine::class, 'machine_user', 'user_id', 'machine_id')
            ->withTimestamps();
    }

    public function workSessions()
    {
        return $this->hasMany(WorkSession::class, 'user_id');
    }

    public function devices()
    {
        return $this->hasMany(UserDevice::class, 'user_id');
    }

    /**
     * Scopes
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeByCompany($query, $companyId)
    {
        return $query->where('company_id', $companyId);
    }

    /**
     * Helper methods
     */
    public function isAdmin()
    {
        return $this->hasRole('admin');
    }

    public function isManager()
    {
        return $this->hasRole('manager');
    }

    public function isOperator()
    {
        return $this->hasRole('operator');
    }

    public function getFullNameAttribute()
    {
        return $this->name;
    }

    public function updateLastLogin()
    {
        $this->update(['last_login_at' => now()]);
    }
}
