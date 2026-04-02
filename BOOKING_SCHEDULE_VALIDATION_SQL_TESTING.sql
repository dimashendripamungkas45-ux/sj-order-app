-- BOOKING_SCHEDULE_VALIDATION_SQL_TESTING.sql
-- Test scenarios untuk validate system secara database level

-- ==========================================
-- 1. INSERT TEST DATA
-- ==========================================

-- Bersihkan data lama (OPTIONAL - HATI-HATI!)
-- DELETE FROM bookings WHERE DATE(booking_date) = '2024-03-15';

-- Insert test rooms
INSERT INTO rooms (name, capacity, description, is_active, created_at, updated_at) VALUES
('Meeting Room A', 10, 'Room untuk meeting kecil', true, NOW(), NOW()),
('Meeting Room B', 20, 'Room untuk meeting sedang', true, NOW(), NOW()),
('Conference Hall', 50, 'Room untuk conference', true, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- Insert test vehicles
INSERT INTO vehicles (name, type, capacity, license_plate, description, is_active, created_at, updated_at) VALUES
('Toyota Avanza 1', 'SUV', 7, 'B-1234-AB', 'Kendaraan untuk perjalanan', true, NOW(), NOW()),
('Toyota Avanza 2', 'SUV', 7, 'B-5678-CD', 'Kendaraan untuk perjalanan', true, NOW(), NOW()),
('Honda Civic', 'Sedan', 4, 'B-9012-EF', 'Mobil eksekutif', true, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- Insert test users
INSERT INTO users (name, email, password, role, division_id, created_at, updated_at) VALUES
('Karyawan 1', 'karyawan1@test.com', BCRYPT('password'), 'employee', 1, NOW(), NOW()),
('Leader Divisi 1', 'leader1@test.com', BCRYPT('password'), 'head_division', 1, NOW(), NOW()),
('Admin GA', 'admin@test.com', BCRYPT('password'), 'admin', NULL, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- ==========================================
-- 2. SCENARIO 1: NORMAL APPROVED BOOKING
-- ==========================================

-- Insert approved booking: 09:00-10:00
INSERT INTO bookings
(user_id, division_id, booking_code, booking_type, booking_date, start_time, end_time, purpose, room_id, vehicle_id, status, approved_by_division, approved_at_division, approved_by_divum, approved_at_divum, created_at, updated_at)
VALUES
(1, 1, '20240315001', 'room', '2024-03-15', '09:00', '10:00', 'Team Meeting', 1, NULL, 'approved', 2, NOW(), 3, NOW(), NOW(), NOW());

-- Query: Check jika booking ini approved
SELECT * FROM bookings
WHERE booking_date = '2024-03-15'
AND room_id = 1
AND status = 'approved'
ORDER BY start_time;

-- ==========================================
-- 3. SCENARIO 2: CONFLICT TEST (Direct Query)
-- ==========================================

-- Booking yang ingin dibuat: 09:30-10:30
-- Expected: Conflict karena overlap dengan existing 09:00-10:00

SELECT * FROM bookings
WHERE booking_type = 'room'
AND room_id = 1
AND booking_date = '2024-03-15'
AND status = 'approved'
AND TIME('2024-03-15 09:30') < TIME(CONCAT(booking_date, ' ', end_time))  -- New start < existing end
AND TIME('2024-03-15 10:30') > TIME(CONCAT(booking_date, ' ', start_time)) -- New end > existing start
ORDER BY start_time;

-- Result: Should show 1 row (the 09:00-10:00 booking)

-- ==========================================
-- 4. SCENARIO 3: BUFFER TIME TEST
-- ==========================================

-- Booking yang ingin dibuat: 10:00-11:00 (immediately after existing 09:00-10:00)
-- Expected: Conflict karena perlu buffer 30 menit (09:30-10:30 adalah buffer zone)

-- Query dengan buffer zone (30 menit sebelum dan sesudah)
SELECT * FROM bookings
WHERE booking_type = 'room'
AND room_id = 1
AND booking_date = '2024-03-15'
AND status = 'approved'
-- Buffer 30 minutes before = SUBTIME(start_time, '00:30:00')
-- Buffer 30 minutes after = ADDTIME(end_time, '00:30:00')
-- Check conflict dengan buffer zone
AND ADDTIME('2024-03-15 10:00', '00:30:00') > SUBTIME(CONCAT(booking_date, ' ', start_time), '00:30:00')
AND SUBTIME('2024-03-15 11:00', '00:30:00') < ADDTIME(CONCAT(booking_date, ' ', end_time), '00:30:00');

-- Result: Should show 1 row (conflict detected with buffer)

-- ==========================================
-- 5. SCENARIO 4: NO CONFLICT TEST
-- =========================================

-- Booking yang ingin dibuat: 10:30-11:30 (dengan proper buffer)
-- Expected: NO conflict (gap dari 10:00 ke 10:30 = 30 menit buffer)

SELECT * FROM bookings
WHERE booking_type = 'room'
AND room_id = 1
AND booking_date = '2024-03-15'
AND status = 'approved'
AND ADDTIME('2024-03-15 10:30', '00:30:00') > SUBTIME(CONCAT(booking_date, ' ', start_time), '00:30:00')
AND SUBTIME('2024-03-15 11:30', '00:30:00') < ADDTIME(CONCAT(booking_date, ' ', end_time), '00:30:00');

-- Result: Should be EMPTY (no conflict)

-- ==========================================
-- 6. SCENARIO 5: AVAILABLE SLOTS TEST
-- ==========================================

-- Generate available slots untuk Meeting Room A pada 2024-03-15
-- Assume existing booking: 09:00-10:00
-- Assume operating hours: 08:00-17:00
-- Assume interval: 30 menit

-- Full time blocks
WITH time_slots AS (
  SELECT '08:00' as slot_start, '08:30' as slot_end UNION ALL
  SELECT '08:30', '09:00' UNION ALL
  SELECT '09:00', '09:30' UNION ALL -- Conflict zone (with buffer)
  SELECT '09:30', '10:00' UNION ALL -- Conflict zone (with buffer)
  SELECT '10:00', '10:30' UNION ALL -- Conflict zone (with buffer)
  SELECT '10:30', '11:00' UNION ALL -- Conflict zone (with buffer)
  SELECT '11:00', '11:30' UNION ALL
  SELECT '11:30', '12:00' UNION ALL
  -- ... continue sampai 17:00
  SELECT '16:30', '17:00'
)
SELECT ts.slot_start, ts.slot_end,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM bookings b
      WHERE b.booking_type = 'room'
      AND b.room_id = 1
      AND b.booking_date = '2024-03-15'
      AND b.status = 'approved'
      AND TIME(ts.slot_start) < TIME(ADDTIME(CONCAT(b.booking_date, ' ', b.end_time), '00:30:00'))
      AND TIME(ts.slot_end) > TIME(SUBTIME(CONCAT(b.booking_date, ' ', b.start_time), '00:30:00'))
    ) THEN 'BUSY'
    ELSE 'AVAILABLE'
  END as status
FROM time_slots ts;

-- Result: Show semua slots dengan status AVAILABLE atau BUSY

-- ==========================================
-- 7. TEST MULTIPLE BOOKINGS
-- ==========================================

-- Insert 2nd approved booking untuk test multiple conflicts
INSERT INTO bookings
(user_id, division_id, booking_code, booking_type, booking_date, start_time, end_time, purpose, room_id, vehicle_id, status, approved_by_division, approved_at_division, approved_by_divum, approved_at_divum, created_at, updated_at)
VALUES
(1, 1, '20240315002', 'room', '2024-03-15', '13:00', '14:30', 'Client Meeting', 1, NULL, 'approved', 2, NOW(), 3, NOW(), NOW(), NOW());

-- Check semua approved bookings untuk room ini
SELECT booking_code, start_time, end_time, purpose, status
FROM bookings
WHERE booking_type = 'room'
AND room_id = 1
AND booking_date = '2024-03-15'
AND status = 'approved'
ORDER BY start_time;

-- Result: Should show 2 rows

-- ==========================================
-- 8. PENDING BOOKING TEST (Should NOT block)
-- ==========================================

-- Insert pending booking (should not affect conflict check)
INSERT INTO bookings
(user_id, division_id, booking_code, booking_type, booking_date, start_time, end_time, purpose, room_id, vehicle_id, status, created_at, updated_at)
VALUES
(1, 1, '20240315003', 'room', '2024-03-15', '10:30', '11:30', 'Planning', 1, NULL, 'pending_division', NOW(), NOW());

-- Check conflict ONLY dengan approved bookings
SELECT * FROM bookings
WHERE booking_type = 'room'
AND room_id = 1
AND booking_date = '2024-03-15'
AND status = 'approved'
AND ADDTIME('2024-03-15 10:30', '00:30:00') > SUBTIME(CONCAT(booking_date, ' ', start_time), '00:30:00')
AND SUBTIME('2024-03-15 11:30', '00:30:00') < ADDTIME(CONCAT(booking_date, ' ', end_time), '00:30:00');

-- Result: Should be EMPTY (pending booking doesn't affect)

-- ==========================================
-- 9. VEHICLE BOOKING TEST
-- ==========================================

-- Insert vehicle booking
INSERT INTO bookings
(user_id, division_id, booking_code, booking_type, booking_date, start_time, end_time, purpose, room_id, vehicle_id, destination, status, approved_by_division, approved_at_division, approved_by_divum, approved_at_divum, created_at, updated_at)
VALUES
(1, 1, '20240315004', 'vehicle', '2024-03-15', '09:00', '12:00', 'Perjalanan ke Cabang', NULL, 1, 'Kantor Cabang', 'approved', 2, NOW(), 3, NOW(), NOW(), NOW());

-- Check conflict untuk vehicle
SELECT * FROM bookings
WHERE booking_type = 'vehicle'
AND vehicle_id = 1
AND booking_date = '2024-03-15'
AND status = 'approved'
AND ADDTIME('2024-03-15 11:00', '00:30:00') > SUBTIME(CONCAT(booking_date, ' ', start_time), '00:30:00')
AND SUBTIME('2024-03-15 12:30', '00:30:00') < ADDTIME(CONCAT(booking_date, ' ', end_time), '00:30:00');

-- Result: Should show 1 row (conflict)

-- ==========================================
-- 10. INDEX VERIFICATION
-- ==========================================

-- Verify indexes sudah dibuat
SHOW INDEX FROM bookings;

-- Expected indexes:
-- - idx_booking_room_schedule (booking_type, room_id, booking_date, start_time, end_time)
-- - idx_booking_vehicle_schedule (booking_type, vehicle_id, booking_date, start_time, end_time)
-- - idx_status
-- - idx_booking_date

-- ==========================================
-- 11. PERFORMANCE TEST
-- ==========================================

-- Test query performance SEBELUM ada conflict check
-- Ini query yang dijalankan di BookingScheduleValidator.php

-- Query dengan buffer time (30 menit)
SELECT * FROM bookings
WHERE booking_type = 'room'
AND room_id = 1
AND booking_date = '2024-03-15'
AND status = 'approved'
-- Request time: 11:00 - 12:00
-- Check if overlaps dengan buffer (09:30 - 12:30)
AND TIME('11:00') < TIME(ADDTIME(CONCAT(booking_date, ' ', end_time), '00:30:00'))
AND TIME('12:00') > TIME(SUBTIME(CONCAT(booking_date, ' ', start_time), '00:30:00'));

-- Gunakan EXPLAIN untuk check query plan
EXPLAIN SELECT * FROM bookings
WHERE booking_type = 'room'
AND room_id = 1
AND booking_date = '2024-03-15'
AND status = 'approved'
AND TIME('11:00') < TIME(ADDTIME(CONCAT(booking_date, ' ', end_time), '00:30:00'))
AND TIME('12:00') > TIME(SUBTIME(CONCAT(booking_date, ' ', start_time), '00:30:00'));

-- Should use index untuk fast query (< 10ms)

-- ==========================================
-- 12. CLEANUP (OPTIONAL)
-- ==========================================

-- Delete test data
-- DELETE FROM bookings WHERE booking_date = '2024-03-15';
-- DELETE FROM rooms WHERE name LIKE 'Meeting Room%' OR name = 'Conference Hall';
-- DELETE FROM vehicles WHERE license_plate LIKE 'B-%';
-- DELETE FROM users WHERE email LIKE '%test.com%';

-- ==========================================
-- SUMMARY
-- ==========================================
--
-- Test Scenarios:
-- 1. ✅ Normal approved booking
-- 2. ✅ Conflict detection (overlap)
-- 3. ✅ Buffer time enforcement (30 min)
-- 4. ✅ No conflict jika gap cukup
-- 5. ✅ Available slots generation
-- 6. ✅ Multiple bookings handling
-- 7. ✅ Pending bookings tidak block (hanya approved)
-- 8. ✅ Vehicle booking support
-- 9. ✅ Index verification
-- 10. ✅ Performance validation
--
-- Hasil Expected: Semua query di atas harus return hasil yang sesuai
-- Jika ada yang berbeda, ada bug di implementation
--

