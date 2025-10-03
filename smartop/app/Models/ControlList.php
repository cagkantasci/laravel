<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class ControlList extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'uuid',
        'company_id',
        'machine_id',
        'control_template_id',
        'user_id',
        'title',
        'description',
        'control_items',
        'status',
        'priority',
        'scheduled_date',
        'completed_date',
        'approved_by',
        'approved_at',
        'rejection_reason',
        'notes',
    ];

    protected $casts = [
        'control_items' => 'array',
        'scheduled_date' => 'datetime',
        'completed_date' => 'datetime',
        'approved_at' => 'datetime',
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

    public function machine()
    {
        return $this->belongsTo(Machine::class);
    }

    public function controlTemplate()
    {
        return $this->belongsTo(ControlTemplate::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    /**
     * Scopes
     */
    public function scopeByCompany($query, $companyId)
    {
        return $query->where('company_id', $companyId);
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }

    public function scopeByPriority($query, $priority)
    {
        return $query->where('priority', $priority);
    }

    public function scopeScheduledForToday($query)
    {
        return $query->whereDate('scheduled_date', now()->toDateString());
    }

    public function scopeOverdue($query)
    {
        return $query->where('scheduled_date', '<', now())
                    ->whereNotIn('status', ['completed', 'approved']);
    }

    /**
     * Helper methods
     */
    public function isPending()
    {
        return $this->status === 'pending';
    }

    public function isCompleted()
    {
        return $this->status === 'completed';
    }

    public function isApproved()
    {
        return $this->status === 'approved';
    }

    public function isRejected()
    {
        return $this->status === 'rejected';
    }

    public function isOverdue()
    {
        return $this->scheduled_date < now() && !in_array($this->status, ['completed', 'approved']);
    }

    public function canBeApproved()
    {
        return in_array($this->status, ['pending', 'completed']);
    }

    public function approve(User $approver, $notes = null)
    {
        $this->update([
            'status' => 'approved',
            'approved_by' => $approver->id,
            'approved_at' => now(),
            'notes' => $notes ? $this->notes . "\n[Onay] " . $notes : $this->notes,
        ]);
    }

    public function reject(User $approver, $reason)
    {
        $this->update([
            'status' => 'rejected',
            'approved_by' => $approver->id,
            'approved_at' => now(),
            'rejection_reason' => $reason,
        ]);
    }

    public function getCompletionPercentageAttribute()
    {
        if (!$this->control_items || !is_array($this->control_items)) {
            return 0;
        }

        $totalItems = count($this->control_items);
        if ($totalItems === 0) {
            return 0;
        }

        $completedItems = collect($this->control_items)->filter(function ($item) {
            return isset($item['completed']) && $item['completed'] === true;
        })->count();

        return round(($completedItems / $totalItems) * 100, 2);
    }

    public function getPriorityColorAttribute()
    {
        return match ($this->priority) {
            'low' => '#28a745',      // Green
            'medium' => '#ffc107',   // Yellow
            'high' => '#fd7e14',     // Orange
            'critical' => '#dc3545', // Red
            default => '#6c757d'     // Gray
        };
    }

    public function getStatusColorAttribute()
    {
        return match ($this->status) {
            'draft' => '#6c757d',      // Gray
            'pending' => '#007bff',    // Blue
            'in_progress' => '#ffc107', // Yellow
            'completed' => '#28a745',  // Green
            'approved' => '#20c997',   // Teal
            'rejected' => '#dc3545',   // Red
            default => '#6c757d'       // Gray
        };
    }
}
