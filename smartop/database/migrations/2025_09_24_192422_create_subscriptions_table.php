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
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->foreignId('company_id')->constrained()->onDelete('cascade');
            $table->string('plan_name'); // starter, professional, enterprise
            $table->decimal('monthly_price', 8, 2);
            $table->integer('max_machines');
            $table->integer('max_managers');
            $table->integer('max_operators');
            $table->json('features'); // Plan features
            $table->enum('status', ['active', 'inactive', 'expired', 'cancelled'])->default('active');
            $table->date('starts_at');
            $table->date('expires_at');
            $table->date('next_billing_date')->nullable();
            $table->enum('billing_cycle', ['monthly', 'yearly'])->default('monthly');
            $table->json('payment_details')->nullable();
            $table->softDeletes();
            $table->timestamps();
            
            // Indexes
            $table->index(['company_id', 'status']);
            $table->index(['expires_at', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
    }
};
