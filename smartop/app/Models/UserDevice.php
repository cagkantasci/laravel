<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class UserDevice extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'device_id',
        'device_name',
        'device_model',
        'platform',
        'fcm_token',
        'app_version',
        'os_version',
        'is_active',
        'last_used_at'
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'last_used_at' => 'datetime'
    ];

    protected $hidden = [
        'fcm_token'
    ];

    /**
     * Get the user that owns the device.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope to get only active devices.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope to get devices by platform.
     */
    public function scopePlatform($query, string $platform)
    {
        return $query->where('platform', $platform);
    }

    /**
     * Get device display name.
     */
    public function getDisplayNameAttribute(): string
    {
        if ($this->device_name) {
            return $this->device_name;
        }

        if ($this->device_model) {
            return $this->device_model;
        }

        return ucfirst($this->platform) . ' Device';
    }

    /**
     * Check if device is iOS.
     */
    public function isIOS(): bool
    {
        return strtolower($this->platform) === 'ios';
    }

    /**
     * Check if device is Android.
     */
    public function isAndroid(): bool
    {
        return strtolower($this->platform) === 'android';
    }

    /**
     * Update last used timestamp.
     */
    public function updateLastUsed(): void
    {
        $this->update(['last_used_at' => now()]);
    }

    /**
     * Deactivate the device.
     */
    public function deactivate(): void
    {
        $this->update(['is_active' => false]);
    }
}