<?php

namespace Database\Factories;

use App\Models\Company;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Machine>
 */
class MachineFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $types = ['excavator', 'bulldozer', 'crane', 'loader', 'grader', 'compactor', 'other'];
        $type = fake()->randomElement($types);

        $brands = [
            'excavator' => ['Caterpillar', 'Komatsu', 'Hitachi', 'Volvo', 'JCB'],
            'bulldozer' => ['Caterpillar', 'Komatsu', 'John Deere', 'Case'],
            'crane' => ['Liebherr', 'Tadano', 'Grove', 'Terex'],
            'loader' => ['Caterpillar', 'Volvo', 'JCB', 'Case'],
            'grader' => ['Caterpillar', 'John Deere', 'Volvo'],
            'compactor' => ['Caterpillar', 'Volvo', 'Dynapac'],
            'other' => ['Generic', 'Custom']
        ];

        $brand = fake()->randomElement($brands[$type] ?? ['Generic']);

        return [
            'company_id' => Company::factory(),
            'name' => fake()->words(2, true) . ' ' . ucfirst($type),
            'type' => $type,
            'model' => $brand . ' ' . fake()->numerify('###'),
            'serial_number' => fake()->unique()->regexify('[A-Z]{2}[0-9]{8}'),
            'manufacturer' => $brand,
            'production_date' => fake()->dateTimeBetween('-10 years', '-1 year'),
            'installation_date' => fake()->dateTimeBetween('-5 years', 'now'),
            'specifications' => [
                'engine_power' => fake()->numberBetween(50, 500), // HP
                'weight' => fake()->randomFloat(1, 5, 80), // tons
                'fuel_capacity' => fake()->numberBetween(100, 1000), // liters
                'max_speed' => fake()->numberBetween(5, 50), // km/h
                'operating_weight' => fake()->randomFloat(1, 10, 100) // tons
            ],
            'status' => fake()->randomElement(['active', 'inactive', 'maintenance', 'out_of_service']),
            'location' => fake()->optional()->streetAddress(),
            'qr_code' => fake()->optional()->regexify('MACHINE_[A-Z0-9]{8}'),
            'notes' => fake()->optional()->sentence(),
        ];
    }

    /**
     * Indicate that the machine is active.
     */
    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'active',
        ]);
    }

    /**
     * Indicate that the machine is in maintenance.
     */
    public function maintenance(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'maintenance',
        ]);
    }

    /**
     * Indicate that the machine is an excavator.
     */
    public function excavator(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'excavator',
            'name' => fake()->words(2, true) . ' Excavator',
            'manufacturer' => fake()->randomElement(['Caterpillar', 'Komatsu', 'Hitachi', 'Volvo']),
        ]);
    }

    /**
     * Indicate that the machine is a bulldozer.
     */
    public function bulldozer(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'bulldozer',
            'name' => fake()->words(2, true) . ' Bulldozer',
            'manufacturer' => fake()->randomElement(['Caterpillar', 'Komatsu', 'John Deere']),
        ]);
    }

    /**
     * Configure machine with QR code.
     */
    public function withQrCode(): static
    {
        return $this->state(fn (array $attributes) => [
            'qr_code' => 'MACHINE_' . strtoupper(fake()->bothify('########')),
        ]);
    }

    /**
     * Configure machine without QR code.
     */
    public function withoutQrCode(): static
    {
        return $this->state(fn (array $attributes) => [
            'qr_code' => null,
        ]);
    }
}