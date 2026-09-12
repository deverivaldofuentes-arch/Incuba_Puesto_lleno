#!/bin/bash
set -e

echo "========================================="
echo "  Iniciando contenedor Laravel..."
echo "========================================="

if [ ! -f /var/www/html/vendor/autoload.php ]; then
    echo "[1/4] vendor/ no encontrado. Ejecutando composer install..."
    composer install --no-interaction --prefer-dist --optimize-autoloader
    echo "[OK] composer install completado."
else
    echo "[OK] vendor/ ya existe. Omitiendo composer install."
fi

echo "[2/4] Aplicando permisos a storage/ y bootstrap/cache/..."
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true

if grep -q "^APP_KEY=$" /var/www/html/.env 2>/dev/null; then
    echo "[3/4] APP_KEY vacia detectada. Generando..."
    php artisan key:generate --force
    echo "[OK] APP_KEY generada."
else
    echo "[OK] APP_KEY ya definida."
fi

echo "[4/4] Limpiando cache de Laravel..."
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true

echo "========================================="
echo "  Servidor Laravel en 0.0.0.0:8000"
echo "========================================="
exec php artisan serve --host=0.0.0.0 --port=8000