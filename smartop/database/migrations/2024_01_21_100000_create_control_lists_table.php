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
        Schema::create('control_lists', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->foreignId('machine_id')->constrained()->onDelete('cascade');
            $table->foreignId('control_template_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // Changed from operator_id
            $table->foreignId('company_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->text('description')->nullable();
            $table->json('control_items'); // Array of control items with responses
            $table->enum('status', ['pending', 'completed', 'approved', 'rejected', 'expired'])->default('pending');
            $table->enum('priority', ['low', 'medium', 'high', 'critical'])->default('medium');
            $table->timestamp('scheduled_date')->nullable();
            $table->timestamp('completed_date')->nullable();
            $table->foreignId('approved_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('approved_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->text('notes')->nullable();
            $table->softDeletes();
            $table->timestamps();

            // Indexes for better performance
            $table->index(['machine_id', 'status', 'created_at']);
            $table->index(['user_id', 'status']);
            $table->index(['company_id', 'status']);
            $table->index(['status', 'scheduled_date']);
            $table->index(['priority', 'status']);
            $table->index('approved_by');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('control_lists');
    }
};
