<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('garages', function (Blueprint $table) {

            $table->id();

            $table->foreignId('owner_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->string('name');

            $table->string('city');
            $table->string('address');

            $table->decimal('price_per_hour', 10, 2);

            $table->integer('capacity');
            $table->integer('available_spots');

            $table->time('open_time')->nullable();
            $table->time('close_time')->nullable();

            $table->text('description')->nullable();

            $table->boolean('is_approved')->default(false);
            $table->boolean('is_active')->default(true);

            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('garages');
    }
};
