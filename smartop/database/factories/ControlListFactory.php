<?php

namespace Database\Factories;

use App\Models\Company;
use App\Models\Machine;
use App\Models\User;
use App\Models\ControlTemplate;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\ControlList>
 */
class ControlListFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $controlItems = [
            [
                'item' => 'Engine oil level check',
                'type' => 'check',
                'required' => true,
                'completed' => fake()->boolean(80),
                'value' => fake()->randomElement(['OK', 'Low', 'High']),
                'notes' => fake()->optional()->sentence()
            ],
            [
                'item' => 'Hydraulic fluid level',
                'type' => 'check',
                'required' => true,
                'completed' => fake()->boolean(80),
                'value' => fake()->randomElement(['OK', 'Low', 'Needs Refill']),
                'notes' => fake()->optional()->sentence()
            ],
            [
                'item' => 'Tire pressure inspection',
                'type' => 'measurement',
                'required' => true,
                'completed' => fake()->boolean(75),
                'value' => fake()->optional()->numberBetween(25, 35) . ' PSI',
                'notes' => fake()->optional()->sentence()
            ],
            [
                'item' => 'Safety equipment check',
                'type' => 'check',
                'required' => true,
                'completed' => fake()->boolean(90),
                'value' => fake()->randomElement(['Present', 'Missing', 'Damaged']),
                'notes' => fake()->optional()->sentence()
            ],
            [
                'item' => 'General visual inspection',
                'type' => 'observation',
                'required' => false,
                'completed' => fake()->boolean(70),
                'value' => fake()->optional()->sentence(),
                'notes' => fake()->optional()->sentence()
            ]
        ];

        return [
            'company_id' => Company::factory(),
            'machine_id' => Machine::factory(),
            'control_template_id' => ControlTemplate::factory(),
            'user_id' => User::factory(),
            'title' => fake()->randomElement([
                'Daily Safety Inspection',
                'Weekly Maintenance Check',
                'Pre-Operation Inspection',
                'Post-Operation Review',
                'Monthly System Check'
            ]),
            'description' => fake()->optional()->paragraph(),
            'control_items' => $controlItems,
            'status' => fake()->randomElement(['pending', 'approved', 'rejected', 'expired']),
            'priority' => fake()->randomElement(['low', 'medium', 'high', 'critical']),
            'scheduled_date' => fake()->dateTimeBetween('-1 week', '+2 weeks'),
            'completed_date' => fake()->optional(60)->dateTimeBetween('-1 week', 'now'),
            'approved_by' => fake()->optional(40) ? User::factory() : null,
            'approved_at' => fake()->optional(30)->dateTimeBetween('-1 week', 'now'),
            'rejection_reason' => fake()->optional(10)->sentence(),
            'notes' => fake()->optional()->paragraph(),
        ];
    }

    /**
     * Indicate that the control list is pending.
     */
    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
            'completed_date' => null,
            'approved_by' => null,
            'approved_at' => null,
            'rejection_reason' => null,
        ]);
    }

    /**
     * Indicate that the control list is approved.
     */
    public function approved(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'approved',
            'completed_date' => fake()->dateTimeBetween('-1 week', 'now'),
            'approved_by' => User::factory(),
            'approved_at' => fake()->dateTimeBetween('-1 week', 'now'),
            'rejection_reason' => null,
        ]);
    }

    /**
     * Indicate that the control list is rejected.
     */
    public function rejected(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'rejected',
            'completed_date' => fake()->dateTimeBetween('-1 week', 'now'),
            'approved_by' => User::factory(),
            'approved_at' => fake()->dateTimeBetween('-1 week', 'now'),
            'rejection_reason' => fake()->sentence(),
        ]);
    }

    /**
     * Indicate that the control list is high priority.
     */
    public function highPriority(): static
    {
        return $this->state(fn (array $attributes) => [
            'priority' => 'high',
        ]);
    }

    /**
     * Indicate that the control list is critical priority.
     */
    public function critical(): static
    {
        return $this->state(fn (array $attributes) => [
            'priority' => 'critical',
        ]);
    }

    /**
     * Indicate that the control list is overdue.
     */
    public function overdue(): static
    {
        return $this->state(fn (array $attributes) => [
            'scheduled_date' => fake()->dateTimeBetween('-1 month', '-1 day'),
            'status' => 'pending',
            'completed_date' => null,
        ]);
    }

    /**
     * Configure control list with all items completed.
     */
    public function allCompleted(): static
    {
        return $this->state(function (array $attributes) {
            $controlItems = $attributes['control_items'] ?? [];

            foreach ($controlItems as &$item) {
                $item['completed'] = true;
                $item['value'] = $item['value'] ?? 'OK';
            }

            return [
                'control_items' => $controlItems,
                'completed_date' => fake()->dateTimeBetween('-1 week', 'now'),
            ];
        });
    }

    /**
     * Configure control list with some items incomplete.
     */
    public function partiallyCompleted(): static
    {
        return $this->state(function (array $attributes) {
            $controlItems = $attributes['control_items'] ?? [];

            foreach ($controlItems as $index => &$item) {
                $item['completed'] = $index < (count($controlItems) / 2);
                if ($item['completed']) {
                    $item['value'] = $item['value'] ?? 'OK';
                }
            }

            return [
                'control_items' => $controlItems,
                'completed_date' => null,
            ];
        });
    }
}