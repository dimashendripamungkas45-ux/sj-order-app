<?php

// routes/api.php - ADD THESE ROUTES

use App\Http\Controllers\Api\BookingApprovalController;

Route::middleware('auth:sanctum')->group(function () {

    // ===== APPROVAL ENDPOINTS =====

    /**
     * TAHAP 1: Pimpinan Divisi Approval
     *
     * Endpoint: PATCH /api/bookings/{id}/approve-division
     *
     * Request:
     * {
     *   "action": "approve" or "reject",
     *   "notes": "Catatan approval (optional)"
     * }
     *
     * Status Transitions:
     * - approve: pending_division → pending_ga
     * - reject: pending_division → rejected_division
     */
    Route::patch('/bookings/{id}/approve-division', [BookingApprovalController::class, 'approveDivision']);

    /**
     * TAHAP 2: Admin GA/DIVUM Final Approval
     *
     * Endpoint: PATCH /api/bookings/{id}/approve-ga
     *
     * Request:
     * {
     *   "action": "approve" or "reject",
     *   "notes": "Catatan approval (optional)"
     * }
     *
     * Status Transitions:
     * - approve: pending_ga → approved (FINAL!)
     * - reject: pending_ga → rejected_ga
     */
    Route::patch('/bookings/{id}/approve-ga', [BookingApprovalController::class, 'approveGA']);

    /**
     * Get pending bookings untuk pimpinan divisi
     * Endpoint: GET /api/bookings/pending/division
     */
    Route::get('/bookings/pending/division', [BookingApprovalController::class, 'getPendingDivision']);

    /**
     * Get pending bookings untuk admin GA
     * Endpoint: GET /api/bookings/pending/ga
     */
    Route::get('/bookings/pending/ga', [BookingApprovalController::class, 'getPendingGA']);
});

