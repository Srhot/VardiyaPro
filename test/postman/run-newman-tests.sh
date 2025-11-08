#!/bin/bash

# Newman Test Runner Script for VardiyaPro API
# This script runs the Postman collection using Newman CLI and generates reports

echo "🚀 Starting Newman API Tests..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create reports directory if it doesn't exist
mkdir -p test/postman/reports

# Check if newman is installed
if ! command -v newman &> /dev/null; then
    echo -e "${RED}❌ Newman is not installed!${NC}"
    echo ""
    echo "Install Newman globally with:"
    echo "  npm install -g newman"
    echo "  npm install -g newman-reporter-html"
    echo ""
    exit 1
fi

# Check if server is running
echo "📡 Checking if Rails server is running..."
if ! curl -s http://localhost:3000/up > /dev/null 2>&1; then
    echo -e "${RED}❌ Rails server is not running!${NC}"
    echo ""
    echo "Start the server with:"
    echo "  bundle exec rails server"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Rails server is running${NC}"
echo ""

# Run Newman tests with multiple reporters
echo "🧪 Running Newman tests..."
echo ""

newman run test/postman/collections/VardiyaPro_Complete_v3.postman_collection.json \
  --environment test/postman/environments/VardiyaPro_Environment_Dev.json \
  --reporters cli,json,html \
  --reporter-json-export test/postman/reports/newman-report.json \
  --reporter-html-export test/postman/reports/newman-report.html \
  --bail \
  --color on \
  --delay-request 100 \
  --timeout-request 10000

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo ""
    echo "📊 Reports generated:"
    echo "  - JSON: test/postman/reports/newman-report.json"
    echo "  - HTML: test/postman/reports/newman-report.html"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Some tests failed!${NC}"
    echo ""
    echo "Check the reports for details:"
    echo "  - JSON: test/postman/reports/newman-report.json"
    echo "  - HTML: test/postman/reports/newman-report.html"
    echo ""
    exit 1
fi
