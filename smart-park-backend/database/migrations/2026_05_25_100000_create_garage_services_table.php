<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('garage_services', function (Blueprint $table) {
            $table->id();
            $table->foreignId('garage_id')
                ->constrained('garages')
                ->cascadeOnDelete();
            $table->string('name');          // e.g. "Car Wash"
            $table->string('icon')->nullable(); // material icon name, e.g. "local_car_wash"
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('garage_services');
    }
};
