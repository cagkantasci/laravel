<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('activity_logs', function (Blueprint $table) {
            $table->id();
            $table->string('type')->index(); // authentication, machine_operation, security, etc.
            $table->string('action')->index(); // login, logout, create, update, delete, etc.
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('machine_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('control_list_id')->nullable()->constrained()->onDelete('set null');
            $table->ipAddress('ip_address')->nullable();
            $table->text('user_agent')->nullable();
            $table->json('data'); // Full event data
            $table->timestamps();

            // Indexes for performance
            $table->index(['type', 'created_at']);
            $table->index(['user_id', 'created_at']);
            $table->index(['machine_id', 'created_at']);
            $table->index(['created_at', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('activity_logs');
    }
};