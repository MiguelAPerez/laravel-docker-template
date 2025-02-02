# Usage official PHP image
FROM php:8.2-fpm

# Install PHP and NodeJs and other required dependencies
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    libzip-dev \
    unzip \
    p7zip \
    git \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable drivers for database, mail, download, and services
RUN docker-php-ext-install pdo_mysql mysqli zip opcache pdo pcntl bcmath pdo_sqlite

# Copy source code
COPY . /var/www/html
COPY .docker.env /var/www/html/.env

WORKDIR /var/www/html

# Update permissions for webserver
RUN chown -R www-data:www-data /var/www/html

# Storage Volume
VOLUME /var/www/html/storage

# Install Packages
RUN php composer.phar install # --no-dev --optimize-autoloader --no-interaction
RUN npm install -D

# Database setup
RUN php artisan key:generate
RUN php artisan storage:link --no-interaction -v

# Build static assets
RUN npm run build
RUN php artisan optimize

# Cache assets
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache
RUN php artisan event:cache

# Expose port
EXPOSE 9000

# Run php server
CMD ["php-fpm", "-R"]