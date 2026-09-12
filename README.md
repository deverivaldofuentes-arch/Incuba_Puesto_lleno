# Puesto Lleno — Backend Laravel 10 + PostgreSQL + Docker

Proyecto **100% dockerizado** para trabajo en equipo.
**No necesitas instalar PHP, Composer ni PostgreSQL en tu maquina local.**
El contenedor se encarga de todo automaticamente al arrancar.

---

## Requisitos Previos

Solo necesitas estas dos herramientas instaladas:

| Herramienta    | Version minima | Descarga                                       |
|----------------|----------------|------------------------------------------------|
| Docker Desktop | 4.x            | https://www.docker.com/products/docker-desktop |
| Git            | 2.x            | https://git-scm.com                            |

> **Windows:** Activa la integracion con WSL 2 en Docker Desktop > Settings > Resources > WSL Integration.

---

## Stack Tecnologico

| Componente       | Version        |
|------------------|----------------|
| PHP              | 8.4 (CLI)      |
| Laravel          | 10.x           |
| PostgreSQL       | 15 Alpine      |
| Composer         | latest         |

---

## Configuracion Inicial (Solo la primera vez)

### Paso 1 — Clonar el repositorio

```bash
git clone https://github.com/deverivaldofuentes-arch/Incuba_Puesto_lleno.git
cd Incuba_Puesto_lleno
```

### Paso 2 — Copiar el archivo de entorno

```bash
cp .env.example .env
```

> Los puertos por defecto son **8001** (App) y **5433** (BD) para no chocar con otros proyectos.
> Si necesitas cambiarlos, edita tu `.env`:
>
> ```env
> APP_PORT=8002         # Puerto para la app
> FORWARD_DB_PORT=5434  # Puerto para PostgreSQL
> ```

### Paso 3 — Construir e iniciar los contenedores

```bash
docker compose up -d --build
```

**Eso es todo.** El contenedor se encarga automaticamente de:

- Instalar todas las dependencias con `composer install`
- Generar la `APP_KEY` si esta vacia
- Corregir permisos de `storage/` y `bootstrap/cache/`
- Limpiar el cache de configuracion
- Arrancar el servidor Laravel en `http://localhost:8001`

> La primera vez puede tardar **2-4 minutos** mientras descarga las imagenes y las dependencias.
> Puedes ver el progreso en tiempo real con: `docker compose logs -f app`

### Paso 4 — Ejecutar las migraciones

```bash
docker compose exec app php artisan migrate
```

### Paso 5 — Verificar que funciona

Abre tu navegador en: **http://localhost:8001**

Si ves la pantalla de Laravel, todo esta correcto.

---

## Comandos del Dia a Dia

### Gestion de contenedores

```bash
# Iniciar los servicios
docker compose up -d

# Detener los servicios (los datos se conservan)
docker compose down

# Reconstruir contenedores tras cambios en Dockerfile o entrypoint.sh
docker compose up -d --build

# Ver el estado de todos los contenedores
docker compose ps

# Ver los logs en tiempo real (todos los servicios)
docker compose logs -f

# Ver los logs solo del contenedor de la app
docker compose logs -f app

# Ver los logs solo de la base de datos
docker compose logs -f db
```

### Comandos de Laravel (Artisan)

```bash
# Ejecutar migraciones
docker compose exec app php artisan migrate

# Revertir y volver a correr migraciones con seeders
docker compose exec app php artisan migrate:fresh --seed

# Crear un modelo con su migracion
docker compose exec app php artisan make:model NombreModelo -m

# Crear un controlador resource
docker compose exec app php artisan make:controller NombreController --resource

# Crear un request de validacion
docker compose exec app php artisan make:request NombreRequest

# Ver todas las rutas registradas
docker compose exec app php artisan route:list

# Limpiar toda la cache de la aplicacion
docker compose exec app php artisan config:clear
docker compose exec app php artisan cache:clear
docker compose exec app php artisan route:clear

# Ejecutar los tests
docker compose exec app php artisan test
```

### Gestion de dependencias (Composer)

```bash
# Instalar un nuevo paquete
docker compose exec app composer require vendor/paquete

# Instalar un paquete solo para desarrollo
docker compose exec app composer require vendor/paquete --dev

# Actualizar todas las dependencias y regenerar composer.lock
docker compose exec app composer update
```

### Acceso directo a los contenedores

```bash
# Entrar al shell del contenedor de la aplicacion
docker compose exec app bash

# Entrar a la consola de PostgreSQL
docker compose exec db psql -U puesto_lleno -d puesto_lleno
```

---

## Arquitectura de Contenedores

```
  [Navegador / Cliente API]
          |
     localhost:8001
          |
  [ puesto_lleno_app ]   <-- PHP 8.4 CLI + Composer + Laravel
          |
  (red interna: puesto_lleno_network)
          |
  [ puesto_lleno_db ]    <-- PostgreSQL 15 Alpine
          |
  [ puesto_lleno_postgres_data ]  <-- Volumen persistente
```

| Recurso          | Nombre                     | Descripcion                         |
|------------------|----------------------------|-------------------------------------|
| Contenedor App   | puesto_lleno_app           | PHP 8.4 + PDO PostgreSQL + Composer |
| Contenedor BD    | puesto_lleno_db            | PostgreSQL 15 Alpine                |
| Red Docker       | puesto_lleno_network       | Red interna aislada                 |
| Volumen de datos | puesto_lleno_postgres_data | Persistencia de datos PostgreSQL    |

---

## Que hace el contenedor al arrancar (automatico)

El archivo `entrypoint.sh` ejecuta estos pasos en cada inicio:

| Paso | Accion                                      | Condicion             |
|------|---------------------------------------------|-----------------------|
| 1    | `composer install`                          | Solo si falta vendor/ |
| 2    | `chmod 775` en storage/ y bootstrap/cache/  | Siempre               |
| 3    | `php artisan key:generate`                  | Solo si APP_KEY vacia |
| 4    | `php artisan config:clear` y `cache:clear`  | Siempre               |
| 5    | `php artisan serve --host=0.0.0.0`          | Siempre               |

---

## Variables de Entorno Importantes

| Variable        | Valor por defecto | Descripcion                              |
|-----------------|-------------------|------------------------------------------|
| APP_PORT        | 8001              | Puerto local para acceder a la app       |
| FORWARD_DB_PORT | 5433              | Puerto local para conectar a PostgreSQL  |
| DB_DATABASE     | puesto_lleno      | Nombre de la base de datos               |
| DB_USERNAME     | puesto_lleno      | Usuario de PostgreSQL                    |
| DB_PASSWORD     | puesto_lleno      | Contrasena de PostgreSQL                 |
| APP_DEBUG       | true              | Muestra errores detallados (solo local)  |
| APP_KEY         | (auto-generada)   | Clave de encriptacion de Laravel         |

> **Produccion:** Cambia `APP_ENV=production`, `APP_DEBUG=false` y usa contrasenas seguras.

---

## Persistencia de Datos

Los datos de PostgreSQL se guardan en el volumen `puesto_lleno_postgres_data`.

```bash
# Detener servicios SIN borrar datos (recomendado)
docker compose down

# Detener servicios Y borrar todos los datos (irreversible)
docker compose down -v
```

---

## Buenas Practicas del Equipo

1. **Nunca subas `.env` al repositorio.** Esta en `.gitignore`. Cada miembro tiene su propio `.env` local.
2. Si agregas una variable nueva al `.env`, agregala tambien al `.env.example` sin el valor sensible.
3. Instala paquetes siempre desde el contenedor: `docker compose exec app composer require vendor/paquete`
4. Antes de hacer push, corre los tests: `docker compose exec app php artisan test`
5. Si un companero agrego migraciones nuevas, ejecuta: `docker compose exec app php artisan migrate`
6. Si cambias el `Dockerfile` o `entrypoint.sh`, reconstruye con: `docker compose up -d --build`

---

## Solucion de Problemas Frecuentes

### El contenedor `app` esta en bucle de reinicios (Restarting)

```bash
# Ver que esta fallando
docker compose logs app --tail=50

# Solucion rapida: reconstruir desde cero
docker compose down
docker compose up -d --build
```

### El puerto 8001 ya esta en uso

```bash
# Edita tu .env y cambia el puerto:
APP_PORT=8002

# Luego reinicia:
docker compose down && docker compose up -d
```

### Error de permisos en storage o bootstrap/cache

```bash
# El entrypoint lo corrige automaticamente, pero si persiste:
docker compose exec app chmod -R 775 storage bootstrap/cache
```

### Las dependencias no se instalaron correctamente

```bash
# Forzar reinstalacion limpia
docker compose exec app composer install --no-cache
```

### Empezar la base de datos desde cero

```bash
docker compose exec app php artisan migrate:fresh --seed
```

### Ver en tiempo real que pasa dentro del contenedor

```bash
docker compose logs -f app
```

### Limpiar todo y empezar de cero (nuclear)

```bash
docker compose down -v --rmi local
docker compose up -d --build
```

---

## Flujo de Trabajo Recomendado

```
git pull                          # Obtener cambios del equipo
docker compose up -d              # Arrancar (composer install es automatico)
docker compose exec app php artisan migrate   # Aplicar migraciones nuevas
# ... trabajar ...
docker compose exec app php artisan test      # Verificar antes de subir
git push
```