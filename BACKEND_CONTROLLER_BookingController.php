<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    /**
     * Get all bookings for current user
     */
    public function index()
    {
        $bookings = Booking::where('user_id', auth('api')->id())
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function($booking) {
                return [
                    'id' => $booking->id,
                    'service_name' => $booking->service_name,
                    'status' => $booking->status,
                    'booking_date' => $booking->booking_date,
                    'description' => $booking->description,
                    'price' => $booking->price,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Bookings retrieved successfully',
            'data' => $bookings
        ], 200);
    }

    /**
     * Get single booking
     */
    public function show($id)
    {
        $booking = Booking::where('id', $id)
            ->where('user_id', auth('api')->id())
            ->first();

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $booking->id,
                'service_name' => $booking->service_name,
                'status' => $booking->status,
                'booking_date' => $booking->booking_date,
                'description' => $booking->description,
                'price' => $booking->price,
            ]
        ], 200);
    }

    /**
     * Create booking
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'service_name' => 'required|string|max:255',
            'booking_date' => 'required|date',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
        ]);

        $booking = Booking::create([
            'user_id' => auth('api')->id(),
            'service_name' => $validated['service_name'],
            'booking_date' => $validated['booking_date'],
            'description' => $validated['description'] ?? '',
            'price' => $validated['price'],
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Booking created successfully',
            'data' => $booking
        ], 201);
    }

    /**
     * Update booking
     */
    public function update(Request $request, $id)
    {
        $booking = Booking::where('id', $id)
            ->where('user_id', auth('api')->id())
            ->first();

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        $validated = $request->validate([
            'service_name' => 'sometimes|string|max:255',
            'booking_date' => 'sometimes|date',
            'description' => 'nullable|string',
            'price' => 'sometimes|numeric|min:0',
            'status' => 'sometimes|in:pending,completed,cancelled',
        ]);

        $booking->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Booking updated successfully',
            'data' => $booking
        ], 200);
    }

    /**
     * Delete booking
     */
    public function destroy($id)
    {
        $booking = Booking::where('id', $id)
            ->where('user_id', auth('api')->id())
            ->first();

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        $booking->delete();

        return response()->json([
            'success' => true,
            'message' => 'Booking deleted successfully'
        ], 200);
    }
}

