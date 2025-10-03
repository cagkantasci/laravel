<?php

namespace Tests\Unit;

use App\Models\User;
use App\Models\Company;
use App\Models\ControlList;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserModelTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate:fresh');
        $this->seed();
    }

    /** @test */
    public function user_has_uuid_on_creation()
    {
        $user = User::factory()->create();

        $this->assertNotNull($user->uuid);
        $this->assertTrue(\Illuminate\Support\Str::isUuid($user->uuid));
    }

    /** @test */
    public function user_belongs_to_company()
    {
        $company = Company::factory()->create();
        $user = User::factory()->create(['company_id' => $company->id]);

        $this->assertInstanceOf(Company::class, $user->company);
        $this->assertEquals($company->id, $user->company->id);
    }

    /** @test */
    public function user_has_many_control_lists()
    {
        $user = User::factory()->create();
        $controlLists = ControlList::factory()->count(3)->create(['user_id' => $user->id]);

        $this->assertCount(3, $user->controlLists);
        $this->assertInstanceOf(ControlList::class, $user->controlLists->first());
    }

    /** @test */
    public function user_can_check_if_admin()
    {
        $user = User::factory()->create();
        $user->assignRole('admin');

        $this->assertTrue($user->isAdmin());
        $this->assertFalse($user->isManager());
        $this->assertFalse($user->isOperator());
    }

    /** @test */
    public function user_can_check_if_manager()
    {
        $user = User::factory()->create();
        $user->assignRole('manager');

        $this->assertFalse($user->isAdmin());
        $this->assertTrue($user->isManager());
        $this->assertFalse($user->isOperator());
    }

    /** @test */
    public function user_can_check_if_operator()
    {
        $user = User::factory()->create();
        $user->assignRole('operator');

        $this->assertFalse($user->isAdmin());
        $this->assertFalse($user->isManager());
        $this->assertTrue($user->isOperator());
    }

    /** @test */
    public function user_scope_active_works()
    {
        User::factory()->create(['status' => 'active']);
        User::factory()->create(['status' => 'inactive']);
        User::factory()->create(['status' => 'active']);

        $activeUsers = User::active()->get();

        $this->assertCount(2, $activeUsers);
        foreach ($activeUsers as $user) {
            $this->assertEquals('active', $user->status);
        }
    }

    /** @test */
    public function user_scope_by_company_works()
    {
        $company1 = Company::factory()->create();
        $company2 = Company::factory()->create();

        User::factory()->count(2)->create(['company_id' => $company1->id]);
        User::factory()->create(['company_id' => $company2->id]);

        $company1Users = User::byCompany($company1->id)->get();

        $this->assertCount(2, $company1Users);
        foreach ($company1Users as $user) {
            $this->assertEquals($company1->id, $user->company_id);
        }
    }

    /** @test */
    public function user_full_name_attribute_works()
    {
        $user = User::factory()->create(['name' => 'John Doe']);

        $this->assertEquals('John Doe', $user->full_name);
    }

    /** @test */
    public function user_can_update_last_login()
    {
        $user = User::factory()->create(['last_login_at' => null]);

        $this->assertNull($user->last_login_at);

        $user->updateLastLogin();

        $user->refresh();
        $this->assertNotNull($user->last_login_at);
        $this->assertTrue($user->last_login_at->isToday());
    }

    /** @test */
    public function user_password_is_hashed()
    {
        $user = User::factory()->create(['password' => 'password123']);

        $this->assertNotEquals('password123', $user->password);
        $this->assertTrue(\Illuminate\Support\Facades\Hash::check('password123', $user->password));
    }

    /** @test */
    public function user_preferences_are_cast_to_array()
    {
        $preferences = ['theme' => 'dark', 'language' => 'tr'];
        $user = User::factory()->create(['preferences' => $preferences]);

        $user->refresh();

        $this->assertIsArray($user->preferences);
        $this->assertEquals($preferences, $user->preferences);
    }

    /** @test */
    public function user_birth_date_is_cast_to_date()
    {
        $user = User::factory()->create(['birth_date' => '1990-01-01']);

        $this->assertInstanceOf(\Illuminate\Support\Carbon::class, $user->birth_date);
        $this->assertEquals('1990-01-01', $user->birth_date->format('Y-m-d'));
    }

    /** @test */
    public function user_soft_deletes_work()
    {
        $user = User::factory()->create();
        $userId = $user->id;

        $user->delete();

        $this->assertSoftDeleted('users', ['id' => $userId]);

        // User should not be found in normal queries
        $this->assertNull(User::find($userId));

        // But should be found with trashed
        $this->assertNotNull(User::withTrashed()->find($userId));
    }

    /** @test */
    public function user_hidden_attributes_are_not_serialized()
    {
        $user = User::factory()->create();

        $userArray = $user->toArray();

        $this->assertArrayNotHasKey('password', $userArray);
        $this->assertArrayNotHasKey('remember_token', $userArray);
    }

    /** @test */
    public function user_email_verified_at_is_cast_to_datetime()
    {
        $user = User::factory()->create(['email_verified_at' => now()]);

        $this->assertInstanceOf(\Illuminate\Support\Carbon::class, $user->email_verified_at);
    }

    /** @test */
    public function user_can_have_multiple_roles()
    {
        $user = User::factory()->create();
        $user->assignRole(['operator', 'manager']);

        $this->assertTrue($user->hasRole('operator'));
        $this->assertTrue($user->hasRole('manager'));
        $this->assertFalse($user->hasRole('admin'));
    }

    /** @test */
    public function user_approved_control_lists_relationship_works()
    {
        $manager = User::factory()->create();
        $operator = User::factory()->create();

        $manager->assignRole('manager');
        $operator->assignRole('operator');

        $controlList = ControlList::factory()->create([
            'user_id' => $operator->id,
            'approved_by' => $manager->id
        ]);

        $this->assertCount(1, $manager->approvedControlLists);
        $this->assertEquals($controlList->id, $manager->approvedControlLists->first()->id);
    }
}