<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reservations', function (Blueprint $table) {

            $table->id();

            $table->foreignId('car_owner_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->foreignId('garage_id')
                ->constrained('garages')
                ->cascadeOnDelete();

            $table->date('reservation_date');
            $table->time('start_time');
            $table->time('end_time');

            $table->unsignedInteger('number_of_spots')->default(1);

            $table->enum('status', [
                'pending',
                'accepted',
                'rejected',
                'cancelled',
                'completed'
            ])->default('pending');

            $table->decimal('price_per_hour', 10, 2)->nullable();
            $table->decimal('total_cost', 10, 2)->nullable();

            $table->timestamp('cancelled_at')->nullable();
            $table->text('cancel_reason')->nullable();
            $table->text('owner_response_note')->nullable();

            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reservations');
    }
};
