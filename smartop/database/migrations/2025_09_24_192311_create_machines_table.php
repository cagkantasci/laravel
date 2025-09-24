<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('machines', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->string('name');
            $table->string('brand');
            $table->string('model');
            $table->string('serial_number')->unique();
            $table->string('plate_number')->nullable();
            $table->year('manufacture_year')->nullable();
            $table->enum('machine_type', ['excavator', 'bulldozer', 'crane', 'loader', 'grader', 'compactor', 'other']);
            $table->string('engine_type')->nullable();
            $table->integer('engine_power')->nullable(); // HP
            $table->decimal('weight', 8, 2)->nullable(); // Tons
            $table->json('specifications')->nullable(); // Technical specifications
            $table->foreignId('company_id')->nullable()->constrained()->onDelete('set null');
            $table->enum('status', ['active', 'inactive', 'maintenance', 'out_of_service'])->default('active');
            $table->date('last_maintenance_date')->nullable();
            $table->date('next_maintenance_date')->nullable();
            $table->json('photos')->nullable(); // Machine photos URLs
            $table->text('notes')->nullable();
            $table->softDeletes();
            $table->timestamps();
            
            // Indexes
            $table->index(['company_id', 'status']);
            $table->index(['machine_type', 'status']);
            $table->index('serial_number');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('machines');
    }
};
