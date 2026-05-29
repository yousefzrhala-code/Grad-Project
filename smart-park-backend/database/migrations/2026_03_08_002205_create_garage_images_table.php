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
        Schema::create('garage_images', function (Blueprint $table) {
            $table->id();

            $table->foreignId('garage_id')
                ->constrained('garages')
                ->cascadeOnDelete();

            $table->string('image_path');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('garage_images');
    }
};
