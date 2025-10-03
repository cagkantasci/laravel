<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Machine extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'uuid',
        'company_id',
        'name',
        'type',
        'model',
        'serial_number',
        'manufacturer',
        'production_date',
        'installation_date',
        'specifications',
        'status',
        'location',
        'qr_code',
        'notes',
    ];

    protected $casts = [
        'production_date' => 'date',
        'installation_date' => 'date',
        'specifications' => 'array',
    ];

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
        return $this->hasMany(ControlList::class);
    }

    /**
     * Scopes
     */
    public function scopeByCompany($query, $companyId)
    {
        return $query->where('company_id', $companyId);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeByType($query, $type)
    {
        return $query->where('type', $type);
    }

    /**
     * Helper methods
     */
    public function isActive()
    {
        return $this->status === 'active';
    }

    public function generateQrCode()
    {
        if (!$this->qr_code) {
            $this->qr_code = 'MACHINE_' . strtoupper(Str::random(8));
            $this->save();
        }
        return $this->qr_code;
    }

    public function getFullNameAttribute()
    {
        return $this->name . ($this->model ? ' (' . $this->model . ')' : '');
    }
}
