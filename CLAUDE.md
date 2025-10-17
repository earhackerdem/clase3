# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Laravel 12 application running in a fully Dockerized environment with PostgreSQL 16, Redis, and Nginx. The setup is optimized for development with hot-reload, Xdebug support, and comprehensive Make commands.

## Development Environment

### Docker Architecture

The project uses Docker Compose with 5 services:
- **web**: Nginx (port 8000) - serves the application
- **php-fpm**: PHP 8.2-FPM with PostgreSQL, Redis extensions, and Xdebug
- **workspace**: PHP 8.2 CLI with Composer, Node.js 22 (via NVM), and development tools
- **postgres**: PostgreSQL 16 (port 5432) - main database
- **redis**: Redis Alpine (port 6379) - cache, sessions, and queues

All services communicate over the `laravel-development` bridge network using service names (e.g., `postgres:5432`, `redis:6379`).

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

# Access PostgreSQL CLI
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

The application uses **PostgreSQL** in Docker. Never use SQLite in development (only for tests).

### Connection Details

From Laravel (`.env`):
```
DB_CONNECTION=pgsql
DB_HOST=postgres          # Docker service name, not localhost
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
```

From host machine (pgAdmin, DBeaver):
```
Host: localhost
Port: 5432
Database: laravel
User: laravel
Password: secret
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
