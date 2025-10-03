<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Company>
 */
class CompanyFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->company(),
            'trade_name' => fake()->companySuffix() . ' ' . fake()->word(),
            'tax_number' => fake()->numerify('##########'),
            'tax_office' => fake()->city() . ' V.D.',
            'email' => fake()->companyEmail(),
            'phone' => fake()->phoneNumber(),
            'address' => fake()->streetAddress(),
            'city' => fake()->city(),
            'district' => fake()->citySuffix(),
            'postal_code' => fake()->postcode(),
            'website' => fake()->optional()->url(),
            'status' => fake()->randomElement(['active', 'inactive']),
            'subscription_plan' => json_encode([
                'type' => fake()->randomElement(['basic', 'professional', 'enterprise']),
                'features' => ['50_machines', 'basic_reports']
            ]),
            'subscription_expires_at' => fake()->optional()->dateTimeBetween('+1 month', '+1 year'),
        ];
    }

    /**
     * Indicate that the company is active.
     */
    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'active',
        ]);
    }

    /**
     * Indicate that the company is on trial.
     */
    public function trial(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'trial',
            'subscription_expires_at' => fake()->dateTimeBetween('+1 week', '+1 month'),
        ]);
    }

    /**
     * Indicate that the company has premium subscription.
     */
    public function premium(): static
    {
        return $this->state(fn (array $attributes) => [
            'subscription_plan' => json_encode([
                'type' => 'professional',
                'features' => ['100_machines', 'advanced_reports', 'api_access']
            ]),
            'subscription_expires_at' => fake()->dateTimeBetween('+6 months', '+1 year'),
        ]);
    }
}