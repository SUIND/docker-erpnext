# ERPNext v15 with Frappe Apps - Docker Setup

**Version:** ERPNext v15  
**Last Updated:** October 27, 2025  
**Platform:** Docker Compose

## Overview

This is a complete ERPNext v15 installation with multiple Frappe apps, running in Docker containers. The setup includes the core ERP system plus additional modules for HR, CRM, support, analytics, and India-specific compliance.

## Installed Applications

### Core System
- **Frappe Framework** - The underlying framework that powers all apps
- **ERPNext v15** - Complete ERP system including:
  - Accounting & Finance
  - Sales & CRM (basic)
  - Buying & Procurement
  - Stock Management
  - Manufacturing
  - Projects
  - Assets
  - And more...

### Additional Apps

1. **HRMS (Human Resources Management System)**
   - Employee lifecycle management
   - Leave and attendance tracking
   - Payroll processing
   - Performance reviews
   - Recruitment and onboarding
   - Expense claims
   - Shift management

2. **CRM (Customer Relationship Management)**
   - Modern, standalone CRM interface
   - Lead and deal management
   - Kanban views
   - Sales pipeline tracking
   - Customer communications
   - Activity timeline

3. **Helpdesk**
   - Customer support ticketing system
   - SLA management
   - Knowledge base integration
   - Multi-channel support
   - Automated workflows
   - Customer portal

4. **Insights**
   - Business Intelligence & Analytics
   - Custom dashboards
   - Visual query builder
   - Charts and reports
   - Data exploration
   - Multiple data source support

5. **Wiki**
   - Knowledge base management
   - Documentation system
   - Version control for articles
   - Search functionality
   - Collaborative editing
   - Public/private wikis

6. **Drive**
   - File management and storage
   - File sharing (internal/external)
   - Folder organization
   - Access controls
   - File versioning
   - Integration with other apps

7. **India Compliance**
   - GST compliance and filing
   - E-Invoicing (IRN generation)
   - E-Waybill generation
   - GSTR reports (GSTR-1, GSTR-3B, etc.)
   - TDS/TCS management
   - India-specific tax rules
   - Regional settings for India

## System Architecture

### Docker Containers

The system runs on the following containers:

- **erpnext-backend** - Gunicorn application server
- **erpnext-frontend** - Nginx web server (reverse proxy)
- **erpnext-db** - MariaDB 10.6 database
- **erpnext-redis-cache** - Redis for caching
- **erpnext-redis-queue** - Redis for job queues
- **erpnext-websocket** - Real-time communication (Socket.IO)
- **erpnext-scheduler** - Background job scheduler
- **erpnext-queue-long** - Worker for long-running jobs
- **erpnext-queue-short** - Worker for short jobs
- **erpnext-configurator** - One-time configuration (auto-exits)
- **erpnext-create-site** - One-time site creation (auto-exits)

### Volumes

- **sites** - All site data, configurations, and files
- **logs** - Application logs
- **db-data** - Database storage
- **redis-queue-data** - Redis persistence

## Access Information

### Web Interface
- **URL:** `http://your-server-ip:9001` (or your configured port)
- **Default Username:** `Administrator`
- **Default Password:** As configured in `.env` file (`APP_PASSWORD`)

### Database Access
- **Host:** `localhost` (from server)
- **Port:** `3306` (exposed on host)
- **Username:** `root`
- **Password:** As configured in `.env` file (`DB_MARIA_PASSWORD`)

## Configuration Files

### Important Files

1. **`.env`** - Environment variables
   - `APP_VERSION=v15` - ERPNext version
   - `APP_NAME=erpnext` - Container prefix
   - `APP_HTTP_PORT=9001` - Web interface port
   - `APP_PASSWORD` - Administrator password
   - `DB_MARIA_PASSWORD` - Database password
   - `DB_MARIA_PORT=3306` - Database port
   - `APP_NETWORK=websoft9` - Docker network name

2. **`Dockerfile`** - Custom image build
   - Extends official `frappe/erpnext:v15` image
   - Installs all additional apps
   - Installs Python dependencies

3. **`docker-compose.yml`** - Container orchestration
   - Defines all services
   - Volume mappings
   - Network configuration
   - Environment variables

4. **`install-hrms.sh`** - Manual app installation script
   - For adding apps to existing installations
   - Run only if needed

## Management Commands

### Starting the System
```bash
docker compose up -d
```

### Stopping the System
```bash
docker compose down
```

### Viewing Logs
```bash
# All containers
docker compose logs -f

# Specific container
docker logs -f erpnext-backend
docker logs -f erpnext-create-site
```

### Accessing Container Shell
```bash
docker exec -it erpnext-backend bash
```

### Running Bench Commands
```bash
# From inside the container
docker exec -it erpnext-backend bash
cd /home/frappe/frappe-bench
bench --site frontend [command]

# Examples:
bench --site frontend migrate
bench --site frontend clear-cache
bench --site frontend backup
bench --site frontend console
```

### Database Backup
```bash
# Create backup
docker exec erpnext-backend bench --site frontend backup --with-files

# Backups are stored in:
# /home/frappe/frappe-bench/sites/frontend/private/backups/
```

### Rebuilding After Changes
```bash
# Clean rebuild (deletes all data!)
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

## Maintenance

### Updating Apps

To update to newer versions, modify the `APP_VERSION` in `.env` and rebuild:

```bash
# Update .env file
APP_VERSION=v15.x.x

# Rebuild and restart
docker compose down
docker compose build --pull
docker compose up -d
```

### Adding More Apps

1. Edit `Dockerfile` to add new app cloning and pip install
2. Edit `docker-compose.yml` create-site command to include `--install-app [app_name]`
3. Rebuild the image

### Removing Apps

Apps cannot be easily removed once installed. It's recommended to:
1. Backup your data
2. Create a fresh installation without the unwanted app
3. Restore data if needed

## Troubleshooting

### Site Not Accessible
```bash
# Check container status
docker compose ps

# Check frontend logs
docker logs erpnext-frontend

# Check backend logs
docker logs erpnext-backend
```

### Database Connection Issues
```bash
# Check database is running
docker exec erpnext-db mysqladmin ping -h localhost -p

# Check site config
docker exec erpnext-backend cat sites/frontend/site_config.json
```

### Worker Queue Issues
```bash
# Check queue workers
docker logs erpnext-queue-long
docker logs erpnext-queue-short

# Clear failed jobs
docker exec erpnext-backend bench --site frontend clear-cache
```

### Reinstall Site (Caution: Data Loss!)
```bash
# This will delete all data!
docker exec erpnext-backend bench drop-site frontend --force
docker exec erpnext-backend bench new-site frontend --admin-password=yourpassword --install-app erpnext
```

## File Locations

### In Container Paths
- **Bench Directory:** `/home/frappe/frappe-bench`
- **Sites:** `/home/frappe/frappe-bench/sites`
- **Apps:** `/home/frappe/frappe-bench/apps`
- **Site Config:** `/home/frappe/frappe-bench/sites/frontend/site_config.json`
- **Common Config:** `/home/frappe/frappe-bench/sites/common_site_config.json`
- **Backups:** `/home/frappe/frappe-bench/sites/frontend/private/backups`
- **Logs:** `/home/frappe/frappe-bench/logs`

### On Host (via Docker Volumes)
```bash
# Find volume location
docker volume inspect docker-erpnext_sites
```

## Network Architecture

- All containers run on external network: `websoft9`
- Frontend exposed on port: `9001` (configurable)
- Database exposed on port: `3306` (configurable)
- Internal services communicate via Docker network

## Security Notes

1. **Change Default Passwords** - Update `APP_PASSWORD` and `DB_MARIA_PASSWORD` in `.env`
2. **Firewall** - Restrict access to ports 9001 and 3306
3. **HTTPS** - Consider adding SSL/TLS (Cloudflare tunnel is configured but token needed)
4. **Backups** - Regular automated backups recommended
5. **Updates** - Keep ERPNext and apps updated for security patches

## Performance Tuning

### For Production Use:
1. Increase worker processes in gunicorn (backend)
2. Add more queue workers if needed
3. Optimize MariaDB settings based on available RAM
4. Enable Redis persistence if required
5. Set up proper monitoring (Prometheus, Grafana)

## Support and Documentation

- **ERPNext Docs:** https://docs.erpnext.com
- **Frappe Framework:** https://frappeframework.com/docs
- **Community Forum:** https://discuss.frappe.io
- **GitHub Issues:** https://github.com/frappe/erpnext/issues

## App-Specific Documentation

- **HRMS:** https://github.com/frappe/hrms
- **CRM:** https://github.com/frappe/crm
- **Helpdesk:** https://github.com/frappe/helpdesk
- **Insights:** https://github.com/frappe/insights
- **Wiki:** https://github.com/frappe/wiki
- **Drive:** https://github.com/frappe/drive
- **India Compliance:** https://github.com/resilient-tech/india-compliance

## License

ERPNext and Frappe apps are licensed under GNU GPL v3.0

---

**Note:** This setup is production-ready but should be reviewed and hardened based on your specific security and performance requirements.
