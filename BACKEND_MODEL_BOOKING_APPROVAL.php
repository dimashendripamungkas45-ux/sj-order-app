<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'division_id',
        'booking_code',
        'booking_type',
        'booking_date',
        'start_time',
        'end_time',
        'purpose',
        'room_id',
        'vehicle_id',
        'participants_count',
        'destination',
        'status',
        'approved_by_division',
        'approved_at_division',
        'division_approval_notes',
        'approved_by_divum',
        'approved_at_divum',
        'divum_approval_notes',
    ];

    protected $casts = [
        'booking_date' => 'date',
        'start_time' => 'datetime:H:i',
        'end_time' => 'datetime:H:i',
        'approved_at_division' => 'datetime',
        'approved_at_divum' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // ===== RELATIONSHIPS =====

    /**
     * Get the user who created this booking
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Get the division
     */
    public function division(): BelongsTo
    {
        return $this->belongsTo(Division::class, 'division_id');
    }

    /**
     * Get the room (jika booking type = room)
     */
    public function room(): BelongsTo
    {
        return $this->belongsTo(Room::class, 'room_id');
    }

    /**
     * Get the vehicle (jika booking type = vehicle)
     */
    public function vehicle(): BelongsTo
    {
        return $this->belongsTo(Vehicle::class, 'vehicle_id');
    }

    /**
     * Get the user who approved from division
     */
    public function divisionApprover(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by_division');
    }

    /**
     * Get the user who approved from DIVUM
     */
    public function divumApprover(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by_divum');
    }

    // ===== ACCESSORS & METHODS =====

    /**
     * Get status label in Indonesian
     */
    public function getStatusLabel(): string
    {
        return match($this->status) {
            'pending_division' => 'Menunggu Persetujuan Divisi',
            'pending_divum' => 'Menunggu Persetujuan DIVUM',
            'approved' => 'Disetujui',
            'rejected_division' => 'Ditolak oleh Divisi',
            'rejected_divum' => 'Ditolak oleh DIVUM',
            default => 'Unknown',
        };
    }

    /**
     * Get status color code untuk UI
     */
    public function getStatusColor(): string
    {
        return match($this->status) {
            'pending_division', 'pending_divum' => '#FFC107',  // Yellow
            'approved' => '#4CAF50',                            // Green
            'rejected_division', 'rejected_divum' => '#F44336', // Red
            default => '#9E9E9E',                               // Grey
        };
    }

    /**
     * Check if booking is pending division approval
     */
    public function isPendingDivision(): bool
    {
        return $this->status === 'pending_division';
    }

    /**
     * Check if booking is pending DIVUM approval
     */
    public function isPendingDivum(): bool
    {
        return $this->status === 'pending_divum';
    }

    /**
     * Check if booking is approved
     */
    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }

    /**
     * Check if booking is rejected
     */
    public function isRejected(): bool
    {
        return in_array($this->status, ['rejected_division', 'rejected_divum']);
    }

    /**
     * Get resource name (Room atau Vehicle)
     */
    public function getResourceName(): string
    {
        if ($this->booking_type === 'room') {
            return $this->room?->name ?? 'Ruangan tidak ditemukan';
        } else {
            return $this->vehicle?->name ?? 'Kendaraan tidak ditemukan';
        }
    }

    /**
     * Format untuk API response
     */
    public function toApiResponse(): array
    {
        return [
            'id' => $this->id,
            'booking_code' => $this->booking_code,
            'user_id' => $this->user_id,
            'division_id' => $this->division_id,
            'booking_type' => $this->booking_type,
            'booking_date' => $this->booking_date->format('Y-m-d'),
            'start_time' => $this->start_time->format('H:i'),
            'end_time' => $this->end_time->format('H:i'),
            'purpose' => $this->purpose,
            'room_id' => $this->room_id,
            'vehicle_id' => $this->vehicle_id,
            'participants_count' => $this->participants_count,
            'destination' => $this->destination,
            'status' => $this->status,
            'status_label' => $this->getStatusLabel(),
            'status_color' => $this->getStatusColor(),
            'resource_name' => $this->getResourceName(),
            'user' => [
                'id' => $this->user->id,
                'name' => $this->user->name,
                'email' => $this->user->email,
            ],
            'approved_by_division' => $this->approved_by_division,
            'approved_at_division' => $this->approved_at_division?->format('Y-m-d H:i:s'),
            'division_approval_notes' => $this->division_approval_notes,
            'division_approver' => $this->divisionApprover ? [
                'id' => $this->divisionApprover->id,
                'name' => $this->divisionApprover->name,
            ] : null,
            'approved_by_divum' => $this->approved_by_divum,
            'approved_at_divum' => $this->approved_at_divum?->format('Y-m-d H:i:s'),
            'divum_approval_notes' => $this->divum_approval_notes,
            'divum_approver' => $this->divumApprover ? [
                'id' => $this->divumApprover->id,
                'name' => $this->divumApprover->name,
            ] : null,
            'created_at' => $this->created_at->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at->format('Y-m-d H:i:s'),
        ];
    }
}

