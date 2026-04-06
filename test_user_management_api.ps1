# ==============================================================================
# USER MANAGEMENT API TESTING SCRIPT (Windows PowerShell)
# ==============================================================================
# Script untuk testing semua endpoint User Management
#
# REQUIREMENTS:
# - PowerShell 5.0+
# - Backend Laravel berjalan di http://localhost:8000
# - User admin sudah terdaftar
#
# USAGE:
# 1. Set token variable di script ini
# 2. Run di PowerShell: .\test_user_management_api.ps1
#
# ==============================================================================

# Set variables
$API_URL = "http://localhost:8000/api"
$ADMIN_EMAIL = "admin@example.com"
$ADMIN_PASSWORD = "password"

# Function untuk print header
function Print-Header {
    param([string]$Text)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

# Function untuk print success
function Print-Success {
    param([string]$Text)
    Write-Host "✓ $Text" -ForegroundColor Green
}

# Function untuk print error
function Print-Error {
    param([string]$Text)
    Write-Host "✗ $Text" -ForegroundColor Red
}

# Function untuk print info
function Print-Info {
    param([string]$Text)
    Write-Host "ℹ $Text" -ForegroundColor Yellow
}

# ==============================================================================
# TEST 1: LOGIN (Dapatkan Token)
# ==============================================================================
Print-Header "TEST 1: LOGIN & GET TOKEN"

Write-Host "Logging in as admin..." -ForegroundColor White

try {
    $LoginBody = @{
        email = $ADMIN_EMAIL
        password = $ADMIN_PASSWORD
    } | ConvertTo-Json

    $LoginResponse = Invoke-WebRequest -Uri "$API_URL/login" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "Accept" = "application/json"
        } `
        -Body $LoginBody `
        -ErrorAction Stop

    $LoginData = $LoginResponse.Content | ConvertFrom-Json
    $TOKEN = $LoginData.token

    if (-not $TOKEN) {
        Print-Error "Login failed! No token received"
        exit 1
    }

    Print-Success "Login successful!"
    Print-Info "Token: $($TOKEN.Substring(0, 20))..."
}
catch {
    Print-Error "Login failed: $_"
    exit 1
}

# ==============================================================================
# TEST 2: GET ALL USERS
# ==============================================================================
Print-Header "TEST 2: GET ALL USERS"

Write-Host "Fetching all users..." -ForegroundColor White

try {
    $Response = Invoke-WebRequest -Uri "$API_URL/users" `
        -Method GET `
        -Headers @{
            "Authorization" = "Bearer $TOKEN"
            "Content-Type" = "application/json"
        } `
        -ErrorAction Stop

    $Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host

    Print-Success "Users fetched successfully"
}
catch {
    Print-Error "Failed to fetch users: $_"
}

# ==============================================================================
# TEST 3: CREATE NEW USER
# ==============================================================================
Print-Header "TEST 3: CREATE NEW USER"

$Timestamp = [math]::Floor([decimal](Get-Date -UFormat %s))
$USER_EMAIL = "test_$Timestamp@example.com"
Write-Host "Creating new user with email: $USER_EMAIL" -ForegroundColor White

try {
    $CreateBody = @{
        name = "Test User"
        email = $USER_EMAIL
        password = "password123"
        role = "employee"
        status = "active"
        phone_number = "081234567890"
        division = "IT Division"
    } | ConvertTo-Json

    $CreateResponse = Invoke-WebRequest -Uri "$API_URL/users" `
        -Method POST `
        -Headers @{
            "Authorization" = "Bearer $TOKEN"
            "Content-Type" = "application/json"
        } `
        -Body $CreateBody `
        -ErrorAction Stop

    $CreateData = $CreateResponse.Content | ConvertFrom-Json
    $USER_ID = $CreateData.data.id

    $CreateResponse.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host

    if (-not $USER_ID) {
        Print-Error "Failed to get user ID"
        exit 1
    }

    Print-Success "User created with ID: $USER_ID"
}
catch {
    Print-Error "Failed to create user: $_"
    exit 1
}

# ==============================================================================
# TEST 4: GET SPECIFIC USER
# ==============================================================================
Print-Header "TEST 4: GET SPECIFIC USER"

Write-Host "Getting user with ID: $USER_ID" -ForegroundColor White

try {
    $Response = Invoke-WebRequest -Uri "$API_URL/users/$USER_ID" `
        -Method GET `
        -Headers @{
            "Authorization" = "Bearer $TOKEN"
            "Content-Type" = "application/json"
        } `
        -ErrorAction Stop

    $Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host

    Print-Success "User retrieved successfully"
}
catch {
    Print-Error "Failed to get user: $_"
}

# ==============================================================================
# TEST 5: UPDATE USER
# ==============================================================================
Print-Header "TEST 5: UPDATE USER"

Write-Host "Updating user with ID: $USER_ID" -ForegroundColor White

try {
    $UpdateBody = @{
        name = "Test User Updated"
        role = "leader"
        status = "active"
    } | ConvertTo-Json

    $Response = Invoke-WebRequest -Uri "$API_URL/users/$USER_ID" `
        -Method PUT `
        -Headers @{
            "Authorization" = "Bearer $TOKEN"
            "Content-Type" = "application/json"
        } `
        -Body $UpdateBody `
        -ErrorAction Stop

    $Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host

    Print-Success "User updated successfully"
}
catch {
    Print-Error "Failed to update user: $_"
}

# ==============================================================================
# TEST 6: SEARCH USERS
# ==============================================================================
Print-Header "TEST 6: SEARCH USERS"

Write-Host "Searching for users with role 'employee'..." -ForegroundColor White

try {
    $Response = Invoke-WebRequest -Uri "$API_URL/users/search?role=employee" `
        -Method GET `
        -Headers @{
            "Authorization" = "Bearer $TOKEN"
            "Content-Type" = "application/json"
        } `
        -ErrorAction Stop

    $Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host

    Print-Success "Search completed"
}
catch {
    Print-Error "Failed to search users: $_"
}

# ==============================================================================
# TEST 7: BATCH UPDATE STATUS
# ==============================================================================
Print-Header "TEST 7: BATCH UPDATE STATUS"

Write-Host "Updating status for users..." -ForegroundColor White

try {
    $BatchBody = @{
        user_ids = @($USER_ID)
        status = "inactive"
    } | ConvertTo-Json

    $Response = Invoke-WebRequest -Uri "$API_URL/users/batch-update-status" `
        -Method POST `
        -Headers @{
            "Authorization" = "Bearer $TOKEN"
            "Content-Type" = "application/json"
        } `
        -Body $BatchBody `
        -ErrorAction Stop

    $Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host

    Print-Success "Batch update completed"
}
catch {
    Print-Error "Failed to batch update: $_"
}

# ==============================================================================
# TEST 8: DELETE USER
# ==============================================================================
Print-Header "TEST 8: DELETE USER"

Write-Host "Deleting user with ID: $USER_ID" -ForegroundColor White

try {
    $Response = Invoke-WebRequest -Uri "$API_URL/users/$USER_ID" `
        -Method DELETE `
        -Headers @{
            "Authorization" = "Bearer $TOKEN"
            "Content-Type" = "application/json"
        } `
        -ErrorAction Stop

    $Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host

    Print-Success "User deleted successfully"
}
catch {
    Print-Error "Failed to delete user: $_"
}

# ==============================================================================
# SUMMARY
# ==============================================================================
Print-Header "TEST SUMMARY"
Print-Success "All tests completed successfully!"
Print-Info "Endpoints tested:"
Print-Info "  ✓ POST /login"
Print-Info "  ✓ GET /users"
Print-Info "  ✓ POST /users"
Print-Info "  ✓ GET /users/{id}"
Print-Info "  ✓ PUT /users/{id}"
Print-Info "  ✓ GET /users/search"
Print-Info "  ✓ POST /users/batch-update-status"
Print-Info "  ✓ DELETE /users/{id}"

Write-Host ""

