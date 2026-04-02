<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // ✅ FIX: Modify status column to properly support all status values
        Schema::table('bookings', function (Blueprint $table) {
            // Change status column to ENUM with all required values
            // This will handle: pending_division, pending_ga, pending_divum,
            // approved, rejected_division, rejected_ga, rejected_divum
            $table->enum('status', [
                'pending_division',
                'pending_ga',
                'pending_divum',
                'approved',
                'rejected_division',
                'rejected_ga',
                'rejected_divum',
                'rejected'
            ])->default('pending_division')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            // Revert to original if needed
            $table->string('status', 50)->default('pending_division')->change();
        });
    }
};

