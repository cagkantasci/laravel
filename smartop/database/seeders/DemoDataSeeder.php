<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Company;
use App\Models\User;
use App\Models\Machine;
use App\Models\ControlTemplate;
use App\Models\ControlList;
use Illuminate\Support\Facades\Hash;

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        // Create additional companies
        $companies = [
            [
                'name' => 'Üretim Fabrikası A.Ş.',
                'trade_name' => 'Üretim Fabrikası',
                'tax_number' => '9876543210',
                'tax_office' => 'Kadıköy V.D.',
                'email' => 'info@uretimfabrikasi.com',
                'phone' => '+90 555 222 3333',
                'address' => 'Sanayi Mahallesi, Üretim Caddesi No:15',
                'city' => 'Istanbul',
                'district' => 'Kadıköy',
                'postal_code' => '34720',
                'status' => 'active',
                'subscription_plan' => json_encode([
                    'type' => 'professional',
                    'features' => ['100_machines', 'basic_reports']
                ]),
                'subscription_expires_at' => now()->addYear(),
            ],
            [
                'name' => 'Makine Sanayi Ltd.Şti.',
                'trade_name' => 'Makine Sanayi',
                'tax_number' => '5555555555',
                'tax_office' => 'Kartal V.D.',
                'email' => 'contact@makinesanayi.com',
                'phone' => '+90 555 444 5555',
                'address' => 'OSB Mahallesi, 3. Cadde No:42',
                'city' => 'Istanbul',
                'district' => 'Tuzla',
                'postal_code' => '34956',
                'status' => 'active',
                'subscription_plan' => json_encode([
                    'type' => 'basic',
                    'features' => ['50_machines']
                ]),
                'subscription_expires_at' => now()->addMonths(6),
            ],
        ];

        $createdCompanies = collect();
        foreach ($companies as $companyData) {
            $createdCompanies->push(Company::factory()->create($companyData));
        }

        // Get all companies including SmartOp Demo Company
        $allCompanies = Company::all();

        // Create users for each company
        foreach ($allCompanies as $company) {
            // Create managers
            for ($i = 1; $i <= 2; $i++) {
                $manager = User::factory()->create([
                    'name' => fake()->name(),
                    'email' => 'manager' . $i . '.' . $company->id . '@' . strtolower(str_replace(' ', '', $company->name)) . '.com',
                    'phone' => '+90 ' . fake()->numerify('5## ### ####'),
                    'company_id' => $company->id,
                    'status' => 'active',
                ]);
                $manager->assignRole('manager');
            }

            // Create operators
            for ($i = 1; $i <= 5; $i++) {
                $operator = User::factory()->create([
                    'name' => fake()->name(),
                    'email' => 'operator' . $i . '.' . $company->id . '@' . strtolower(str_replace(' ', '', $company->name)) . '.com',
                    'phone' => '+90 ' . fake()->numerify('5## ### ####'),
                    'company_id' => $company->id,
                    'status' => 'active',
                ]);
                $operator->assignRole('operator');
            }
        }

        // Create machines for each company
        $machineTypes = ['excavator', 'bulldozer', 'crane', 'loader', 'grader', 'compactor'];
        $manufacturers = ['Caterpillar', 'Komatsu', 'Volvo', 'Hitachi', 'JCB', 'Liebherr'];

        foreach ($allCompanies as $company) {
            $machineCount = rand(5, 15);

            for ($i = 1; $i <= $machineCount; $i++) {
                $type = $machineTypes[array_rand($machineTypes)];
                $manufacturer = $manufacturers[array_rand($manufacturers)];

                Machine::factory()->create([
                    'company_id' => $company->id,
                    'name' => ucfirst($type) . ' - ' . chr(64 + $i),
                    'type' => $type,
                    'manufacturer' => $manufacturer,
                    'model' => $manufacturer . ' ' . fake()->bothify('##??-###'),
                    'serial_number' => fake()->unique()->bothify('SN-####-????-####'),
                    'production_date' => fake()->dateTimeBetween('-' . rand(5, 15) . ' years', '-1 year'),
                    'installation_date' => fake()->dateTimeBetween('-5 years', 'now'),
                    'status' => ['active', 'active', 'active', 'maintenance'][array_rand(['active', 'active', 'active', 'maintenance'])],
                    'location' => ['Workshop A', 'Workshop B', 'Production Floor', 'Assembly Line'][array_rand(['Workshop A', 'Workshop B', 'Production Floor', 'Assembly Line'])],
                    'specifications' => json_encode([
                        'engine_power' => rand(50, 500) . ' HP',
                        'weight' => rand(5, 80) . ' tons',
                        'fuel_capacity' => rand(100, 1000) . ' liters',
                        'max_speed' => rand(5, 50) . ' km/h',
                    ]),
                    'qr_code' => 'MACHINE_' . strtoupper(fake()->bothify('########')),
                ]);
            }
        }

        // Assign machines to operators
        foreach ($allCompanies as $company) {
            $companyMachines = Machine::where('company_id', $company->id)->get();
            $companyOperators = User::role('operator')->where('company_id', $company->id)->get();

            foreach ($companyOperators as $operator) {
                // Her operator'a rastgele 2-5 makine ata
                $machinesToAssign = $companyMachines->random(min(rand(2, 5), $companyMachines->count()));
                foreach ($machinesToAssign as $machine) {
                    $operator->assignedMachines()->syncWithoutDetaching($machine->id);
                }
            }
        }

        // Get admin user for created_by
        $adminUser = User::role('admin')->first();

        // Create control templates
        $templates = [
            [
                'name' => 'Daily Machine Inspection',
                'description' => 'Standard daily inspection checklist for all machines',
                'machine_type' => 'all',
                'is_default' => true,
                'is_active' => true,
                'company_id' => null,
                'created_by' => $adminUser->id,
                'control_items' => json_encode([
                    ['title' => 'Check oil levels', 'description' => 'Verify all oil levels are adequate', 'type' => 'checkbox', 'required' => true, 'order' => 1],
                    ['title' => 'Inspect safety guards', 'description' => 'Ensure all safety guards are in place', 'type' => 'checkbox', 'required' => true, 'order' => 2],
                    ['title' => 'Test emergency stop', 'description' => 'Verify emergency stop button functionality', 'type' => 'checkbox', 'required' => true, 'order' => 3],
                    ['title' => 'Check for unusual noises', 'description' => 'Listen for any abnormal sounds', 'type' => 'checkbox', 'required' => false, 'order' => 4],
                    ['title' => 'Temperature reading', 'description' => 'Record machine temperature', 'type' => 'number', 'required' => false, 'order' => 5],
                    ['title' => 'Additional notes', 'description' => 'Any additional observations', 'type' => 'text', 'required' => false, 'order' => 6],
                ]),
            ],
            [
                'name' => 'Weekly Maintenance Check',
                'description' => 'Comprehensive weekly maintenance checklist',
                'machine_type' => 'all',
                'is_default' => true,
                'is_active' => true,
                'company_id' => null,
                'created_by' => $adminUser->id,
                'control_items' => json_encode([
                    ['title' => 'Lubricate moving parts', 'description' => 'Apply lubricant to all moving components', 'type' => 'checkbox', 'required' => true, 'order' => 1],
                    ['title' => 'Clean filters', 'description' => 'Remove and clean all filters', 'type' => 'checkbox', 'required' => true, 'order' => 2],
                    ['title' => 'Check belt tension', 'description' => 'Verify belt tension is correct', 'type' => 'checkbox', 'required' => true, 'order' => 3],
                    ['title' => 'Inspect electrical connections', 'description' => 'Check for loose or damaged connections', 'type' => 'checkbox', 'required' => true, 'order' => 4],
                    ['title' => 'Calibration check', 'description' => 'Verify machine calibration', 'type' => 'checkbox', 'required' => false, 'order' => 5],
                    ['title' => 'Maintenance photo', 'description' => 'Photo of completed maintenance', 'type' => 'photo', 'required' => false, 'order' => 6],
                ]),
            ],
            [
                'name' => 'Safety Inspection',
                'description' => 'Monthly safety compliance inspection',
                'machine_type' => 'all',
                'is_default' => true,
                'is_active' => true,
                'company_id' => null,
                'created_by' => $adminUser->id,
                'control_items' => json_encode([
                    ['title' => 'Fire extinguisher check', 'description' => 'Verify fire extinguisher is accessible and charged', 'type' => 'checkbox', 'required' => true, 'order' => 1],
                    ['title' => 'First aid kit inspection', 'description' => 'Check first aid kit is stocked', 'type' => 'checkbox', 'required' => true, 'order' => 2],
                    ['title' => 'Safety signage', 'description' => 'Verify all safety signs are visible', 'type' => 'checkbox', 'required' => true, 'order' => 3],
                    ['title' => 'PPE availability', 'description' => 'Check personal protective equipment is available', 'type' => 'checkbox', 'required' => true, 'order' => 4],
                    ['title' => 'Safety compliance photo', 'description' => 'Photo of safety setup', 'type' => 'photo', 'required' => false, 'order' => 5],
                ]),
            ],
        ];

        foreach ($templates as $templateData) {
            ControlTemplate::create($templateData);
        }

        // Create some completed control lists
        $machines = Machine::with('company')->get();
        $operators = User::role('operator')->get();

        foreach ($machines->random(min(20, $machines->count())) as $machine) {
            $template = ControlTemplate::inRandomOrder()->first();
            $operator = $operators->where('company_id', $machine->company_id)->random();
            $manager = User::role('manager')->where('company_id', $machine->company_id)->first();

            $controlList = ControlList::factory()->create([
                'machine_id' => $machine->id,
                'control_template_id' => $template->id,
                'operator_id' => $operator->id,
                'manager_id' => $manager?->id,
                'title' => $template->name . ' - ' . $machine->name,
                'status' => ['pending', 'approved', 'approved', 'completed'][array_rand(['pending', 'approved', 'approved', 'completed'])],
                'scheduled_at' => now()->subDays(rand(1, 7)),
                'started_at' => now()->subDays(rand(1, 7)),
                'completed_at' => rand(0, 1) ? now()->subDays(rand(0, 7)) : null,
            ]);

            // Add items to control list
            foreach ($template->items as $templateItem) {
                $controlList->items()->create([
                    'control_template_item_id' => $templateItem->id,
                    'title' => $templateItem->title,
                    'description' => $templateItem->description,
                    'type' => $templateItem->type,
                    'required' => $templateItem->required,
                    'order' => $templateItem->order,
                    'value' => $templateItem->type === 'checkbox' ? (rand(0, 1) ? 'checked' : null) : null,
                    'checked' => $templateItem->type === 'checkbox' ? rand(0, 1) : null,
                ]);
            }
        }

        $this->command->info('Demo data seeded successfully!');
        $this->command->info('Companies: ' . Company::count());
        $this->command->info('Users: ' . User::count());
        $this->command->info('Machines: ' . Machine::count());
        $this->command->info('Control Templates: ' . ControlTemplate::count());
        $this->command->info('Control Lists: ' . ControlList::count());
    }
}
