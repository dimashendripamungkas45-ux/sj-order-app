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
        // Create bookings table dengan approval workflow
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();

            // User info
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('division_id')->nullable()->constrained('divisions')->onDelete('set null');

            // Booking details
            $table->string('booking_code')->unique();
            $table->enum('booking_type', ['room', 'vehicle']);
            $table->date('booking_date');
            $table->time('start_time');
            $table->time('end_time');
            $table->text('purpose');

            // Resource references
            $table->foreignId('room_id')->nullable()->constrained('rooms')->onDelete('set null');
            $table->foreignId('vehicle_id')->nullable()->constrained('vehicles')->onDelete('set null');

            // Additional info
            $table->integer('participants_count')->nullable();
            $table->string('destination')->nullable();

            // Status & Approval Workflow
            $table->enum('status', [
                'pending_division',    // Menunggu approval dari Pimpinan Divisi
                'pending_divum',       // Sudah diapprove divisi, menunggu approval DIVUM
                'approved',            // Fully approved
                'rejected_division',   // Ditolak oleh Pimpinan Divisi
                'rejected_divum'       // Ditolak oleh DIVUM
            ])->default('pending_division');

            // Approval tracking
            $table->foreignId('approved_by_division')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('approved_at_division')->nullable();
            $table->text('division_approval_notes')->nullable();

            $table->foreignId('approved_by_divum')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('approved_at_divum')->nullable();
            $table->text('divum_approval_notes')->nullable();

            // Timestamps
            $table->timestamps();

            // Indexes for better query performance
            $table->index('user_id');
            $table->index('division_id');
            $table->index('status');
            $table->index('booking_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};

