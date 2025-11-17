#!/bin/bash

# NRO Offline Server - Configuration Test Script

# Run this before deployment to verify your setup

 

set -e

 

# Colors

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[1;33m'

BLUE='\033[0;34m'

NC='\033[0m'

 

TESTS_PASSED=0

TESTS_FAILED=0

 

print_test() {

    echo -e "${BLUE}[TEST]${NC} $1"

}

 

pass() {

    echo -e "${GREEN}  ✅ PASS:${NC} $1"

    TESTS_PASSED=$((TESTS_PASSED + 1))

}

 

fail() {

    echo -e "${RED}  ❌ FAIL:${NC} $1"

    TESTS_FAILED=$((TESTS_FAILED + 1))

}

 

warn() {

    echo -e "${YELLOW}  ⚠️  WARN:${NC} $1"

}

 

echo -e "${BLUE}========================================${NC}"

echo -e "${BLUE}  NRO Server - Configuration Tests${NC}"

echo -e "${BLUE}========================================${NC}\n"

 

# Test 1: Docker installed

print_test "Checking Docker installation"

if command -v docker &> /dev/null; then

    DOCKER_VERSION=$(docker --version)

    pass "Docker is installed: $DOCKER_VERSION"

else

    fail "Docker is not installed"

fi

 

# Test 2: Docker Compose installed

print_test "Checking Docker Compose installation"

if command -v docker-compose &> /dev/null; then

    COMPOSE_VERSION=$(docker-compose --version)

    pass "Docker Compose is installed: $COMPOSE_VERSION"

elif docker compose version &> /dev/null; then

    COMPOSE_VERSION=$(docker compose version)

    pass "Docker Compose (plugin) is installed: $COMPOSE_VERSION"

    warn "Using 'docker compose' (plugin) instead of 'docker-compose'"

else

    fail "Docker Compose is not installed"

fi

 

# Test 3: Docker daemon running

print_test "Checking Docker daemon status"

if docker info &> /dev/null; then

    pass "Docker daemon is running"

else

    fail "Docker daemon is not running"

fi

 

# Test 4: Current user in docker group

print_test "Checking Docker permissions"

if groups | grep -q docker; then

    pass "Current user is in docker group"

else

    warn "Current user is not in docker group - may need sudo"

    echo "     Run: sudo usermod -aG docker $USER"

fi

 

# Test 5: Check required files

print_test "Checking required files"

REQUIRED_FILES=(

    "docker-compose.yml"

    "Dockerfile"

    "docker-entrypoint.sh"

    "nro_deobfuscated.py"

    ".env.example"

)

 

for file in "${REQUIRED_FILES[@]}"; do

    if [ -f "$file" ]; then

        pass "Found: $file"

    else

        fail "Missing: $file"

    fi

done

 

# Test 6: Check docker-compose.yml syntax

print_test "Validating docker-compose.yml syntax"

if docker-compose config > /dev/null 2>&1; then

    pass "docker-compose.yml syntax is valid"

elif docker compose config > /dev/null 2>&1; then

    pass "docker-compose.yml syntax is valid"

else

    fail "docker-compose.yml has syntax errors"

    echo "     Run: docker-compose config"

fi

 

# Test 7: Check for selfnet network

print_test "Checking for selfnet Docker network"

if docker network ls | grep -q selfnet; then

    pass "selfnet network exists"

else

    warn "selfnet network does not exist (will be created)"

    echo "     Run: docker network create selfnet"

fi

 

# Test 8: Check environment variables

print_test "Checking environment variables"

ENV_FILE="$HOME/Desktop/selthost/.env"

 

if [ -f "$ENV_FILE" ]; then

    pass "Found .env file at $ENV_FILE"

 

    if grep -q "PUID" "$ENV_FILE"; then

        pass "PUID is configured"

    else

        warn "PUID not found in .env"

    fi

 

    if grep -q "PGID" "$ENV_FILE"; then

        pass "PGID is configured"

    else

        warn "PGID not found in .env"

    fi

 

    if grep -q "TZ" "$ENV_FILE"; then

        pass "TZ (timezone) is configured"

    else

        warn "TZ not found in .env"

    fi

 

    if grep -q "NRO_MYSQL_ROOT_PASSWORD" "$ENV_FILE"; then

        pass "NRO_MYSQL_ROOT_PASSWORD is configured"

    else

        warn "NRO_MYSQL_ROOT_PASSWORD not found in .env"

        echo "     Will be generated during deployment"

    fi

 

    if grep -q "NRO_MYSQL_PASSWORD" "$ENV_FILE"; then

        pass "NRO_MYSQL_PASSWORD is configured"

    else

        warn "NRO_MYSQL_PASSWORD not found in .env"

        echo "     Will be generated during deployment"

    fi

else

    warn ".env file not found at $ENV_FILE"

    echo "     Will be created during deployment"

fi

 

# Test 9: Check available disk space

print_test "Checking available disk space"

AVAILABLE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')

if [ "$AVAILABLE" -ge 5 ]; then

    pass "Sufficient disk space: ${AVAILABLE}GB available"

else

    warn "Low disk space: only ${AVAILABLE}GB available (recommend 5GB+)"

fi

 

# Test 10: Check available memory

print_test "Checking available memory"

AVAILABLE_MEM=$(free -g | grep Mem | awk '{print $7}')

if [ "$AVAILABLE_MEM" -ge 2 ]; then

    pass "Sufficient memory: ${AVAILABLE_MEM}GB available"

else

    warn "Low memory: only ${AVAILABLE_MEM}GB available (recommend 2GB+)"

fi

 

# Test 11: Check port availability

print_test "Checking port availability"

if command -v netstat &> /dev/null; then

    if netstat -tuln | grep -q ":14445 "; then

        warn "Port 14445 is already in use"

    else

        pass "Port 14445 is available"

    fi

 

    if netstat -tuln | grep -q ":14444 "; then

        warn "Port 14444 is already in use"

    else

        pass "Port 14444 is available"

    fi

else

    warn "netstat not available, skipping port check"

fi

 

# Test 12: Check Dockerfile syntax

print_test "Checking Dockerfile"

if [ -f "Dockerfile" ]; then

    if docker build --no-cache -f Dockerfile -t nro-test . > /dev/null 2>&1; then

        pass "Dockerfile builds successfully"

        docker rmi nro-test > /dev/null 2>&1 || true

    else

        warn "Dockerfile may have issues (test build failed)"

    fi

else

    fail "Dockerfile not found"

fi

 

# Summary

echo ""

echo -e "${BLUE}========================================${NC}"

echo -e "${BLUE}         Test Results Summary${NC}"

echo -e "${BLUE}========================================${NC}"

echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"

echo -e "${RED}Failed: $TESTS_FAILED${NC}"

 

if [ $TESTS_FAILED -eq 0 ]; then

    echo ""

    echo -e "${GREEN}✅ All critical tests passed!${NC}"

    echo -e "${GREEN}You're ready to deploy.${NC}"

    echo ""

    echo "Run the deployment script:"

    echo -e "${BLUE}./deploy.sh${NC}"

    exit 0

else

    echo ""

    echo -e "${RED}❌ Some tests failed.${NC}"

    echo "Please fix the issues above before deploying."

    exit 1

fi

 