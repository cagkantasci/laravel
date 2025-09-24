<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class ControlTemplate extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'uuid',
        'company_id',
        'name',
        'description',
        'category',
        'machine_types',
        'template_items',
        'estimated_duration',
        'is_active',
        'created_by',
    ];

    protected $casts = [
        'machine_types' => 'array',
        'template_items' => 'array',
        'is_active' => 'boolean',
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

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
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
        return $query->where('is_active', true);
    }

    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function scopeByMachineType($query, $machineType)
    {
        return $query->whereJsonContains('machine_types', $machineType);
    }

    /**
     * Helper methods
     */
    public function isActive()
    {
        return $this->is_active;
    }

    public function getItemsCountAttribute()
    {
        return is_array($this->template_items) ? count($this->template_items) : 0;
    }

    public function createControlList($machineId, $userId, $scheduledDate = null)
    {
        return ControlList::create([
            'company_id' => $this->company_id,
            'machine_id' => $machineId,
            'control_template_id' => $this->id,
            'user_id' => $userId,
            'title' => $this->name,
            'description' => $this->description,
            'control_items' => $this->template_items,
            'status' => 'pending',
            'priority' => 'medium',
            'scheduled_date' => $scheduledDate ?? now(),
        ]);
    }

    public function duplicate($newName = null)
    {
        $template = $this->replicate();
        $template->name = $newName ?? $this->name . ' (Kopya)';
        $template->uuid = Str::uuid();
        $template->save();

        return $template;
    }
}
