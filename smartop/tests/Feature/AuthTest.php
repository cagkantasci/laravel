<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Company;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate:fresh');
        $this->seed();
    }

    /** @test */
    public function user_can_register_with_valid_data()
    {
        $company = Company::factory()->create();

        $userData = [
            'name' => 'Test User',
            'email' => 'test@smartop.com',
            'password' => 'SecurePassword123!',
            'password_confirmation' => 'SecurePassword123!',
            'phone' => '+905551234567',
            'identity_number' => '12345678901',
            'birth_date' => '1990-01-01',
            'gender' => 'male',
            'company_id' => $company->id
        ];

        $response = $this->postJson('/api/register', $userData);

        $response->assertStatus(201)
                ->assertJsonStructure([
                    'success',
                    'message',
                    'data' => [
                        'user' => [
                            'id', 'name', 'email', 'uuid'
                        ],
                        'token',
                        'token_type',
                        'expires_at'
                    ]
                ]);

        $this->assertDatabaseHas('users', [
            'email' => 'test@smartop.com',
            'name' => 'Test User'
        ]);
    }

    /** @test */
    public function user_cannot_register_with_invalid_email()
    {
        $userData = [
            'name' => 'Test User',
            'email' => 'invalid-email',
            'password' => 'SecurePassword123!',
            'password_confirmation' => 'SecurePassword123!',
        ];

        $response = $this->postJson('/api/register', $userData);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['email']);
    }

    /** @test */
    public function user_cannot_register_with_weak_password()
    {
        $userData = [
            'name' => 'Test User',
            'email' => 'test@smartop.com',
            'password' => '123',
            'password_confirmation' => '123',
        ];

        $response = $this->postJson('/api/register', $userData);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['password']);
    }

    /** @test */
    public function user_can_login_with_valid_credentials()
    {
        $user = User::factory()->create([
            'email' => 'test@smartop.com',
            'password' => Hash::make('password123'),
            'status' => 'active'
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'test@smartop.com',
            'password' => 'password123'
        ]);

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'message',
                    'data' => [
                        'user',
                        'token',
                        'token_type',
                        'expires_at'
                    ]
                ]);
    }

    /** @test */
    public function user_cannot_login_with_invalid_credentials()
    {
        $user = User::factory()->create([
            'email' => 'test@smartop.com',
            'password' => Hash::make('password123')
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'test@smartop.com',
            'password' => 'wrongpassword'
        ]);

        $response->assertStatus(401)
                ->assertJson([
                    'success' => false,
                    'message' => 'Invalid login credentials'
                ]);
    }

    /** @test */
    public function inactive_user_cannot_login()
    {
        $user = User::factory()->create([
            'email' => 'test@smartop.com',
            'password' => Hash::make('password123'),
            'status' => 'inactive'
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'test@smartop.com',
            'password' => 'password123'
        ]);

        $response->assertStatus(403)
                ->assertJson([
                    'success' => false,
                    'message' => 'Account is not active'
                ]);
    }

    /** @test */
    public function authenticated_user_can_get_profile()
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/profile');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'data' => [
                        'user' => [
                            'id', 'name', 'email'
                        ],
                        'permissions'
                    ]
                ]);
    }

    /** @test */
    public function unauthenticated_user_cannot_access_profile()
    {
        $response = $this->getJson('/api/profile');

        $response->assertStatus(401);
    }

    /** @test */
    public function user_can_update_profile()
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $updateData = [
            'name' => 'Updated Name',
            'phone' => '+905559876543'
        ];

        $response = $this->putJson('/api/profile', $updateData);

        $response->assertStatus(200)
                ->assertJson([
                    'success' => true,
                    'message' => 'Profile updated successfully'
                ]);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Updated Name',
            'phone' => '+905559876543'
        ]);
    }

    /** @test */
    public function user_can_change_password()
    {
        $user = User::factory()->create([
            'password' => Hash::make('oldpassword123')
        ]);
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/change-password', [
            'current_password' => 'oldpassword123',
            'new_password' => 'NewPassword123!',
            'new_password_confirmation' => 'NewPassword123!'
        ]);

        $response->assertStatus(200);

        // Verify password was changed
        $user->refresh();
        $this->assertTrue(Hash::check('NewPassword123!', $user->password));
    }

    /** @test */
    public function user_cannot_change_password_with_wrong_current_password()
    {
        $user = User::factory()->create([
            'password' => Hash::make('oldpassword123')
        ]);
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/change-password', [
            'current_password' => 'wrongpassword',
            'new_password' => 'NewPassword123!',
            'new_password_confirmation' => 'NewPassword123!'
        ]);

        $response->assertStatus(400)
                ->assertJson([
                    'success' => false,
                    'message' => 'Current password is incorrect'
                ]);
    }

    /** @test */
    public function user_can_logout()
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/logout');

        $response->assertStatus(200)
                ->assertJson([
                    'success' => true,
                    'message' => 'Logout successful'
                ]);
    }

    /** @test */
    public function user_can_logout_from_all_devices()
    {
        $user = User::factory()->create();

        // Create multiple tokens
        $token1 = $user->createToken('token1')->plainTextToken;
        $token2 = $user->createToken('token2')->plainTextToken;

        Sanctum::actingAs($user);

        $response = $this->postJson('/api/logout-all');

        $response->assertStatus(200)
                ->assertJson([
                    'success' => true,
                    'message' => 'Logged out from all devices'
                ]);

        // Verify all tokens are deleted
        $this->assertEquals(0, $user->tokens()->count());
    }

    /** @test */
    public function login_rate_limiting_works()
    {
        $user = User::factory()->create([
            'email' => 'test@smartop.com',
            'password' => Hash::make('password123')
        ]);

        // Make 6 failed login attempts
        for ($i = 0; $i < 6; $i++) {
            $this->postJson('/api/login', [
                'email' => 'test@smartop.com',
                'password' => 'wrongpassword'
            ]);
        }

        // The 6th attempt should be rate limited
        $response = $this->postJson('/api/login', [
            'email' => 'test@smartop.com',
            'password' => 'wrongpassword'
        ]);

        $response->assertStatus(429)
                ->assertJson([
                    'success' => false,
                    'message' => 'Too many login attempts. Please try again later.'
                ]);
    }
}