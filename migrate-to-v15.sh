#!/bin/bash
# Script to migrate ERPNext from v14 to v15 and install HRMS

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

APP_NAME=${APP_NAME:-erpnext}
SITE_NAME=${SITE_NAME:-frontend}

echo "==================================="
echo "ERPNext v14 to v15 Migration + HRMS"
echo "==================================="
echo "Container: ${APP_NAME}-backend"
echo "Site: ${SITE_NAME}"
echo ""
echo "WARNING: This will upgrade your ERPNext installation from v14 to v15."
echo "Make sure you have a backup of your database and files!"
echo ""
read -p "Do you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Migration cancelled."
    exit 0
fi

echo ""
echo "Step 1: Creating backup..."
docker exec ${APP_NAME}-backend bench --site ${SITE_NAME} backup --with-files

echo ""
echo "Step 2: Stopping all containers..."
docker-compose down

echo ""
echo "Step 3: Building v15 image with HRMS..."
docker-compose build --pull

echo ""
echo "Step 4: Starting containers with v15..."
docker-compose up -d

echo ""
echo "Step 5: Waiting for services to be ready (60 seconds)..."
sleep 60

echo ""
echo "Step 6: Running migrate to upgrade to v15..."
docker exec ${APP_NAME}-backend bench --site ${SITE_NAME} migrate

echo ""
echo "Step 7: Installing HRMS app..."
docker exec ${APP_NAME}-backend bench --site ${SITE_NAME} install-app hrms

echo ""
echo "Step 8: Running final migration..."
docker exec ${APP_NAME}-backend bench --site ${SITE_NAME} migrate

echo ""
echo "Step 9: Clearing cache..."
docker exec ${APP_NAME}-backend bench --site ${SITE_NAME} clear-cache

echo ""
echo "Step 10: Rebuilding assets..."
docker exec ${APP_NAME}-backend bench --site ${SITE_NAME} build

echo ""
echo "✓ Migration completed successfully!"
echo ""
echo "Your ERPNext has been upgraded to v15 with HRMS installed."
echo "Please check your site and verify everything is working correctly."
echo ""
echo "Backups are located in the sites/${SITE_NAME}/private/backups/ directory."
