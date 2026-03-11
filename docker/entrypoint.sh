#!/bin/sh
set -e

# Wait for the MySQL database to be ready
echo "Waiting for database connection..."
until php -r "new PDO('mysql:host=${DB_HOST:-db};port=${DB_PORT:-3306};dbname=${DB_DATABASE}', '${DB_USERNAME}', '${DB_PASSWORD}');" 2>/dev/null; do
    echo "  Database not ready — retrying in 3s..."
    sleep 3
done
echo "Database is ready."

# Create the storage:link (safe to run multiple times)
php artisan storage:link --quiet || true

# Cache config, routes, and views for faster boot times
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Optionally run migrations — set RUN_MIGRATIONS=true in your env to enable
if [ "${RUN_MIGRATIONS}" = "true" ]; then
    echo "Running database migrations..."
    php artisan migrate --force
fi

echo "Starting php-fpm..."
exec "$@"
