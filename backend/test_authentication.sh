#!/bin/bash

# Security Test Script for Authentication Implementation
# This script tests that the authentication fix properly blocks unauthenticated access

BASE_URL="https://app.efficientgroupdubai.com"
COOKIE_FILE="test_cookies.txt"

echo "=========================================="
echo "Authentication Security Test"
echo "=========================================="
echo ""

# Test 1: Unauthenticated access to get_guests (should fail with 401)
echo "Test 1: Attempting unauthenticated access to get_guests endpoint..."
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/backend/api/manage_guests.php?action=get_guests")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "401" ]; then
    echo "✓ PASS: Endpoint correctly returns 401 Unauthorized"
    echo "  Response: $BODY"
else
    echo "✗ FAIL: Expected 401, got $HTTP_CODE"
    echo "  Response: $BODY"
fi
echo ""

# Test 2: Unauthenticated access with bed_space_id parameter (should fail with 401)
echo "Test 2: Attempting unauthenticated access with bed_space_id parameter..."
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/backend/api/manage_guests.php?action=get_guests&bed_space_id=1")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "401" ]; then
    echo "✓ PASS: Endpoint correctly returns 401 Unauthorized"
    echo "  Response: $BODY"
else
    echo "✗ FAIL: Expected 401, got $HTTP_CODE"
    echo "  Response: $BODY"
fi
echo ""

# Test 3: Login with valid credentials
echo "Test 3: Attempting login with credentials..."
RESPONSE=$(curl -s -c "$COOKIE_FILE" -w "\nHTTP_CODE:%{http_code}" \
    -X POST "${BASE_URL}/backend/login.php" \
    -d "username=admin&password=admin123")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "200" ] && echo "$BODY" | grep -q "success"; then
    echo "✓ PASS: Login successful"
    echo "  Response: $BODY"
else
    echo "✗ FAIL: Login failed"
    echo "  Response: $BODY"
    echo "  Note: Make sure admin_users table exists and default credentials are set"
fi
echo ""

# Test 4: Authenticated access to get_guests (should succeed)
echo "Test 4: Attempting authenticated access to get_guests endpoint..."
RESPONSE=$(curl -s -b "$COOKIE_FILE" -w "\nHTTP_CODE:%{http_code}" \
    "${BASE_URL}/backend/api/manage_guests.php?action=get_guests")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "200" ] && echo "$BODY" | grep -q "success"; then
    echo "✓ PASS: Authenticated request successful"
    echo "  Response: $BODY"
else
    echo "✗ FAIL: Authenticated request failed"
    echo "  Response: $BODY"
fi
echo ""

# Test 5: Test other protected endpoints
echo "Test 5: Testing other protected endpoints without authentication..."

ENDPOINTS=(
    "manage_flats.php?action=get_flats"
    "manage_rooms.php?action=get_rooms"
    "manage_bed_spaces.php?action=get_bed_spaces"
    "manage_rental_records.php?action=get_rental_records"
    "manage_owners.php?action=get_re_owners"
)

for endpoint in "${ENDPOINTS[@]}"; do
    RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/backend/api/${endpoint}")
    HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
    
    if [ "$HTTP_CODE" = "401" ]; then
        echo "  ✓ $endpoint - Correctly protected"
    else
        echo "  ✗ $endpoint - NOT protected (HTTP $HTTP_CODE)"
    fi
done
echo ""

# Test 6: Dashboard stats endpoint
echo "Test 6: Testing dashboard stats endpoint without authentication..."
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/backend/get_dashboard_stats.php")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)

if [ "$HTTP_CODE" = "401" ]; then
    echo "✓ PASS: Dashboard stats correctly protected"
else
    echo "✗ FAIL: Dashboard stats NOT protected (HTTP $HTTP_CODE)"
fi
echo ""

# Cleanup
rm -f "$COOKIE_FILE"

echo "=========================================="
echo "Test Complete"
echo "=========================================="
echo ""
echo "Summary:"
echo "- All API endpoints should return 401 without authentication"
echo "- Login should succeed with valid credentials"
echo "- Authenticated requests should succeed with session cookie"
echo ""
echo "If any tests failed, review the implementation and ensure:"
echo "1. auth_helper.php is properly included in all API files"
echo "2. require_authentication() is called before processing requests"
echo "3. admin_users table exists with valid credentials"
echo "4. PHP sessions are properly configured"
