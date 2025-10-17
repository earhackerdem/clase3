# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Laravel 12 application running in a fully Dockerized environment with PostgreSQL 16, Redis, and Nginx. The setup is optimized for development with hot-reload, Xdebug support, and comprehensive Make commands.

## Development Environment

### Docker Architecture

The project uses Docker Compose with 7 services:
- **web**: Nginx (port 8000) - serves the application
- **php-fpm**: PHP 8.2-FPM with MySQL, PostgreSQL, Redis extensions, and Xdebug
- **workspace**: PHP 8.2 CLI with Composer, Node.js 22 (via NVM), and development tools
- **mysql**: MySQL 8.4 LTS (port 3306) - **default database**
- **postgres**: PostgreSQL 16 (port 5432) - alternative database
- **redis**: Redis Alpine (port 6379) - cache, sessions, and queues
- **phpmyadmin**: phpMyAdmin (port 8080) - MySQL web interface

All services communicate over the `laravel-development` bridge network using service names (e.g., `mysql:3306`, `postgres:5432`, `redis:6379`).

### Key Files
- `compose.dev.yaml` - Docker Compose configuration for development
- `Makefile` - Contains all common development commands
- `docker-setup.sh` - Automated initial setup script
- `.env` - Environment configuration (created from `.env.example`)

## Common Commands

### Starting and Stopping

```bash
# Start all containers
make up

# Stop containers
make down

# Restart containers
make restart

# View container status
make ps

# View logs in real-time
make logs
```

### Development Workflow

```bash
# Access the workspace container (for CLI work)
make shell

# Run Artisan commands
make artisan CMD="migrate"
make artisan CMD="make:model Product -mc"

# Run Composer commands
make composer CMD="require package/name"

# Run npm commands (automatically sources NVM)
make npm CMD="install"
make npm CMD="run dev"

# Run tests
make test

# Clear all caches
make clear
```

### Database Operations

```bash
# Run migrations
make migrate

# Rollback last migration
make rollback

# Refresh database (drops all tables and re-runs migrations)
make fresh

# Refresh database and run seeders
make fresh-seed

# Run seeders only
make seed

# Access MySQL CLI (default database)
make mysql-shell

# View slow query log (queries > 1 second)
make mysql-slow

# View MySQL performance statistics
make mysql-perf

# Access PostgreSQL CLI (alternative database)
make db-shell
```

### Running Tests

Tests use SQLite in-memory database (configured in `phpunit.xml`). To run a specific test:

```bash
# Run all tests
make test

# Run specific test file (from within workspace)
docker compose -f compose.dev.yaml exec -u www workspace php artisan test --filter=UserTest

# Run specific test method
docker compose -f compose.dev.yaml exec -u www workspace php artisan test --filter=test_user_can_login
```

### Asset Compilation

Frontend assets use Vite. Node.js commands must be run inside the workspace container with NVM:

```bash
# Build for production
make npm CMD="run build"

# Development mode (watch)
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm run dev"

# Install dependencies
make npm CMD="install"
```

## Database Configuration

The application has **two databases available**: MySQL (default) and PostgreSQL. Never use SQLite in development (only for tests).

### MySQL Configuration (Default Database)

**Recommended for this project.** MySQL 8.4 LTS with optimized configuration, slow query logging, and Performance Schema enabled.

#### Connection Details

From Laravel (`.env`):
```
DB_CONNECTION=mysql
DB_HOST=mysql             # Docker service name, not localhost
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
```

From host machine (MySQL Workbench, DBeaver, or phpMyAdmin):
```
Host: localhost
Port: 3306
Database: laravel
User: laravel
Password: secret

# For administrative tasks
Root Password: root_secret
```

#### phpMyAdmin Access

Web interface for MySQL management:
- **URL**: http://localhost:8080
- **Server**: mysql
- **Username**: root
- **Password**: root_secret

#### Performance Monitoring

MySQL is configured with advanced monitoring features:

1. **Slow Query Log**: Automatically logs queries taking more than 1 second
   - Location: `storage/logs/mysql/mysql-slow.log`
   - View: `make mysql-slow`
   - Includes queries not using indexes

2. **Performance Schema**: Enabled for detailed query analysis
   - View top slow queries: `make mysql-perf`
   - Analyze query performance, resource usage, and bottlenecks
   - Full access via MySQL CLI or phpMyAdmin

3. **Custom Configuration**: `docker/development/mysql/my.cnf`
   - Optimized buffer pool size (256M)
   - InnoDB optimizations
   - UTF8mb4 by default
   - Query optimization settings

### PostgreSQL Configuration (Alternative Database)

PostgreSQL 16 is available but not the default. To switch to PostgreSQL:

1. Update `.env`:
   ```
   DB_CONNECTION=pgsql
   DB_HOST=postgres
   DB_PORT=5432
   DB_DATABASE=laravel
   DB_USERNAME=laravel
   DB_PASSWORD=secret
   ```

2. Run migrations: `make fresh`

#### Connection Details

From host machine (pgAdmin, DBeaver):
```
Host: localhost
Port: 5432
Database: laravel
User: laravel
Password: secret
```

### Switching Between Databases

The project maintains both MySQL and PostgreSQL configurations. To switch:

1. **To MySQL** (default):
   ```bash
   # Update DB_CONNECTION in .env
   DB_CONNECTION=mysql
   DB_HOST=mysql
   DB_PORT=3306

   # Refresh migrations
   make fresh
   ```

2. **To PostgreSQL**:
   ```bash
   # Update DB_CONNECTION in .env
   DB_CONNECTION=pgsql
   DB_HOST=postgres
   DB_PORT=5432

   # Refresh migrations
   make fresh
   ```

### Database CLI Access

```bash
# MySQL (default)
make mysql-shell

# PostgreSQL (alternative)
make db-shell
```

## Architecture Patterns

### Standard Laravel Structure

- **Controllers**: `app/Http/Controllers/` - Keep thin, delegate to services
- **Models**: `app/Models/` - Eloquent models with relationships
- **Migrations**: `database/migrations/` - All database schema changes
- **Seeders**: `database/seeders/` - Test data generation
- **Factories**: `database/factories/` - Model factories for testing
- **Requests**: `app/Http/Requests/` - Form validation
- **Resources**: `app/Http/Resources/` - API response transformation
- **Routes**: `routes/web.php` and `routes/api.php`
- **Tests**: `tests/Feature/` and `tests/Unit/`

### Best Practices Applied

- **API Resources**: Use for consistent API response formats
- **Form Requests**: Separate validation logic from controllers
- **Factories**: Always create factories for models to support testing
- **Tests**: Write Feature tests for API endpoints covering success and error cases
- **Migrations**: Include indexes for foreign keys and frequently queried columns

## Working with Docker

### File Permissions

The workspace and php-fpm containers run with UID/GID that match your host user (configured via `.env`). Files created inside containers will have correct ownership on host.

### Xdebug Configuration

Xdebug is enabled by default for debugging:
- Port: 9003
- IDE Key: DOCKER
- Host: host.docker.internal

To disable Xdebug (better performance):
```bash
# Edit .env
XDEBUG_ENABLED=false

# Rebuild
make build
make up
```

### Volume Mounts

Code is mounted at `/var/www` in all containers via bind mount, providing hot-reload. Changes on host immediately reflect in containers.

### PostgreSQL Data Persistence

Database data persists in the named volume `postgres-data-development`. To completely reset:

```bash
make clean    # Removes containers AND volumes
make setup    # Reconfigure from scratch
```

## Initial Setup

When cloning this repository on a new machine:

```bash
# Run the automated setup script
./docker-setup.sh
```

This script will:
1. Create `.env` from `.env.example`
2. Detect and configure UID/GID
3. Build Docker images
4. Start containers
5. Install Composer dependencies
6. Generate APP_KEY
7. Run migrations
8. Install npm dependencies
9. Build assets

## Troubleshooting

### Container Won't Start

```bash
# Check logs for specific service
docker compose -f compose.dev.yaml logs [service-name]

# Common services: web, php-fpm, postgres, redis, workspace
```

### Permission Errors

Ensure UID/GID in `.env` match your host user:
```bash
echo "UID=$(id -u)" >> .env
echo "GID=$(id -g)" >> .env
make restart
```

### Port Already in Use

Edit `.env` to change ports:
```bash
NGINX_PORT=8080        # Default: 8000
POSTGRES_PORT=5433     # Default: 5432
REDIS_PORT=6380        # Default: 6379
```

### Database Connection Fails

Verify `.env` uses service name `postgres`, not `localhost` or `127.0.0.1`:
```bash
DB_HOST=postgres
```

### Changes Not Reflecting

```bash
make clear    # Clear all Laravel caches
```

## Testing Strategy

- **Feature Tests**: Test HTTP endpoints, database interactions, full request/response cycle
- **Unit Tests**: Test individual classes and methods in isolation
- **Database**: Tests use SQLite in-memory (configured in `phpunit.xml`)
- **Factories**: Use factories to create test data, not direct instantiation
- **RefreshDatabase**: Use this trait to reset database between tests

## Code Style

This project uses Laravel Pint for code formatting:

```bash
# Format code
docker compose -f compose.dev.yaml exec -u www workspace ./vendor/bin/pint

# Check without fixing
docker compose -f compose.dev.yaml exec -u www workspace ./vendor/bin/pint --test
```

## Git Workflow

When creating commits:
- Use descriptive commit messages in Spanish (based on project language)
- Follow the existing commit message format (e.g., `[FEATURE]`, `docs:`, `config:`)
- The project includes pre-configured permissions for automated git operations

## Additional Documentation

- `README.md` - Quick start guide and daily usage
- `README.Docker.md` - Complete Docker documentation
- `ARQUITECTURA.md` - Architecture diagrams and system design
- `INICIO-RAPIDO.md` - Fast setup guide
- `GUIA-PRUEBA.md` - Testing guide for new machines
- `RESUMEN-CONFIGURACION.md` - Configuration summary
- Al configurar nuevos MCPs, rastrea los cambios y si la configuración del MCP contiene API Keys o configuración sensible, añade una variable .ENV y actualiza la configuración del MCP para que adquiera el valor de dicha variable