<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use App\Models\Machine;
use App\Services\MaintenanceService;
use App\Events\MachineMaintenanceScheduled;

class ProcessMachineMaintenanceJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $timeout = 300;
    public $tries = 2;

    protected Machine $machine;
    protected array $maintenanceData;

    /**
     * Create a new job instance.
     */
    public function __construct(Machine $machine, array $maintenanceData)
    {
        $this->machine = $machine;
        $this->maintenanceData = $maintenanceData;
        $this->onQueue('maintenance');
    }

    /**
     * Execute the job.
     */
    public function handle(MaintenanceService $maintenanceService): void
    {
        Log::info('Processing machine maintenance', [
            'machine_id' => $this->machine->id,
            'machine_name' => $this->machine->name,
            'maintenance_type' => $this->maintenanceData['type'] ?? 'routine'
        ]);

        try {
            // Create maintenance record
            $maintenance = $maintenanceService->scheduleMaintenance(
                $this->machine,
                $this->maintenanceData
            );

            // Update machine status if needed
            if ($this->maintenanceData['requires_downtime'] ?? false) {
                $this->machine->update(['status' => 'maintenance']);
            }

            // Notify relevant personnel
            $this->notifyMaintenanceTeam($maintenance);

            // Fire event for real-time updates
            event(new MachineMaintenanceScheduled($maintenance));

            Log::info('Machine maintenance processed successfully', [
                'machine_id' => $this->machine->id,
                'maintenance_id' => $maintenance->id
            ]);

        } catch (\Throwable $e) {
            Log::error('Machine maintenance processing failed', [
                'machine_id' => $this->machine->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            throw $e;
        }
    }

    /**
     * Notify maintenance team about scheduled maintenance.
     */
    protected function notifyMaintenanceTeam($maintenance): void
    {
        $notificationData = [
            'title' => 'Maintenance Scheduled',
            'message' => "Maintenance has been scheduled for {$this->machine->name}",
            'machine_id' => $this->machine->id,
            'maintenance_id' => $maintenance->id,
            'scheduled_date' => $maintenance->scheduled_date,
            'priority' => $maintenance->priority ?? 'normal'
        ];

        // Get maintenance team members
        $maintenanceTeam = $this->machine->company
            ->users()
            ->whereHas('roles', function ($query) {
                $query->whereIn('name', ['manager', 'maintenance_technician']);
            })
            ->get()
            ->toArray();

        SendNotificationJob::dispatch(
            $notificationData,
            'maintenance_scheduled',
            $maintenanceTeam
        );
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error('Machine maintenance job permanently failed', [
            'machine_id' => $this->machine->id,
            'error' => $exception->getMessage()
        ]);

        // Notify administrators about the failure
        $notificationData = [
            'title' => 'Maintenance Scheduling Failed',
            'message' => "Failed to schedule maintenance for {$this->machine->name}",
            'machine_id' => $this->machine->id,
            'error' => $exception->getMessage(),
            'priority' => 'high'
        ];

        $admins = $this->machine->company
            ->users()
            ->whereHas('roles', function ($query) {
                $query->where('name', 'admin');
            })
            ->get()
            ->toArray();

        SendNotificationJob::dispatch(
            $notificationData,
            'maintenance_failed',
            $admins
        );
    }

    /**
     * Get the tags that should be assigned to the job.
     */
    public function tags(): array
    {
        return [
            'maintenance',
            'machine:' . $this->machine->id,
            'company:' . $this->machine->company_id
        ];
    }
}