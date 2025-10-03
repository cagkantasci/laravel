<?php

namespace Tests\Unit;

use App\Models\Machine;
use App\Models\Company;
use App\Models\ControlList;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MachineModelTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate:fresh');
        $this->seed();
    }

    /** @test */
    public function machine_has_uuid_on_creation()
    {
        $machine = Machine::factory()->create();

        $this->assertNotNull($machine->uuid);
        $this->assertTrue(\Illuminate\Support\Str::isUuid($machine->uuid));
    }

    /** @test */
    public function machine_belongs_to_company()
    {
        $company = Company::factory()->create();
        $machine = Machine::factory()->create(['company_id' => $company->id]);

        $this->assertInstanceOf(Company::class, $machine->company);
        $this->assertEquals($company->id, $machine->company->id);
    }

    /** @test */
    public function machine_has_many_control_lists()
    {
        $machine = Machine::factory()->create();
        $controlLists = ControlList::factory()->count(3)->create(['machine_id' => $machine->id]);

        $this->assertCount(3, $machine->controlLists);
        $this->assertInstanceOf(ControlList::class, $machine->controlLists->first());
    }

    /** @test */
    public function machine_scope_by_company_works()
    {
        $company1 = Company::factory()->create();
        $company2 = Company::factory()->create();

        Machine::factory()->count(2)->create(['company_id' => $company1->id]);
        Machine::factory()->create(['company_id' => $company2->id]);

        $company1Machines = Machine::byCompany($company1->id)->get();

        $this->assertCount(2, $company1Machines);
        foreach ($company1Machines as $machine) {
            $this->assertEquals($company1->id, $machine->company_id);
        }
    }

    /** @test */
    public function machine_scope_active_works()
    {
        Machine::factory()->create(['status' => 'active']);
        Machine::factory()->create(['status' => 'inactive']);
        Machine::factory()->create(['status' => 'active']);

        $activeMachines = Machine::active()->get();

        $this->assertCount(2, $activeMachines);
        foreach ($activeMachines as $machine) {
            $this->assertEquals('active', $machine->status);
        }
    }

    /** @test */
    public function machine_scope_by_type_works()
    {
        Machine::factory()->create(['type' => 'excavator']);
        Machine::factory()->create(['type' => 'bulldozer']);
        Machine::factory()->create(['type' => 'excavator']);

        $excavators = Machine::byType('excavator')->get();

        $this->assertCount(2, $excavators);
        foreach ($excavators as $machine) {
            $this->assertEquals('excavator', $machine->type);
        }
    }

    /** @test */
    public function machine_is_active_method_works()
    {
        $activeMachine = Machine::factory()->create(['status' => 'active']);
        $inactiveMachine = Machine::factory()->create(['status' => 'inactive']);

        $this->assertTrue($activeMachine->isActive());
        $this->assertFalse($inactiveMachine->isActive());
    }

    /** @test */
    public function machine_can_generate_qr_code()
    {
        $machine = Machine::factory()->create(['qr_code' => null]);

        $this->assertNull($machine->qr_code);

        $qrCode = $machine->generateQrCode();

        $machine->refresh();

        $this->assertNotNull($machine->qr_code);
        $this->assertEquals($machine->qr_code, $qrCode);
        $this->assertStringStartsWith('MACHINE_', $qrCode);
        $this->assertEquals(16, strlen($qrCode)); // MACHINE_ + 8 characters
    }

    /** @test */
    public function machine_does_not_regenerate_existing_qr_code()
    {
        $existingQrCode = 'MACHINE_EXISTING';
        $machine = Machine::factory()->create(['qr_code' => $existingQrCode]);

        $qrCode = $machine->generateQrCode();

        $this->assertEquals($existingQrCode, $qrCode);
        $this->assertEquals($existingQrCode, $machine->qr_code);
    }

    /** @test */
    public function machine_full_name_attribute_works()
    {
        $machine = Machine::factory()->create([
            'name' => 'Big Excavator',
            'model' => 'CAT 320D'
        ]);

        $this->assertEquals('Big Excavator (CAT 320D)', $machine->full_name);
    }

    /** @test */
    public function machine_full_name_without_model_works()
    {
        $machine = Machine::factory()->create([
            'name' => 'Big Excavator',
            'model' => null
        ]);

        $this->assertEquals('Big Excavator', $machine->full_name);
    }

    /** @test */
    public function machine_production_date_is_cast_to_date()
    {
        $machine = Machine::factory()->create(['production_date' => '2020-01-01']);

        $this->assertInstanceOf(\Illuminate\Support\Carbon::class, $machine->production_date);
        $this->assertEquals('2020-01-01', $machine->production_date->format('Y-m-d'));
    }

    /** @test */
    public function machine_installation_date_is_cast_to_date()
    {
        $machine = Machine::factory()->create(['installation_date' => '2020-02-01']);

        $this->assertInstanceOf(\Illuminate\Support\Carbon::class, $machine->installation_date);
        $this->assertEquals('2020-02-01', $machine->installation_date->format('Y-m-d'));
    }

    /** @test */
    public function machine_specifications_are_cast_to_array()
    {
        $specifications = [
            'engine_power' => 150,
            'weight' => 22.5,
            'fuel_capacity' => 400
        ];

        $machine = Machine::factory()->create(['specifications' => $specifications]);

        $machine->refresh();

        $this->assertIsArray($machine->specifications);
        $this->assertEquals($specifications, $machine->specifications);
    }

    /** @test */
    public function machine_soft_deletes_work()
    {
        $machine = Machine::factory()->create();
        $machineId = $machine->id;

        $machine->delete();

        $this->assertSoftDeleted('machines', ['id' => $machineId]);

        // Machine should not be found in normal queries
        $this->assertNull(Machine::find($machineId));

        // But should be found with trashed
        $this->assertNotNull(Machine::withTrashed()->find($machineId));
    }

    /** @test */
    public function machine_has_correct_fillable_attributes()
    {
        $fillable = [
            'uuid', 'company_id', 'name', 'type', 'model', 'serial_number',
            'manufacturer', 'production_date', 'installation_date',
            'specifications', 'status', 'location', 'qr_code', 'notes'
        ];

        $machine = new Machine();

        $this->assertEquals($fillable, $machine->getFillable());
    }

    /** @test */
    public function machine_serial_number_is_unique()
    {
        $this->expectException(\Illuminate\Database\QueryException::class);

        Machine::factory()->create(['serial_number' => 'UNIQUE123']);
        Machine::factory()->create(['serial_number' => 'UNIQUE123']);
    }

    /** @test */
    public function machine_can_be_filtered_by_multiple_types()
    {
        Machine::factory()->create(['type' => 'excavator']);
        Machine::factory()->create(['type' => 'bulldozer']);
        Machine::factory()->create(['type' => 'crane']);
        Machine::factory()->create(['type' => 'excavator']);

        $machines = Machine::whereIn('type', ['excavator', 'crane'])->get();

        $this->assertCount(3, $machines);

        $types = $machines->pluck('type')->unique()->values()->toArray();
        $this->assertContains('excavator', $types);
        $this->assertContains('crane', $types);
        $this->assertNotContains('bulldozer', $types);
    }

    /** @test */
    public function machine_status_enum_validation()
    {
        $validStatuses = ['active', 'inactive', 'maintenance', 'out_of_service'];

        foreach ($validStatuses as $status) {
            $machine = Machine::factory()->create(['status' => $status]);
            $this->assertEquals($status, $machine->status);
        }
    }

    /** @test */
    public function machine_type_enum_validation()
    {
        $validTypes = ['excavator', 'bulldozer', 'crane', 'loader', 'grader', 'compactor', 'other'];

        foreach ($validTypes as $type) {
            $machine = Machine::factory()->create(['type' => $type]);
            $this->assertEquals($type, $machine->type);
        }
    }
}