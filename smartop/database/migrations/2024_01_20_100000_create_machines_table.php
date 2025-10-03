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
            $table->string('type'); // Changed from machine_type to match model
            $table->string('model');
            $table->string('serial_number')->unique();
            $table->string('manufacturer')->nullable(); // Changed from brand
            $table->date('production_date')->nullable(); // Changed from manufacture_year
            $table->date('installation_date')->nullable();
            $table->json('specifications')->nullable(); // Technical specifications
            $table->foreignId('company_id')->constrained()->onDelete('cascade'); // Required field, cascade delete
            $table->enum('status', ['active', 'inactive', 'maintenance', 'out_of_service'])->default('active');
            $table->string('location')->nullable();
            $table->string('qr_code')->nullable()->unique();
            $table->text('notes')->nullable();
            $table->softDeletes();
            $table->timestamps();

            // Indexes for better performance
            $table->index(['company_id', 'status']);
            $table->index(['type', 'status']);
            $table->index('serial_number');
            $table->index('qr_code');
            $table->index('status');
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
