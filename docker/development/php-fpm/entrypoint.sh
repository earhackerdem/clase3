#!/bin/bash
set -e

# Wait for the database to be ready using PHP
echo "Waiting for PostgreSQL to be ready..."
until php -r "
\$host = getenv('DB_HOST') ?: 'postgres';
\$port = getenv('DB_PORT') ?: 5432;
\$conn = @fsockopen(\$host, \$port, \$errno, \$errstr, 5);
if (\$conn) {
    fclose(\$conn);
    exit(0);
}
exit(1);
"; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done

echo "PostgreSQL is up - executing command"

# Run migrations if needed
if [ "${RUN_MIGRATIONS}" = "true" ]; then
    php artisan migrate --force
fi

# Clear and cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Execute the main container command
exec "$@"

