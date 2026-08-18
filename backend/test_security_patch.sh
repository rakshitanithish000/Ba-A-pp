#!/bin/bash
# Security Patch Verification Test Script
# This script demonstrates that the vulnerability has been mitigated

echo "=========================================="
echo "Security Patch Verification Test"
echo "=========================================="
echo ""

# Configuration
BASE_URL="http://localhost/backend"
API_URL="$BASE_URL/api/manage_owners.php"
LOGIN_URL="$BASE_URL/login.php"

echo "Testing vulnerability mitigation..."
echo ""

# Test 1: Attempt unauthenticated delete (should fail with 401)
echo "Test 1: Unauthenticated delete_lease_owner request"
echo "Expected: 401 Unauthorized"
echo "Command: curl -s -w '\\nHTTP Status: %{http_code}\\n' -X POST '$API_URL?action=delete_lease_owner' -d 'id=1'"
echo ""
response=$(curl -s -w '\nHTTP Status: %{http_code}\n' -X POST "$API_URL?action=delete_lease_owner" -d "id=1")
echo "$response"
echo ""

if echo "$response" | grep -q "401"; then
    echo "✅ PASS: Unauthenticated request blocked"
else
    echo "❌ FAIL: Unauthenticated request not blocked"
fi
echo ""
echo "=========================================="
echo ""

# Test 2: Attempt unauthenticated read (should fail with 401)
echo "Test 2: Unauthenticated get_lease_owners request"
echo "Expected: 401 Unauthorized"
echo "Command: curl -s -w '\\nHTTP Status: %{http_code}\\n' -X GET '$API_URL?action=get_lease_owners'"
echo ""
response=$(curl -s -w '\nHTTP Status: %{http_code}\n' -X GET "$API_URL?action=get_lease_owners")
echo "$response"
echo ""

if echo "$response" | grep -q "401"; then
    echo "✅ PASS: Unauthenticated request blocked"
else
    echo "❌ FAIL: Unauthenticated request not blocked"
fi
echo ""
echo "=========================================="
echo ""

# Test 3: Login and authenticated request (should succeed)
echo "Test 3: Authenticated request after login"
echo "Step 1: Login"
echo "Command: curl -s -c cookies.txt -X POST '$LOGIN_URL' -d 'username=admin&password=admin123'"
echo ""
login_response=$(curl -s -c /tmp/test_cookies.txt -X POST "$LOGIN_URL" -d "username=admin&password=admin123")
echo "$login_response"
echo ""

if echo "$login_response" | grep -q "success"; then
    echo "✅ Login successful"
    echo ""
    echo "Step 2: Authenticated request"
    echo "Command: curl -s -b cookies.txt -X GET '$API_URL?action=get_lease_owners'"
    echo ""
    auth_response=$(curl -s -b /tmp/test_cookies.txt -X GET "$API_URL?action=get_lease_owners")
    echo "$auth_response"
    echo ""
    
    if echo "$auth_response" | grep -q "success"; then
        echo "✅ PASS: Authenticated request succeeded"
    else
        echo "❌ FAIL: Authenticated request failed"
    fi
else
    echo "❌ Login failed (check credentials)"
fi
echo ""
echo "=========================================="
echo ""

# Cleanup
rm -f /tmp/test_cookies.txt

echo "Test Summary:"
echo "-------------"
echo "The vulnerability has been mitigated if:"
echo "1. Unauthenticated delete requests return 401 Unauthorized"
echo "2. Unauthenticated read requests return 401 Unauthorized"
echo "3. Authenticated requests succeed after valid login"
echo ""
echo "All API endpoints now require authentication before processing requests."
echo "The delete_lease_owner action can only be executed by authenticated users."
echo ""
