# ---- Stage 1: Build dependencies ----
FROM php:8.3-fpm AS builder

RUN apt-get update && apt-get install -y \
    git curl zip unzip libpq-dev libzip-dev libgd-dev \
    libgeos-dev libproj-dev \
    && docker-php-ext-install pdo pdo_pgsql zip gd \
    && pecl install redis \
    && docker-php-ext-enable redis

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/backend

# Install dependencies first (cached unless composer.json changes)
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader

COPY . .
RUN composer dump-autoload --optimize

# ---- Stage 2: Production image (no build tools) ----
FROM php:8.3-fpm AS production

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d
COPY --from=builder /var/www/backend /var/www/backend

RUN chown -R www-data:www-data /var/www/backend/storage /var/www/backend/bootstrap/cache

WORKDIR /var/www/backend
