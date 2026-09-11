# 🚀 Puesto_lleno - Plataforma Backend (Laravel 10 + PostgreSQL + Docker)

Proyecto **Puesto_lleno** basado en **Laravel 10**, totalmente dockerizado con **PostgreSQL 15**, diseñado para trabajo en equipo sin conflictos de puertos ni servicios.

---

## 📋 Requisitos Previos

1. **Docker Desktop** (con soporte WSL 2 activado en Windows) o **Docker Engine** + **Docker Compose** v2 en Linux/macOS.
2. **Git**.

> 💡 **Nota:** No necesitas instalar PHP, Composer ni PostgreSQL localmente en tu sistema. Todo se ejecuta dentro de contenedores aislados.

---

## 🚀 Inicio Rápido (Paso a Paso)

### 1. Clonar el repositorio
```bash
git clone <URL_DEL_REPOSITORIO> Puesto_lleno
cd Puesto_lleno
```

### 2. Configurar variables de entorno
```bash
cp .env.example .env
```

*(Opcional)* Si en tu máquina local ya tienes un servicio ocupando el puerto `8000` o `5432`, edita en tu `.env`:
```env
APP_PORT=8002
FORWARD_DB_PORT=5434
```

### 3. Construir y encender los contenedores
```bash
docker compose up -d --build
```

### 4. Generar clave de la aplicación y ejecutar migraciones
```bash
# Generar APP_KEY
docker compose exec app php artisan key:generate

# Ejecutar migraciones de PostgreSQL
docker compose exec app php artisan migrate
```

### 5. Verificar funcionamiento
Abre tu navegador e ingresa a: **[http://localhost:8000](http://localhost:8000)** (o el puerto configurado en `APP_PORT`).

---

## 🛠️ Comandos de Desarrollo Diario

| Acción | Comando |
|---|---|
| **Iniciar servicios** | `docker compose up -d` |
| **Detener servicios** | `docker compose down` |
| **Ver logs en tiempo real** | `docker compose logs -f` |
| **Ver estado de contenedores** | `docker compose ps` |
| **Ejecutar comandos Artisan** | `docker compose exec app php artisan <comando>` |
| **Ejecutar migraciones + seeders** | `docker compose exec app php artisan migrate:fresh --seed` |
| **Ejecutar Composer** | `docker compose exec app composer <comando>` |
| **Ejecutar Tests** | `docker compose exec app php artisan test` |
| **Entrar al Shell del contenedor** | `docker compose exec app bash` |
| **Consola de PostgreSQL (psql)** | `docker compose exec db psql -U puesto_lleno -d puesto_lleno` |

---

## 🔒 Aislamiento y Estructura de Contenedores

- **Contenedor App:** `puesto_lleno_app` (PHP 8.2 CLI + PDO PostgreSQL + Composer).
- **Contenedor BD:** `puesto_lleno_db` (PostgreSQL 15 Alpine).
- **Red aislada:** `puesto_lleno_network` (Evita conflictos con otros proyectos Docker).
- **Volumen de Datos:** `puesto_lleno_postgres_data` (Garantiza que la información de PostgreSQL persista tras reiniciar la PC o los contenedores).

---

## 🤝 Buenas Prácticas para el Equipo

- **No subir el archivo `.env` al repositorio.** Cada desarrollador mantiene su propio `.env`.
- Si agregas una nueva variable de entorno al proyecto, regístrala también en `.env.example`.
- Para instalar nuevos paquetes PHP: `docker compose exec app composer require <paquete>`.
