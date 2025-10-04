<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Subscription extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'uuid',
        'company_id',
        'plan_name',
        'monthly_price',
        'max_machines',
        'max_managers',
        'max_operators',
        'features',
        'status',
        'starts_at',
        'expires_at',
        'next_billing_date',
        'billing_cycle',
        'payment_details',
    ];

    protected function casts(): array
    {
        return [
            'monthly_price' => 'decimal:2',
            'features' => 'array',
            'payment_details' => 'array',
            'starts_at' => 'date',
            'expires_at' => 'date',
            'next_billing_date' => 'date',
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

    // Relationships
    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeExpired($query)
    {
        return $query->where('status', 'expired');
    }

    public function scopeCancelled($query)
    {
        return $query->where('status', 'cancelled');
    }

    // Accessors
    public function getIsActiveAttribute()
    {
        return $this->status === 'active' && $this->expires_at > now();
    }

    public function getIsExpiredAttribute()
    {
        return $this->expires_at <= now();
    }

    public function getDaysRemainingAttribute()
    {
        return $this->expires_at > now() ? $this->expires_at->diffInDays(now()) : 0;
    }
}
