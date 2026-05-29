<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('reservations', function (Blueprint $table) {
            $table->timestamp('checked_out_at')->nullable()->after('checked_in_at');
            // 'car_owner' or 'garage_owner' or 'system'
            $table->string('checked_in_by')->nullable()->after('checked_out_at');
            $table->string('checked_out_by')->nullable()->after('checked_in_by');
            $table->string('cancelled_by')->nullable()->after('checked_out_by');
        });
    }

    public function down(): void
    {
        Schema::table('reservations', function (Blueprint $table) {
            $table->dropColumn([
                'checked_out_at',
                'checked_in_by',
                'checked_out_by',
                'cancelled_by',
            ]);
        });
    }
};
