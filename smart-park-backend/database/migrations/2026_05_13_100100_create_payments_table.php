<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->foreignId('reservation_id')
                ->nullable()
                ->constrained('reservations')
                ->nullOnDelete();

            $table->decimal('amount', 10, 2);
            $table->string('currency', 8)->default('JOD');

            // 'card' or 'cash'
            $table->string('payment_method', 16)->default('card');

            // Fake card data — nullable because cash payments have no card.
            $table->string('card_last4', 4)->nullable();
            $table->string('card_holder')->nullable();

            // 'succeeded' | 'failed' | 'pending_cash'
            $table->string('status')->default('pending');

            $table->string('transaction_id')->unique();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
