<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Company extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'uuid',
        'name',
        'trade_name',
        'tax_number',
        'tax_office',
        'address',
        'city',
        'district',
        'postal_code',
        'phone',
        'email',
        'website',
        'logo',
        'status',
        'subscription_plan',
        'subscription_expires_at',
        'settings',
    ];

    protected function casts(): array
    {
        return [
            'subscription_plan' => 'array',
            'subscription_expires_at' => 'datetime',
            'settings' => 'array',
            'deleted_at' => 'datetime',
        ];
    }

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
    public function users()
    {
        return $this->hasMany(User::class);
    }

    public function machines()
    {
        return $this->hasMany(Machine::class);
    }

    public function controlLists()
    {
        return $this->hasMany(ControlList::class);
    }

    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }

    /**
     * Scopes
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    /**
     * Helper methods
     */
    public function isActive()
    {
        return $this->status === 'active';
    }

    public function hasActiveSubscription()
    {
        return $this->subscription_expires_at && $this->subscription_expires_at->isFuture();
    }

    public function getActiveSubscription()
    {
        return $this->subscriptions()
            ->where('status', 'active')
            ->where('expires_at', '>', now())
            ->first();
    }
}
