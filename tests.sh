#!/bin/zsh

# WireMock API Tests
# This script tests all WireMock mappings to ensure they're functioning properly

# Configuration
BASE_URL="http://localhost:8081"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo "\n${BLUE}========================================${NC}"
    echo "${BLUE}$1${NC}"
    echo "${BLUE}========================================${NC}\n"
}

# Function to print test results
print_result() {
    local test_name=$1
    local expected_status=$2
    local actual_status=$3
    
    if [ "$actual_status" -eq "$expected_status" ]; then
        echo "${GREEN}✓ PASS${NC} - $test_name (Status: $actual_status)"
    else
        echo "${RED}✗ FAIL${NC} - $test_name (Expected: $expected_status, Got: $actual_status)"
    fi
}

echo "${YELLOW}Starting WireMock API Tests...${NC}"
echo "Base URL: ${BASE_URL}"

# Test 1: Health Check
print_header "Test 1: Health Check Endpoint"
echo "Request: GET ${BASE_URL}/api/health"
response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/api/health")
http_status=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')
echo "Response Body:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"
print_result "Health Check" 200 "$http_status"

# Test 2: Get All Accounts
print_header "Test 2: Get All Accounts"
echo "Request: GET ${BASE_URL}/api/accounts"
response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/api/accounts")
http_status=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')
echo "Response Body:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"
print_result "Get All Accounts" 200 "$http_status"

# Test 3: Get Single Account by UUID
print_header "Test 3: Get Single Account by UUID"
UUID="f396a966-5eea-43d4-bd6a-1b44a2a16d9c"
echo "Request: GET ${BASE_URL}/api/accounts/${UUID}"
response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/api/accounts/${UUID}")
http_status=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')
echo "Response Body:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"
print_result "Get Single Account" 200 "$http_status"

# Test 4: Get Another Single Account (with different UUID)
print_header "Test 4: Get Another Single Account"
UUID="9dfc7e64-fefd-4ca9-afa8-b2589450438e"
echo "Request: GET ${BASE_URL}/api/accounts/${UUID}"
response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/api/accounts/${UUID}")
http_status=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')
echo "Response Body:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"
print_result "Get Another Single Account" 200 "$http_status"

# Test 5: Create New Account (Valid)
print_header "Test 5: Create New Account (Valid Request)"
echo "Request: POST ${BASE_URL}/api/accounts"
echo "Request Body: {\"name\": \"John\", \"lastName\": \"Smith\"}"
response=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{"name": "John", "lastName": "Smith"}' \
    "${BASE_URL}/api/accounts")
http_status=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')
echo "Response Body:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"
print_result "Create Account (Valid)" 201 "$http_status"

# Test 6: Create Account with Missing Required Field
print_header "Test 6: Create Account (Missing Required Field)"
echo "Request: POST ${BASE_URL}/api/accounts"
echo "Request Body: {\"name\": \"John\"} (missing lastName)"
response=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{"name": "John"}' \
    "${BASE_URL}/api/accounts")
http_status=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')
echo "Response Body:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"
# This should fail validation and return 404 (falls through to default mapping)
print_result "Create Account (Invalid - Missing Field)" 404 "$http_status"

# Test 7: Create Account without Content-Type Header
print_header "Test 7: Create Account (Missing Content-Type Header)"
echo "Request: POST ${BASE_URL}/api/accounts (without Content-Type header)"
response=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Accept: application/json" \
    -d '{"name": "John", "lastName": "Smith"}' \
    "${BASE_URL}/api/accounts")
http_status=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')
echo "Response Body:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"
# Should fail header match and return 404
print_result "Create Account (Invalid - No Content-Type)" 404 "$http_status"

# Test 8: Invalid Endpoint (404 Handler)
print_header "Test 8: Invalid Endpoint (Default 404 Handler)"
echo "Request: GET ${BASE_URL}/api/nonexistent"
response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/api/nonexistent")
http_status=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')
echo "Response Body:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"
print_result "Invalid Endpoint (404)" 404 "$http_status"

# Test 9: GET Account with Invalid UUID Format
print_header "Test 9: GET Account with Invalid UUID Format"
echo "Request: GET ${BASE_URL}/api/accounts/invalid-uuid"
response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/api/accounts/invalid-uuid")
http_status=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')
echo "Response Body:"
echo "$body" | jq '.' 2>/dev/null || echo "$body"
print_result "Invalid UUID Format (404)" 404 "$http_status"

# Test 10: Check Response Headers
print_header "Test 10: Verify Response Headers"
echo "Request: GET ${BASE_URL}/api/accounts (checking headers)"
response=$(curl -s -i "${BASE_URL}/api/accounts")
echo "$response"
if echo "$response" | grep -q "Content-Type: application/json"; then
    echo "${GREEN}✓ PASS${NC} - Content-Type header is correct"
else
    echo "${RED}✗ FAIL${NC} - Content-Type header is missing or incorrect"
fi

# Test 11: Check Location Header on POST
print_header "Test 11: Verify Location Header on POST"
echo "Request: POST ${BASE_URL}/api/accounts (checking Location header)"
response=$(curl -s -i \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{"name": "Test", "lastName": "User"}' \
    "${BASE_URL}/api/accounts")
echo "$response"
if echo "$response" | grep -q "Location: /api/accounts/"; then
    echo "${GREEN}✓ PASS${NC} - Location header is present"
else
    echo "${RED}✗ FAIL${NC} - Location header is missing"
fi

# Summary
print_header "Test Summary"
echo "${YELLOW}All WireMock mapping tests completed!${NC}"
echo "\nTested mappings:"
echo "  ✓ Health check endpoint"
echo "  ✓ Get all accounts"
echo "  ✓ Get single account by UUID"
echo "  ✓ Create account (valid)"
echo "  ✓ Create account (validation failures)"
echo "  ✓ Default 404 handler"
echo "  ✓ Response headers"
echo "\n${BLUE}Note:${NC} Make sure WireMock is running on ${BASE_URL}"
echo "Run './mock_local.sh' or './podman_run.sh' to start WireMock\n"