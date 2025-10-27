#!/bin/bash
# Script to install Frappe HR (HRMS) on existing ERPNext installation

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

APP_NAME=${APP_NAME:-erpnext}
SITE_NAME=${SITE_NAME:-frontend}

echo "Installing Frappe HR (HRMS) on existing site..."
echo "Container: ${APP_NAME}-backend"
echo "Site: ${SITE_NAME}"
echo ""

# Get the HRMS app
echo "Step 1: Downloading HRMS app..."
docker exec -it ${APP_NAME}-backend bench get-app hrms

# Install HRMS on the site
echo "Step 2: Installing HRMS on site ${SITE_NAME}..."
docker exec -it ${APP_NAME}-backend bench --site ${SITE_NAME} install-app hrms

# Migrate the site
echo "Step 3: Running migrations..."
docker exec -it ${APP_NAME}-backend bench --site ${SITE_NAME} migrate

# Clear cache
echo "Step 4: Clearing cache..."
docker exec -it ${APP_NAME}-backend bench --site ${SITE_NAME} clear-cache

echo ""
echo "✓ Frappe HR (HRMS) has been successfully installed!"
echo "Please restart your ERPNext containers:"
echo "  docker-compose restart"
