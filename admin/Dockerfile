FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev \
    zip unzip libzip-dev libexif-dev ffmpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

RUN echo "upload_max_filesize=100M\npost_max_size=100M\nmemory_limit=256M" > /usr/local/etc/php/conf.d/uploads.ini

EXPOSE 8000

CMD until php artisan migrate --force; do echo "Database not ready yet, retrying in 3s..."; sleep 3; done \
    && rm -f /var/www/public/storage && ln -s /var/www/storage/app/public /var/www/public/storage \
    && if [ ! -f /var/www/storage/app/.seeded ]; then php artisan db:seed --force && touch /var/www/storage/app/.seeded; fi \
    && touch /var/www/storage/installed \
    && php artisan serve --host=0.0.0.0 --port=8000
