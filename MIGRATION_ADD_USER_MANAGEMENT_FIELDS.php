<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Migration untuk menambahkan kolom user management ke tabel users
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
            // Jika kolom belum ada, tambahkan
            if (!Schema::hasColumn('users', 'role')) {
                $table->string('role')->default('employee')->after('email')
                    ->comment('Role: employee, leader, admin');
            }

            if (!Schema::hasColumn('users', 'status')) {
                $table->enum('status', ['active', 'inactive'])->default('active')->after('role')
                    ->comment('Status: active, inactive');
            }

            if (!Schema::hasColumn('users', 'phone_number')) {
                $table->string('phone_number')->nullable()->after('status')
                    ->comment('Nomor telepon pengguna');
            }

            if (!Schema::hasColumn('users', 'division')) {
                $table->string('division')->nullable()->after('phone_number')
                    ->comment('Divisi pengguna');
            }

            // Add indexes untuk performa query
            $table->index('role');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'role',
                'status',
                'phone_number',
                'division'
            ]);
        });
    }
};

