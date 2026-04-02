#!/bin/bash

##############################################
# BOOKING CONFLICT DETECTION - API TEST SCRIPT
##############################################
# Script ini untuk testing conflict detection
# melalui API endpoint

# Color codes untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
API_URL="http://localhost:8000"
TOKEN="your_bearer_token_here" # GANTI dengan token Anda

echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   BOOKING CONFLICT DETECTION - API TEST${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}\n"

# Test 1: Check Availability - Scenario OVERLAP
echo -e "${YELLOW}📋 TEST 1: Direct Overlap (Should FAIL)${NC}"
echo "Existing booking: 10:00 - 11:00"
echo "New request: 10:30 - 11:30"
echo "Expected: CONFLICT ❌\n"

curl -X GET "${API_URL}/api/bookings/check-availability" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/json" \
  -G \
  --data-urlencode "booking_type=room" \
  --data-urlencode "room_id=1" \
  --data-urlencode "booking_date=2024-03-20" \
  --data-urlencode "start_time=10:30" \
  --data-urlencode "end_time=11:30"

echo -e "\n\n"

# Test 2: Check Availability - Scenario NO BUFFER
echo -e "${YELLOW}📋 TEST 2: No Buffer (Should FAIL)${NC}"
echo "Existing booking: 10:00 - 11:00"
echo "New request: 11:00 - 12:00 (langsung setelah)"
echo "Expected: CONFLICT ❌ (need 30min buffer)\n"

curl -X GET "${API_URL}/api/bookings/check-availability" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/json" \
  -G \
  --data-urlencode "booking_type=room" \
  --data-urlencode "room_id=1" \
  --data-urlencode "booking_date=2024-03-20" \
  --data-urlencode "start_time=11:00" \
  --data-urlencode "end_time=12:00"

echo -e "\n\n"

# Test 3: Check Availability - Scenario WITH BUFFER
echo -e "${YELLOW}📋 TEST 3: With Buffer (Should PASS)${NC}"
echo "Existing booking: 10:00 - 11:00"
echo "New request: 11:45 - 12:45 (45min buffer)"
echo "Expected: OK ✅\n"

curl -X GET "${API_URL}/api/bookings/check-availability" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/json" \
  -G \
  --data-urlencode "booking_type=room" \
  --data-urlencode "room_id=1" \
  --data-urlencode "booking_date=2024-03-20" \
  --data-urlencode "start_time=11:45" \
  --data-urlencode "end_time=12:45"

echo -e "\n\n"

# Test 4: Get Available Slots
echo -e "${YELLOW}📋 TEST 4: Get Available Slots${NC}"
echo "Request: Get all available slots on 2024-03-20 for room 1"
echo "Expected: List of available and busy slots\n"

curl -X GET "${API_URL}/api/facilities/available-slots" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/json" \
  -G \
  --data-urlencode "booking_type=room" \
  --data-urlencode "facility_id=1" \
  --data-urlencode "booking_date=2024-03-20"

echo -e "\n\n"

# Test 5: Get Facility Bookings
echo -e "${YELLOW}📋 TEST 5: Get Facility Bookings${NC}"
echo "Request: Get all bookings for room 1 on 2024-03-20"
echo "Expected: List of all bookings with times\n"

curl -X GET "${API_URL}/api/facilities/bookings/room/1/2024-03-20" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/json"

echo -e "\n\n"

# Test 6: Create Booking - Should FAIL due to conflict
echo -e "${YELLOW}📋 TEST 6: Create Booking with Conflict (Should FAIL)${NC}"
echo "Request: Create booking at 10:30-11:30 for room 1"
echo "Expected: CONFLICT response with error\n"

curl -X POST "${API_URL}/api/bookings" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "booking_type": "room",
    "room_id": 1,
    "booking_date": "2024-03-20",
    "start_time": "10:30",
    "end_time": "11:30",
    "purpose": "Test Meeting - Should Fail",
    "participants_count": 5
  }'

echo -e "\n\n"

# Test 7: Create Booking - Should PASS
echo -e "${YELLOW}📋 TEST 7: Create Booking without Conflict (Should PASS)${NC}"
echo "Request: Create booking at 14:00-15:00 for room 1"
echo "Expected: Booking created successfully\n"

curl -X POST "${API_URL}/api/bookings" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "booking_type": "room",
    "room_id": 1,
    "booking_date": "2024-03-20",
    "start_time": "14:00",
    "end_time": "15:00",
    "purpose": "Test Meeting - Should Pass",
    "participants_count": 5
  }'

echo -e "\n\n"

echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   TESTS COMPLETED${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}\n"

echo -e "${GREEN}✅ Testing Guide:${NC}"
echo "1. Replace TOKEN with your actual bearer token"
echo "2. Ensure database has test data for 2024-03-20"
echo "3. Run: bash BOOKING_CONFLICT_FIX_TEST_API.sh"
echo "4. Check response for each test scenario"
echo ""
echo -e "${YELLOW}Expected Results:${NC}"
echo "TEST 1 & 2: available: false (CONFLICT)"
echo "TEST 3: available: true (OK)"
echo "TEST 4 & 5: List of slots/bookings"
echo "TEST 6: success: false (Booking failed)"
echo "TEST 7: success: true (Booking created)"
echo ""


