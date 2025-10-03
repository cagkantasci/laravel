<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Company;
use App\Models\Machine;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MachineTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate:fresh');
        $this->seed();
    }

    /** @test */
    public function authenticated_user_can_list_machines()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('admin');

        Machine::factory()->count(3)->create(['company_id' => $company->id]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/machines');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'data' => [
                        '*' => [
                            'id', 'uuid', 'name', 'type', 'model', 'serial_number'
                        ]
                    ]
                ]);
    }

    /** @test */
    public function admin_can_create_machine()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('admin');

        Sanctum::actingAs($user);

        $machineData = [
            'name' => 'Test Excavator',
            'type' => 'excavator',
            'model' => 'CAT 320D',
            'serial_number' => 'SN123456789',
            'manufacturer' => 'Caterpillar',
            'production_date' => '2020-01-01',
            'installation_date' => '2020-02-01',
            'specifications' => [
                'engine_power' => 150,
                'weight' => 22.5,
                'fuel_capacity' => 400
            ],
            'status' => 'active',
            'location' => 'Site A - Zone 1',
            'notes' => 'Brand new excavator'
        ];

        $response = $this->postJson('/api/machines', $machineData);

        $response->assertStatus(201)
                ->assertJsonStructure([
                    'success',
                    'message',
                    'data' => [
                        'id', 'uuid', 'name', 'type', 'model'
                    ]
                ]);

        $this->assertDatabaseHas('machines', [
            'name' => 'Test Excavator',
            'serial_number' => 'SN123456789',
            'company_id' => $company->id
        ]);
    }

    /** @test */
    public function machine_requires_valid_data()
    {
        $user = User::factory()->create();
        $user->assignRole('admin');
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/machines', [
            'name' => '',
            'type' => 'invalid_type',
            'serial_number' => ''
        ]);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['name', 'type', 'serial_number']);
    }

    /** @test */
    public function serial_number_must_be_unique()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('admin');

        Machine::factory()->create([
            'serial_number' => 'UNIQUE123',
            'company_id' => $company->id
        ]);

        Sanctum::actingAs($user);

        $response = $this->postJson('/api/machines', [
            'name' => 'Another Machine',
            'type' => 'excavator',
            'model' => 'Model X',
            'serial_number' => 'UNIQUE123'
        ]);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['serial_number']);
    }

    /** @test */
    public function user_can_view_machine_details()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        $machine = Machine::factory()->create(['company_id' => $company->id]);

        Sanctum::actingAs($user);

        $response = $this->getJson("/api/machines/{$machine->id}");

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'data' => [
                        'id', 'uuid', 'name', 'type', 'model', 'specifications'
                    ]
                ]);
    }

    /** @test */
    public function admin_can_update_machine()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('admin');

        $machine = Machine::factory()->create(['company_id' => $company->id]);

        Sanctum::actingAs($user);

        $updateData = [
            'name' => 'Updated Machine Name',
            'status' => 'maintenance',
            'location' => 'New Location'
        ];

        $response = $this->putJson("/api/machines/{$machine->id}", $updateData);

        $response->assertStatus(200);

        $this->assertDatabaseHas('machines', [
            'id' => $machine->id,
            'name' => 'Updated Machine Name',
            'status' => 'maintenance'
        ]);
    }

    /** @test */
    public function admin_can_delete_machine()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('admin');

        $machine = Machine::factory()->create(['company_id' => $company->id]);

        Sanctum::actingAs($user);

        $response = $this->deleteJson("/api/machines/{$machine->id}");

        $response->assertStatus(200);

        $this->assertSoftDeleted('machines', ['id' => $machine->id]);
    }

    /** @test */
    public function operator_cannot_create_machine()
    {
        $user = User::factory()->create();
        $user->assignRole('operator');

        Sanctum::actingAs($user);

        $response = $this->postJson('/api/machines', [
            'name' => 'Test Machine',
            'type' => 'excavator',
            'model' => 'Model X',
            'serial_number' => 'SN123'
        ]);

        $response->assertStatus(403);
    }

    /** @test */
    public function user_can_generate_qr_code_for_machine()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        $machine = Machine::factory()->create(['company_id' => $company->id]);

        Sanctum::actingAs($user);

        $response = $this->postJson("/api/machines/{$machine->id}/qr-code");

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'data' => [
                        'qr_code', 'qr_url'
                    ]
                ]);

        $machine->refresh();
        $this->assertNotNull($machine->qr_code);
    }

    /** @test */
    public function installation_date_must_be_after_production_date()
    {
        $user = User::factory()->create();
        $user->assignRole('admin');
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/machines', [
            'name' => 'Test Machine',
            'type' => 'excavator',
            'model' => 'Model X',
            'serial_number' => 'SN123',
            'production_date' => '2020-06-01',
            'installation_date' => '2020-01-01' // Before production date
        ]);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['installation_date']);
    }

    /** @test */
    public function machine_specifications_validation()
    {
        $user = User::factory()->create();
        $user->assignRole('admin');
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/machines', [
            'name' => 'Test Machine',
            'type' => 'excavator',
            'model' => 'Model X',
            'serial_number' => 'SN123',
            'specifications' => [
                'engine_power' => -10, // Invalid negative value
                'weight' => 0, // Invalid zero value
                'fuel_capacity' => 0.5 // Invalid low value
            ]
        ]);

        $response->assertStatus(422)
                ->assertJsonValidationErrors([
                    'specifications.engine_power',
                    'specifications.weight',
                    'specifications.fuel_capacity'
                ]);
    }

    /** @test */
    public function user_can_filter_machines_by_type()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        Machine::factory()->create(['company_id' => $company->id, 'type' => 'excavator']);
        Machine::factory()->create(['company_id' => $company->id, 'type' => 'bulldozer']);
        Machine::factory()->create(['company_id' => $company->id, 'type' => 'excavator']);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/machines?type=excavator');

        $response->assertStatus(200);

        $machines = $response->json('data');
        $this->assertCount(2, $machines);

        foreach ($machines as $machine) {
            $this->assertEquals('excavator', $machine['type']);
        }
    }

    /** @test */
    public function user_can_search_machines_by_name()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        Machine::factory()->create(['company_id' => $company->id, 'name' => 'Big Excavator']);
        Machine::factory()->create(['company_id' => $company->id, 'name' => 'Small Bulldozer']);
        Machine::factory()->create(['company_id' => $company->id, 'name' => 'Mega Excavator']);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/machines?search=excavator');

        $response->assertStatus(200);

        $machines = $response->json('data');
        $this->assertCount(2, $machines);
    }
}