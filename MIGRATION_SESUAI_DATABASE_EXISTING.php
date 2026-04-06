<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Migration untuk menambahkan kolom yang diperlukan untuk User Management
 * SESUAI DENGAN STRUKTUR DATABASE YANG SUDAH ADA
 *
 * Database sudah memiliki struktur:
 * - id, division_id, employee_id, name, email, password, role, phone, is_active
 *
 * Jika ada kolom yang belum ada, akan ditambahkan dengan migration ini
 *
 * Jalankan dengan: php artisan migrate
 */
return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Check dan tambah kolom yang mungkin belum ada

            // Kolom division_id (jika belum ada)
            if (!Schema::hasColumn('users', 'division_id')) {
                $table->unsignedBigInteger('division_id')->nullable()->after('id');
            }

            // Kolom employee_id (jika belum ada)
            if (!Schema::hasColumn('users', 'employee_id')) {
                $table->string('employee_id')->nullable()->unique()->after('division_id');
            }

            // Kolom role (jika belum ada)
            if (!Schema::hasColumn('users', 'role')) {
                $table->string('role')->default('employee')->after('email')
                    ->comment('Role: admin_ga, head_division, employee');
            }

            // Kolom phone (jika belum ada)
            if (!Schema::hasColumn('users', 'phone')) {
                $table->string('phone')->nullable()->after('password')
                    ->comment('Nomor telepon pengguna');
            }

            // Kolom is_active (jika belum ada)
            if (!Schema::hasColumn('users', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('phone')
                    ->comment('Status aktif (1=aktif, 0=tidak aktif)');
            }

            // Add indexes untuk performa query
            if (!Schema::hasColumn('users', 'role')) {
                // Index sudah ditambahkan di atas saat create column
            } else {
                // Jika belum ada index, tambahkan
                try {
                    $table->index('role');
                    $table->index('is_active');
                    $table->index('division_id');
                } catch (\Exception $e) {
                    // Index mungkin sudah ada, skip error
                }
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Hapus kolom yang ditambahkan jika ada
            // HATI-HATI: Jika menggunakan dropColumn, data akan hilang!
            // Uncomment hanya jika ingin benar-benar rollback

            // $table->dropColumn('role');
            // $table->dropColumn('phone');
            // $table->dropColumn('is_active');
            // $table->dropColumn('employee_id');
            // $table->dropColumn('division_id');
        });
    }
};

