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
        Schema::create('machine_work_sessions', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->foreignId('machine_id')->constrained()->onDelete('cascade');
            $table->foreignId('operator_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('control_list_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('company_id')->constrained()->onDelete('cascade');

            // Work session times
            $table->dateTime('start_time');
            $table->dateTime('end_time')->nullable();
            $table->integer('duration_minutes')->nullable(); // Calculated duration

            // Status
            $table->enum('status', ['in_progress', 'completed', 'approved', 'rejected'])->default('in_progress');

            // Location and notes
            $table->string('location')->nullable();
            $table->text('start_notes')->nullable(); // Notes when starting
            $table->text('end_notes')->nullable(); // Notes when ending

            // Manager approval
            $table->foreignId('approved_by')->nullable()->constrained('users')->onDelete('set null');
            $table->dateTime('approved_at')->nullable();
            $table->text('approval_notes')->nullable();

            $table->softDeletes();
            $table->timestamps();

            // Indexes
            $table->index(['machine_id', 'status']);
            $table->index(['operator_id', 'status']);
            $table->index(['company_id', 'status']);
            $table->index('start_time');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('machine_work_sessions');
    }
};
