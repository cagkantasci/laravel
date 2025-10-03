<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;
use Carbon\Carbon;

class MachineWorkSession extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'uuid',
        'machine_id',
        'operator_id',
        'control_list_id',
        'company_id',
        'start_time',
        'end_time',
        'duration_minutes',
        'status',
        'location',
        'start_notes',
        'end_notes',
        'approved_by',
        'approved_at',
        'approval_notes',
    ];

    protected $casts = [
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'approved_at' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (!$model->uuid) {
                $model->uuid = Str::uuid();
            }
        });

        static::saving(function ($model) {
            // Auto-calculate duration when end_time is set
            if ($model->end_time && $model->start_time) {
                $model->duration_minutes = $model->start_time->diffInMinutes($model->end_time);
            }
        });
    }

    // Relationships
    public function machine()
    {
        return $this->belongsTo(Machine::class);
    }

    public function operator()
    {
        return $this->belongsTo(User::class, 'operator_id');
    }

    public function controlList()
    {
        return $this->belongsTo(ControlList::class);
    }

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    // Scopes
    public function scopeInProgress($query)
    {
        return $query->where('status', 'in_progress');
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeForCompany($query, $companyId)
    {
        return $query->where('company_id', $companyId);
    }

    public function scopeForOperator($query, $operatorId)
    {
        return $query->where('operator_id', $operatorId);
    }

    // Helper methods
    public function isInProgress()
    {
        return $this->status === 'in_progress';
    }

    public function endSession($endNotes = null)
    {
        $this->end_time = now();
        $this->end_notes = $endNotes;
        $this->status = 'completed';
        $this->save();

        return $this;
    }

    public function approve($approverId, $notes = null)
    {
        $this->approved_by = $approverId;
        $this->approved_at = now();
        $this->approval_notes = $notes;
        $this->status = 'approved';
        $this->save();

        return $this;
    }

    public function reject($approverId, $notes = null)
    {
        $this->approved_by = $approverId;
        $this->approved_at = now();
        $this->approval_notes = $notes;
        $this->status = 'rejected';
        $this->save();

        return $this;
    }

    public function getDurationFormatted()
    {
        if (!$this->duration_minutes) {
            return 'N/A';
        }

        $hours = floor($this->duration_minutes / 60);
        $minutes = $this->duration_minutes % 60;

        return sprintf('%d saat %d dakika', $hours, $minutes);
    }
}
