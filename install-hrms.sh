#!/bin/bash
# Script to install Frappe HR (HRMS) on existing ERPNext installation

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

APP_NAME=${APP_NAME:-erpnext}
SITE_NAME=${SITE_NAME:-frontend}

echo "Installing Frappe HR (HRMS) on existing ERPNext site..."
echo "Container: ${APP_NAME}-backend"
echo "Site: ${SITE_NAME}"
echo ""

# Install HRMS on the site
echo "Step 1: Installing HRMS app on site ${SITE_NAME}..."
docker exec ${APP_NAME}-backend bench --site ${SITE_NAME} install-app hrms

# Migrate the site
echo "Step 2: Running migrations..."
docker exec ${APP_NAME}-backend bench --site ${SITE_NAME} migrate

# Clear cache
echo "Step 3: Clearing cache..."
docker exec ${APP_NAME}-backend bench --site ${SITE_NAME} clear-cache

echo ""
echo "✓ Frappe HR (HRMS) has been successfully installed!"
echo "You may need to refresh your browser to see the HR module."
