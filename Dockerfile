# =============================================================================
# Stage 1: Build frontend assets
# =============================================================================
FROM node:16-alpine AS node_builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --no-audit --prefer-offline

COPY webpack.mix.js ./
COPY resources/ ./resources/
COPY public/ ./public/

RUN npm run prod

# =============================================================================
# Stage 2: Install PHP dependencies
# =============================================================================
FROM composer:2.2 AS composer_builder

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --no-scripts \
    --no-autoloader \
    --ignore-platform-reqs \
    --prefer-dist

COPY . .

RUN composer dump-autoload \
    --optimize \
    --no-dev

# =============================================================================
# Stage 3: Production app image
# =============================================================================
FROM php:7.4-fpm-alpine AS app

LABEL maintainer="ci-nomads"

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libzip-dev \
        libxml2-dev \
        oniguruma-dev \
        curl \
        unzip \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        ctype \
        fileinfo \
        gd \
        mbstring \
        opcache \
        pdo_mysql \
        tokenizer \
        xml \
        zip \
    && rm -rf /tmp/*

# PHP-FPM & OPcache production config
COPY docker/php/php.ini /usr/local/etc/php/conf.d/app.ini
COPY docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html

# Copy application files from composer builder
COPY --from=composer_builder /app /var/www/html

# Overwrite compiled public assets from node builder
COPY --from=node_builder /app/public /var/www/html/public

# Set correct ownership and permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]

# =============================================================================
# Stage 4: Nginx image with compiled assets baked in
# =============================================================================
FROM nginx:1.25-alpine AS nginx

COPY docker/nginx/conf.d/app.conf /etc/nginx/conf.d/default.conf

# Copy compiled public assets from node builder — no volume needed
COPY --from=node_builder /app/public /var/www/html/public

EXPOSE 80
