<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Company;
use App\Models\Machine;
use App\Models\ControlList;
use App\Models\ControlTemplate;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ControlListTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate:fresh');
        $this->seed();
    }

    /** @test */
    public function user_can_list_control_lists()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        $machine = Machine::factory()->create(['company_id' => $company->id]);
        ControlList::factory()->count(3)->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user->id
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/control-lists');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'data' => [
                        '*' => [
                            'id', 'uuid', 'status', 'machine', 'user'
                        ]
                    ]
                ]);
    }

    /** @test */
    public function operator_can_create_control_list()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        $machine = Machine::factory()->create(['company_id' => $company->id]);
        $template = ControlTemplate::factory()->create(['company_id' => $company->id]);

        Sanctum::actingAs($user);

        $controlListData = [
            'machine_id' => $machine->id,
            'control_template_id' => $template->id,
            'title' => 'Daily Machine Inspection',
            'description' => 'Regular daily inspection',
            'control_items' => [
                [
                    'item' => 'Engine oil level',
                    'type' => 'check',
                    'required' => true,
                    'completed' => true,
                    'value' => 'OK',
                    'notes' => 'Oil level normal'
                ],
                [
                    'item' => 'Hydraulic fluid',
                    'type' => 'check',
                    'required' => true,
                    'completed' => true,
                    'value' => 'Low',
                    'notes' => 'Needs refill'
                ]
            ],
            'priority' => 'medium',
            'scheduled_date' => now()->addDay()->format('Y-m-d H:i:s'),
            'notes' => 'Morning inspection completed'
        ];

        $response = $this->postJson('/api/control-lists', $controlListData);

        $response->assertStatus(201)
                ->assertJsonStructure([
                    'success',
                    'message',
                    'data' => [
                        'id', 'uuid', 'title', 'status'
                    ]
                ]);

        $this->assertDatabaseHas('control_lists', [
            'machine_id' => $machine->id,
            'user_id' => $user->id,
            'title' => 'Daily Machine Inspection'
        ]);
    }

    /** @test */
    public function control_list_requires_valid_data()
    {
        $user = User::factory()->create();
        $user->assignRole('operator');
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/control-lists', [
            'machine_id' => 9999, // Non-existent machine
            'title' => '',
            'control_items' => 'invalid'
        ]);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['machine_id', 'title', 'control_items']);
    }

    /** @test */
    public function user_can_view_control_list_details()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        $machine = Machine::factory()->create(['company_id' => $company->id]);
        $controlList = ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user->id
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson("/api/control-lists/{$controlList->id}");

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'data' => [
                        'id', 'uuid', 'title', 'control_items', 'machine', 'user'
                    ]
                ]);
    }

    /** @test */
    public function operator_can_update_own_control_list()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        $machine = Machine::factory()->create(['company_id' => $company->id]);
        $controlList = ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user->id,
            'status' => 'pending'
        ]);

        Sanctum::actingAs($user);

        $updateData = [
            'title' => 'Updated Control List',
            'notes' => 'Updated notes',
            'control_items' => [
                [
                    'item' => 'Updated check',
                    'type' => 'check',
                    'completed' => true,
                    'value' => 'OK'
                ]
            ]
        ];

        $response = $this->putJson("/api/control-lists/{$controlList->id}", $updateData);

        $response->assertStatus(200);

        $this->assertDatabaseHas('control_lists', [
            'id' => $controlList->id,
            'title' => 'Updated Control List'
        ]);
    }

    /** @test */
    public function operator_cannot_update_others_control_list()
    {
        $company = Company::factory()->create();
        $user1 = User::factory()->create(['company_id' => $company->id]);
        $user2 = User::factory()->create(['company_id' => $company->id]);
        $user1->assignRole('operator');
        $user2->assignRole('operator');

        $machine = Machine::factory()->create(['company_id' => $company->id]);
        $controlList = ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user2->id
        ]);

        Sanctum::actingAs($user1);

        $response = $this->putJson("/api/control-lists/{$controlList->id}", [
            'title' => 'Unauthorized Update'
        ]);

        $response->assertStatus(403);
    }

    /** @test */
    public function manager_can_approve_control_list()
    {
        $company = Company::factory()->create();
        $operator = User::factory()->create(['company_id' => $company->id]);
        $manager = User::factory()->create(['company_id' => $company->id]);
        $operator->assignRole('operator');
        $manager->assignRole('manager');

        $machine = Machine::factory()->create(['company_id' => $company->id]);
        $controlList = ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $operator->id,
            'status' => 'completed'
        ]);

        Sanctum::actingAs($manager);

        $response = $this->postJson("/api/control-lists/{$controlList->id}/approve", [
            'notes' => 'Approved - Good work'
        ]);

        $response->assertStatus(200)
                ->assertJson([
                    'success' => true,
                    'message' => 'Control list approved successfully'
                ]);

        $this->assertDatabaseHas('control_lists', [
            'id' => $controlList->id,
            'status' => 'approved',
            'approved_by' => $manager->id
        ]);
    }

    /** @test */
    public function manager_can_reject_control_list()
    {
        $company = Company::factory()->create();
        $operator = User::factory()->create(['company_id' => $company->id]);
        $manager = User::factory()->create(['company_id' => $company->id]);
        $operator->assignRole('operator');
        $manager->assignRole('manager');

        $machine = Machine::factory()->create(['company_id' => $company->id]);
        $controlList = ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $operator->id,
            'status' => 'completed'
        ]);

        Sanctum::actingAs($manager);

        $response = $this->postJson("/api/control-lists/{$controlList->id}/reject", [
            'reason' => 'Incomplete inspection - please redo'
        ]);

        $response->assertStatus(200)
                ->assertJson([
                    'success' => true,
                    'message' => 'Control list rejected'
                ]);

        $this->assertDatabaseHas('control_lists', [
            'id' => $controlList->id,
            'status' => 'rejected',
            'approved_by' => $manager->id
        ]);
    }

    /** @test */
    public function operator_cannot_approve_control_list()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        $machine = Machine::factory()->create(['company_id' => $company->id]);
        $controlList = ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user->id
        ]);

        Sanctum::actingAs($user);

        $response = $this->postJson("/api/control-lists/{$controlList->id}/approve");

        $response->assertStatus(403);
    }

    /** @test */
    public function control_list_calculates_completion_percentage()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $machine = Machine::factory()->create(['company_id' => $company->id]);

        $controlList = ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user->id,
            'control_items' => [
                ['item' => 'Check 1', 'completed' => true],
                ['item' => 'Check 2', 'completed' => true],
                ['item' => 'Check 3', 'completed' => false],
                ['item' => 'Check 4', 'completed' => false]
            ]
        ]);

        $this->assertEquals(50.0, $controlList->completion_percentage);
    }

    /** @test */
    public function user_can_filter_control_lists_by_status()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        $machine = Machine::factory()->create(['company_id' => $company->id]);

        ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user->id,
            'status' => 'pending'
        ]);

        ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user->id,
            'status' => 'approved'
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/control-lists?status=pending');

        $response->assertStatus(200);

        $controlLists = $response->json('data');
        $this->assertCount(1, $controlLists);
        $this->assertEquals('pending', $controlLists[0]['status']);
    }

    /** @test */
    public function control_list_shows_overdue_status()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $machine = Machine::factory()->create(['company_id' => $company->id]);

        $overdueControlList = ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user->id,
            'scheduled_date' => now()->subDays(2),
            'status' => 'pending'
        ]);

        $this->assertTrue($overdueControlList->isOverdue());
    }

    /** @test */
    public function user_can_search_control_lists()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);
        $user->assignRole('operator');

        $machine = Machine::factory()->create(['company_id' => $company->id]);

        ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user->id,
            'title' => 'Daily Safety Check'
        ]);

        ControlList::factory()->create([
            'company_id' => $company->id,
            'machine_id' => $machine->id,
            'user_id' => $user->id,
            'title' => 'Weekly Maintenance'
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/control-lists?search=safety');

        $response->assertStatus(200);

        $controlLists = $response->json('data');
        $this->assertCount(1, $controlLists);
        $this->assertStringContainsString('Safety', $controlLists[0]['title']);
    }
}