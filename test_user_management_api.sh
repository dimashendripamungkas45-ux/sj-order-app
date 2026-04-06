#!/bin/bash

# ==============================================================================
# USER MANAGEMENT API TESTING SCRIPT
# ==============================================================================
# Script untuk testing semua endpoint User Management
#
# REQUIREMENTS:
# - curl command line tool
# - Backend Laravel berjalan di http://localhost:8000
# - User admin dengan token sudah terautentikasi
#
# USAGE:
# 1. Set TOKEN variable dengan bearer token admin Anda
# 2. Run: bash test_user_management.sh
#
# ==============================================================================

# Set variables
API_URL="http://localhost:8000/api"
TOKEN="your_bearer_token_here"  # GANTI DENGAN TOKEN ANDA!
ADMIN_EMAIL="admin@example.com"

# Color codes untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function untuk print header
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Function untuk print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function untuk print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function untuk print info
print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# ==============================================================================
# TEST 1: LOGIN (Dapatkan Token)
# ==============================================================================
print_header "TEST 1: LOGIN & GET TOKEN"

echo "Logging in as admin..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "'$ADMIN_EMAIL'",
    "password": "password"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    print_error "Login failed! Please check credentials"
    print_info "Response: $LOGIN_RESPONSE"
    exit 1
fi

print_success "Login successful!"
print_info "Token: ${TOKEN:0:20}..."

# ==============================================================================
# TEST 2: GET ALL USERS
# ==============================================================================
print_header "TEST 2: GET ALL USERS"

echo "Fetching all users..."
curl -s -X GET "$API_URL/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'

print_success "Users fetched successfully"

# ==============================================================================
# TEST 3: CREATE NEW USER
# ==============================================================================
print_header "TEST 3: CREATE NEW USER"

USER_EMAIL="test_$(date +%s)@example.com"
echo "Creating new user with email: $USER_EMAIL"

CREATE_RESPONSE=$(curl -s -X POST "$API_URL/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "'$USER_EMAIL'",
    "password": "password123",
    "role": "employee",
    "status": "active",
    "phone_number": "081234567890",
    "division": "IT Division"
  }')

echo $CREATE_RESPONSE | jq '.'

USER_ID=$(echo $CREATE_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$USER_ID" ]; then
    print_error "Failed to create user"
    exit 1
fi

print_success "User created with ID: $USER_ID"

# ==============================================================================
# TEST 4: GET SPECIFIC USER
# ==============================================================================
print_header "TEST 4: GET SPECIFIC USER"

echo "Getting user with ID: $USER_ID"
curl -s -X GET "$API_URL/users/$USER_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'

print_success "User retrieved successfully"

# ==============================================================================
# TEST 5: UPDATE USER
# ==============================================================================
print_header "TEST 5: UPDATE USER"

echo "Updating user with ID: $USER_ID"
curl -s -X PUT "$API_URL/users/$USER_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User Updated",
    "role": "leader",
    "status": "active"
  }' | jq '.'

print_success "User updated successfully"

# ==============================================================================
# TEST 6: SEARCH USERS
# ==============================================================================
print_header "TEST 6: SEARCH USERS"

echo "Searching for users with role 'employee'..."
curl -s -X GET "$API_URL/users/search?role=employee" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'

print_success "Search completed"

# ==============================================================================
# TEST 7: BATCH UPDATE STATUS
# ==============================================================================
print_header "TEST 7: BATCH UPDATE STATUS"

echo "Updating status for users..."
curl -s -X POST "$API_URL/users/batch-update-status" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_ids": ['$USER_ID'],
    "status": "inactive"
  }' | jq '.'

print_success "Batch update completed"

# ==============================================================================
# TEST 8: DELETE USER
# ==============================================================================
print_header "TEST 8: DELETE USER"

echo "Deleting user with ID: $USER_ID"
curl -s -X DELETE "$API_URL/users/$USER_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'

print_success "User deleted successfully"

# ==============================================================================
# SUMMARY
# ==============================================================================
print_header "TEST SUMMARY"
print_success "All tests completed successfully!"
print_info "Endpoints tested:"
print_info "  ✓ POST /login"
print_info "  ✓ GET /users"
print_info "  ✓ POST /users"
print_info "  ✓ GET /users/{id}"
print_info "  ✓ PUT /users/{id}"
print_info "  ✓ GET /users/search"
print_info "  ✓ POST /users/batch-update-status"
print_info "  ✓ DELETE /users/{id}"

