# Puesto_lleno - Backend Laravel 10 + PostgreSQL + Docker

Proyecto **100% dockerizado** para trabajo en equipo. No necesitas instalar PHP, Composer ni PostgreSQL en tu maquina local.

---

## Requisitos Previos

Asegurate de tener instalado en tu sistema:

| Herramienta     | Version minima | Descarga                                      |
|-----------------|----------------|-----------------------------------------------|
| Docker Desktop  | 4.x            | https://www.docker.com/products/docker-desktop |
| Git             | 2.x            | https://git-scm.com                           |

> IMPORTANTE Windows: Activa la integracion con WSL 2 en Docker Desktop > Settings > Resources > WSL Integration.

---

## Configuracion Inicial (Solo la primera vez)

### Paso 1 - Clonar el repositorio

```bash
git clone <URL_DEL_REPOSITORIO> Puesto_lleno
cd Puesto_lleno
```

### Paso 2 - Copiar el archivo de entorno

```bash
cp .env.example .env
```

> Nota: Este proyecto usa los puertos **8001** (App) y **5433** (BD) por defecto para que no choque con otros proyectos como Ahorrazo.
> Si necesitas cambiarlos, edita tu `.env`:
>
> ```env
> APP_PORT=8002        # Puerto para la app
> FORWARD_DB_PORT=5434 # Puerto para PostgreSQL
> ```

### Paso 3 - Construir e iniciar los contenedores

```bash
docker compose up -d --build
```

Este comando descarga las imagenes, construye el contenedor PHP y levanta la base de datos PostgreSQL.
La primera vez puede tardar unos minutos dependiendo de tu conexion a internet.

### Paso 4 - Generar clave de la aplicacion

```bash
docker compose exec app php artisan key:generate
```

### Paso 5 - Ejecutar las migraciones

```bash
docker compose exec app php artisan migrate
```

### Paso 6 - Verificar que funciona

Abre tu navegador en: **http://localhost:8001**

Si configuraste un puerto diferente, usa: `http://localhost:{APP_PORT}`

---

## Comandos del Dia a Dia

### Gestion de contenedores

```bash
# Iniciar los servicios (sin reconstruir)
docker compose up -d

# Detener los servicios (los datos se conservan)
docker compose down

# Reconstruir contenedores tras cambios en Dockerfile
docker compose up -d --build

# Ver el estado de los contenedores
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

# Revertir y volver a correr todas las migraciones con seeders
docker compose exec app php artisan migrate:fresh --seed

# Crear un nuevo modelo con migracion
docker compose exec app php artisan make:model NombreModelo -m

# Crear un controlador resource
docker compose exec app php artisan make:controller NombreController --resource

# Crear un request de validacion
docker compose exec app php artisan make:request NombreRequest

# Ver todas las rutas registradas
docker compose exec app php artisan route:list

# Limpiar cache de la aplicacion
docker compose exec app php artisan cache:clear
docker compose exec app php artisan config:clear
docker compose exec app php artisan route:clear

# Ejecutar los tests
docker compose exec app php artisan test
```

### Gestion de dependencias (Composer)

```bash
# Instalar un nuevo paquete
docker compose exec app composer require vendor/paquete

# Instalar un paquete de desarrollo
docker compose exec app composer require vendor/paquete --dev

# Actualizar dependencias
docker compose exec app composer update
```

### Acceso directo a los contenedores

```bash
# Entrar al bash del contenedor de la aplicacion
docker compose exec app bash

# Entrar a la consola de PostgreSQL (psql)
docker compose exec db psql -U puesto_lleno -d puesto_lleno
```

---

## Arquitectura de Contenedores

```
  [Tu Navegador / Herramienta]
          |
     localhost:8001
          |
  [ puesto_lleno_app ]    <-- PHP 8.2 CLI + PDO + Composer
          |
     (red interna: puesto_lleno_network)
          |
  [ puesto_lleno_db ]     <-- PostgreSQL 15 Alpine
          |
  [ puesto_lleno_postgres_data ]  <-- Volumen persistente
```

| Recurso            | Nombre                       | Descripcion                          |
|--------------------|------------------------------|--------------------------------------|
| Contenedor App     | puesto_lleno_app             | PHP 8.2 + PDO PostgreSQL + Composer  |
| Contenedor BD      | puesto_lleno_db              | PostgreSQL 15 Alpine                 |
| Red Docker         | puesto_lleno_network         | Red aislada, sin conflictos          |
| Volumen de datos   | puesto_lleno_postgres_data   | Persistencia de datos PostgreSQL     |

---

## Variables de Entorno Importantes

| Variable          | Valor por defecto | Descripcion                              |
|-------------------|-------------------|------------------------------------------|
| APP_PORT          | 8001              | Puerto local para acceder a la app       |
| FORWARD_DB_PORT   | 5433              | Puerto local para conectar a PostgreSQL  |
| DB_DATABASE       | puesto_lleno      | Nombre de la base de datos               |
| DB_USERNAME       | puesto_lleno      | Usuario de PostgreSQL                    |
| DB_PASSWORD       | puesto_lleno      | Contrasena de PostgreSQL                 |
| APP_DEBUG         | true              | Muestra errores detallados (solo local)  |

> ATENCION En produccion: cambia `APP_ENV=production`, `APP_DEBUG=false` y usa contrasenas seguras.

---

## Persistencia de Datos

Los datos de PostgreSQL se guardan en el volumen `puesto_lleno_postgres_data`.

```bash
# Detener servicios SIN borrar datos
docker compose down

# Detener servicios Y borrar todos los datos (cuidado)
docker compose down -v
```

---

## Buenas Practicas del Equipo

1. **Nunca subas `.env` al repositorio.** Cada miembro tiene su propio `.env` local.
2. Siempre que agregues una variable nueva al `.env`, agregala tambien al `.env.example` (sin valor sensible).
3. Usa `docker compose exec app composer require` para instalar paquetes desde el contenedor.
4. Antes de hacer push, corre `docker compose exec app php artisan test` para verificar que los tests pasen.
5. Si un companero agrega una nueva migracion, ejecuta `docker compose exec app php artisan migrate` para actualizarte.

---

## Solucion de Problemas Frecuentes

**El puerto 8001 ya esta en uso:**
```bash
# En tu .env, cambia:
APP_PORT=8002
# Luego reinicia:
docker compose down && docker compose up -d
```

**Error de permisos en storage o bootstrap/cache:**
```bash
docker compose exec app chmod -R 775 storage bootstrap/cache
```

**Quiero empezar la base de datos desde cero:**
```bash
docker compose exec app php artisan migrate:fresh --seed
```

**Ver que esta pasando dentro de los contenedores:**
```bash
docker compose logs -f app
docker compose logs -f db
```
