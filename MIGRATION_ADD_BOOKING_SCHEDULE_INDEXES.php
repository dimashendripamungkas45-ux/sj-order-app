<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tambah indexes untuk optimasi query time-slot conflict checking
     *
     * RUN: php artisan make:migration add_booking_schedule_indexes
     * THEN: php artisan migrate
     */
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            // Index untuk cek conflict time-slot: (booking_type, room_id, booking_date, start_time, end_time)
            if (!Schema::hasIndexPath('bookings', ['booking_type', 'room_id', 'booking_date', 'start_time', 'end_time'])) {
                $table->index(['booking_type', 'room_id', 'booking_date', 'start_time', 'end_time'], 'idx_booking_room_schedule');
            }

            // Index untuk vehicle booking schedule
            if (!Schema::hasIndexPath('bookings', ['booking_type', 'vehicle_id', 'booking_date', 'start_time', 'end_time'])) {
                $table->index(['booking_type', 'vehicle_id', 'booking_date', 'start_time', 'end_time'], 'idx_booking_vehicle_schedule');
            }

            // Index untuk status filtering
            if (!Schema::hasIndex('bookings', 'idx_status')) {
                $table->index('status', 'idx_status');
            }

            // Index untuk date range queries
            if (!Schema::hasIndex('bookings', 'idx_booking_date')) {
                $table->index('booking_date', 'idx_booking_date');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropIndexIfExists('idx_booking_room_schedule');
            $table->dropIndexIfExists('idx_booking_vehicle_schedule');
            $table->dropIndexIfExists('idx_status');
            $table->dropIndexIfExists('idx_booking_date');
        });
    }
};

