<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Columns payment_method, card_last4 (nullable), card_holder (nullable)
        // are already defined correctly in create_payments_table migration.
        // This migration is intentionally left empty.
    }

    public function down(): void
    {
        //
    }
};
