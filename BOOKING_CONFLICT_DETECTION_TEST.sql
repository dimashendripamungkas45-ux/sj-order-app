-- ============================================
-- BOOKING CONFLICT DETECTION TEST SCENARIOS
-- ============================================
-- File ini berisi test cases untuk memverifikasi
-- logika conflict detection bekerja dengan benar

USE your_database_name; -- GANTI dengan nama database Anda

-- Scenario 1: DIRECT OVERLAP (Conflict yang paling obvious)
-- Booking A: 10:00 - 11:00
-- Booking B (New): 10:30 - 11:30 (should NOT be allowed)
-- Expected: CONFLICT ❌ - overlap langsung

SELECT '=== SCENARIO 1: Direct Overlap ===' AS test_name;

-- Assume Booking A sudah ada
-- start_time < buffer_end (10:00 < 11:30) = TRUE
-- end_time > buffer_start (11:00 > 09:30) = TRUE
-- Result: CONFLICT

SELECT
    'Existing Booking' AS booking_type,
    '10:00' AS start_time,
    '11:00' AS end_time,
    'CONFLICT' AS status,
    'New request 10:30-11:30 overlaps' AS reason;

-- ============================================

-- Scenario 2: NO BUFFER - Request langsung setelah booking
-- Booking A: 10:00 - 11:00
-- Booking B (New): 11:00 - 12:00 (should NOT be allowed - no buffer)
-- Expected: CONFLICT ❌ - perlu buffer 30 menit

SELECT '=== SCENARIO 2: No Buffer (Direct After) ===' AS test_name;

-- Buffer calculation:
-- Existing: 10:00 - 11:00
-- Buffer Zone: 09:30 - 11:30 (30 min before + 30 min after)
-- New request: 11:00 - 12:00
-- Check: 11:00 < 11:30? YES, 12:00 > 09:30? YES
-- Result: CONFLICT

SELECT
    'Existing Booking' AS booking_type,
    '10:00' AS start_time,
    '11:00' AS end_time,
    'Buffer Start' AS '09:30',
    'Buffer End' AS '11:30',
    'New Request: 11:00-12:00' AS request,
    'CONFLICT (no 30min buffer)' AS status;

-- ============================================

-- Scenario 3: WITH BUFFER - Request dengan buffer yang cukup
-- Booking A: 10:00 - 11:00
-- Booking B (New): 11:45 - 12:45 (should be allowed - 45 min buffer)
-- Expected: OK ✅

SELECT '=== SCENARIO 3: With Sufficient Buffer ===' AS test_name;

-- Buffer calculation:
-- Existing: 10:00 - 11:00
-- Buffer Zone: 09:30 - 11:30 (30 min before + 30 min after)
-- New request: 11:45 - 12:45
-- Check: 11:45 < 11:30? NO - new request starts AFTER buffer ends
-- Result: NO CONFLICT (OK)

SELECT
    'Existing Booking' AS booking_type,
    '10:00' AS start_time,
    '11:00' AS end_time,
    'Buffer Start' AS '09:30',
    'Buffer End' AS '11:30',
    'New Request: 11:45-12:45' AS request,
    'OK (sufficient buffer)' AS status;

-- ============================================

-- Scenario 4: MULTIPLE BOOKINGS - Check hanya approved
-- Booking A (approved): 10:00 - 11:00
-- Booking B (pending): 10:30 - 11:30 (should NOT affect - pending)
-- Booking C (New): 10:30 - 11:30 (should NOT be allowed - conflict with A)
-- Expected: CONFLICT dengan A saja

SELECT '=== SCENARIO 4: Multiple Bookings (Only Approved) ===' AS test_name;

-- Query hanya check approved bookings
-- Booking A (approved) - check it
-- Booking B (pending) - SKIP it
-- New request harus tidak conflict dengan A

SELECT
    'Booking A (approved)' AS booking_type,
    '10:00' AS start_time,
    '11:00' AS end_time,
    'INCLUDED in conflict check' AS status
UNION ALL
SELECT
    'Booking B (pending)' AS booking_type,
    '10:30' AS start_time,
    '11:30' AS end_time,
    'SKIPPED (not approved)' AS status
UNION ALL
SELECT
    'New Request: 10:30-11:30' AS booking_type,
    'Will conflict with' AS start_time,
    'Booking A only' AS end_time,
    'CONFLICT ❌' AS status;

-- ============================================

-- SQL Query untuk test (ganti dengan nilai actual dari database Anda)
-- Ini adalah SQL yang dihasilkan oleh PHP code

-- Test Case 1: Check availability untuk room_id=1, booking_date=2024-03-20, 10:30-11:30
SELECT
    'SELECT query yang dijalankan di PHP:' AS debug,
    COUNT(*) as conflict_count
FROM bookings
WHERE booking_type = 'room'
  AND booking_date = '2024-03-20'
  AND status = 'approved'
  AND room_id = 1
  AND start_time < '11:30'      -- buffer_end (11:00 + 30min)
  AND end_time > '09:30';        -- buffer_start (10:00 - 30min)

-- Jika query di atas mengembalikan > 0, berarti ADA CONFLICT
-- Result harus CONFLICT

-- ============================================

-- TESTING QUERY LOGIC - Manual Verification
-- Berikut adalah manual test untuk memverifikasi PHP logic:

-- Step 1: Insert test data (kalau belum ada)
-- Pastikan test data ada dengan booking_date tertentu

-- Step 2: Jalankan query dengan parameter yang tepat
-- Room 1, Date 2024-03-20:
-- - Existing booking 10:00-11:00 (approved)
-- - Check new request 10:30-11:30

-- Expected result: conflict_count > 0 (CONFLICT detected)

-- Step 3: Verifikasi dengan berbagai kombinasi waktu:
SELECT
    'Conflict Test Matrix' AS test,
    'Existing Start' AS '10:00',
    'Existing End' AS '11:00',
    'Buffer Start' AS '09:30',
    'Buffer End' AS '11:30',
    'New Request' AS test_case,
    'Expected Result' AS result
UNION ALL SELECT '', '', '', '', '', '10:30 - 11:30', 'CONFLICT'
UNION ALL SELECT '', '', '', '', '', '11:00 - 12:00', 'CONFLICT (no buffer)'
UNION ALL SELECT '', '', '', '', '', '11:45 - 12:45', 'OK (buffer ok)'
UNION ALL SELECT '', '', '', '', '', '08:00 - 09:00', 'OK (before buffer)'
UNION ALL SELECT '', '', '', '', '', '14:00 - 15:00', 'OK (far away)';

-- ============================================
-- Query Performance
-- ============================================

-- Create indexes untuk optimize conflict checking:
CREATE INDEX IF NOT EXISTS idx_booking_type_date_status
ON bookings(booking_type, booking_date, status);

CREATE INDEX IF NOT EXISTS idx_booking_room_id
ON bookings(room_id);

CREATE INDEX IF NOT EXISTS idx_booking_vehicle_id
ON bookings(vehicle_id);

CREATE INDEX IF NOT EXISTS idx_booking_times
ON bookings(start_time, end_time);

-- ============================================
-- Verify Current Data
-- ============================================

-- Lihat semua approved bookings pada tanggal tertentu
SELECT
    'Approved Bookings on 2024-03-20:' AS debug;

SELECT
    id,
    booking_code,
    booking_type,
    room_id,
    vehicle_id,
    start_time,
    end_time,
    purpose,
    status
FROM bookings
WHERE booking_date = '2024-03-20'
  AND status = 'approved'
ORDER BY start_time;

-- ============================================

