# 🏗️ Arquitectura del Entorno Docker

## 📊 Diagrama de Servicios

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Red: laravel-development                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌────────────────┐         ┌──────────────────┐                   │
│  │   NAVEGADOR    │────────▶│  NGINX (web)     │                   │
│  │                │         │  Puerto: 8000    │                   │
│  └────────────────┘         │  Imagen: nginx   │                   │
│                             └────────┬─────────┘                   │
│                                      │                              │
│                                      │ FastCGI                      │
│                                      ▼                              │
│                             ┌──────────────────┐                   │
│                             │  PHP-FPM         │                   │
│                             │  Puerto: 9000    │                   │
│                             │  PHP 8.2         │                   │
│                             │  + Xdebug        │                   │
│                             │  + PostgreSQL    │                   │
│                             │  + Redis ext     │                   │
│                             └────────┬─────────┘                   │
│                                      │                              │
│                                      │                              │
│                      ┌───────────────┴──────────────┐              │
│                      │                               │              │
│                      ▼                               ▼              │
│            ┌──────────────────┐          ┌─────────────────┐      │
│            │  POSTGRESQL 16   │          │  REDIS          │      │
│            │  Puerto: 5432    │          │  Puerto: 6379   │      │
│            │  DB: laravel     │          │                 │      │
│            │  User: laravel   │          │  Cache + Queue  │      │
│            │  Pass: secret    │          │  + Sessions     │      │
│            └──────────────────┘          └─────────────────┘      │
│                      ▲                                              │
│                      │                                              │
│                      └────────────────┐                            │
│                                       │                            │
│                             ┌──────────────────┐                   │
│                             │  WORKSPACE       │                   │
│                             │  PHP 8.2 CLI     │                   │
│                             │  + Composer      │                   │
│                             │  + Node.js 22    │                   │
│                             │  + npm           │                   │
│                             │  + Artisan       │                   │
│                             │  + Xdebug        │                   │
│                             │  + Git           │                   │
│                             └──────────────────┘                   │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Servicios Configurados

### 1. 🌐 **NGINX (web)**
- **Imagen:** `nginx:latest`
- **Puerto:** `8000:80` (host:container)
- **Función:** Servidor web que maneja las peticiones HTTP
- **Configuración:** `docker/development/nginx/nginx.conf`
- **Características:**
  - Compresión Gzip
  - Caché de assets estáticos
  - FastCGI para PHP
  - Timeouts optimizados

### 2. 🐘 **PHP-FPM**
- **Imagen:** Custom (Multi-stage)
- **Base:** `php:8.2-fpm`
- **Puerto interno:** `9000`
- **Dockerfile:** `docker/common/php-fpm/Dockerfile`
- **Extensiones instaladas:**
  - `pdo_pgsql` - PostgreSQL
  - `pgsql` - PostgreSQL
  - `redis` - Redis
  - `opcache` - Caché de código
  - `intl` - Internacionalización
  - `zip` - Compresión
  - `bcmath` - Matemáticas
  - `soap` - Web Services
  - `xdebug` - Debugging (solo desarrollo)
- **Características:**
  - Usuario custom con UID/GID configurable
  - Entrypoint con health checks
  - Configuración optimizada de OPcache

### 3. 💻 **WORKSPACE**
- **Imagen:** Custom
- **Base:** `php:8.2-cli`
- **Dockerfile:** `docker/development/workspace/Dockerfile`
- **Herramientas incluidas:**
  - PHP 8.2 CLI con todas las extensiones
  - Composer (latest)
  - Node.js 22 (vía NVM)
  - npm
  - Git
  - PostgreSQL client
  - Xdebug
- **Función:** Contenedor para desarrollo, comandos CLI, Artisan, compilación de assets

### 4. 🗄️ **PostgreSQL 16**
- **Imagen:** `postgres:16`
- **Puerto:** `5432:5432`
- **Base de datos:** `laravel`
- **Usuario:** `laravel`
- **Contraseña:** `secret`
- **Volumen:** `postgres-data-development`
- **Health check:** Incluido
- **Características:**
  - Persistencia de datos
  - Auto-restart
  - Health monitoring

### 5. 🔴 **Redis Alpine**
- **Imagen:** `redis:alpine`
- **Puerto:** `6379:6379`
- **Función:** 
  - Caché de aplicación
  - Almacenamiento de sesiones
  - Colas (queues)
- **Health check:** Incluido

---

## 🔄 Flujo de Desarrollo

```
┌──────────────┐
│ DESARROLLADOR│
└──────┬───────┘
       │
       │ (1) Edita código en host
       │
       ▼
┌────────────────────────────────────┐
│  ARCHIVOS MONTADOS (bind mount)    │
│  ./:/var/www                       │
└────────┬──────────────┬────────────┘
         │              │
         │              │ (2) Hot reload
         │              │
         ▼              ▼
  ┌─────────────┐  ┌──────────┐
  │  PHP-FPM    │  │ WORKSPACE│
  │  (ejecuta)  │  │  (CLI)   │
  └─────────────┘  └──────────┘
         │              │
         │              │
         │              │ (3) Compila assets
         │              │
         ▼              ▼
    ┌──────────────────────┐
    │   public/build/      │
    └──────────────────────┘
```

---

## 📁 Estructura de Archivos Docker

```
proyecto/
│
├── docker/                           # Configuraciones Docker
│   ├── common/                       # Compartido producción/desarrollo
│   │   └── php-fpm/
│   │       └── Dockerfile            # Multi-stage: base → prod → dev
│   │
│   ├── development/                  # Específico para desarrollo
│   │   ├── php-fpm/
│   │   │   └── entrypoint.sh        # Script de inicio con health checks
│   │   ├── workspace/
│   │   │   └── Dockerfile           # Contenedor CLI con herramientas
│   │   └── nginx/
│   │       └── nginx.conf           # Configuración Nginx
│   │
│   └── production/                   # Para futuras configuraciones prod
│
├── compose.dev.yaml                  # Orquestación de servicios
├── .dockerignore                     # Archivos excluidos de imágenes
├── .env.example                      # Variables de entorno template
│
├── docker-setup.sh                   # 🚀 Script de configuración automática
├── Makefile                          # 🛠️ Comandos simplificados
├── INICIO-RAPIDO.md                  # ⚡ Guía de inicio rápido
├── README.Docker.md                  # 📚 Documentación completa
└── ARQUITECTURA.md                   # 🏗️ Este archivo
```

---

## 🔐 Variables de Entorno Importantes

### Docker (.env)
```bash
# Puertos
NGINX_PORT=8000
POSTGRES_PORT=5432
REDIS_PORT=6379

# Permisos (sincronización con host)
UID=1000
GID=1000

# Xdebug (debugging)
XDEBUG_ENABLED=true
XDEBUG_HOST=host.docker.internal
XDEBUG_IDE_KEY=DOCKER
```

### Laravel (.env)
```bash
# Base de datos
DB_CONNECTION=pgsql
DB_HOST=postgres          # Nombre del servicio
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

# Cache y Sesiones
CACHE_STORE=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Redis
REDIS_HOST=redis          # Nombre del servicio
REDIS_PORT=6379
```

---

## 🔄 Multi-Stage Build Strategy

El Dockerfile de PHP-FPM utiliza una estrategia de construcción multi-etapa:

```dockerfile
# Stage 1: Base
FROM php:8.2-fpm AS base
# Instala extensiones comunes
# Configura PHP básico

# Stage 2: Production
FROM base AS production
# Copia código de aplicación
# Instala dependencias de producción
# Optimizaciones de producción

# Stage 3: Development
FROM production AS development
# Instala Xdebug
# Configura usuario custom (UID/GID)
# Habilita hot reload
# Scripts de desarrollo
```

**Ventajas:**
- ✅ Misma base para desarrollo y producción
- ✅ Desarrollo hereda de producción (consistencia)
- ✅ Imágenes optimizadas por entorno
- ✅ Reutilización de capas (cache)

---

## 🌐 Network: laravel-development

Todos los servicios están en la misma red Docker tipo `bridge`:

```yaml
networks:
  laravel-development:
    driver: bridge
```

**Características:**
- ✅ Resolución de DNS automática por nombre de servicio
- ✅ Aislamiento de red del host
- ✅ Comunicación eficiente entre contenedores
- ✅ Exposición selectiva de puertos al host

**Comunicación:**
```
PHP-FPM   ──▶  postgres:5432  (interno)
PHP-FPM   ──▶  redis:6379     (interno)
NGINX     ──▶  php-fpm:9000   (interno)
HOST      ──▶  localhost:8000  (expuesto)
```

---

## 💾 Volúmenes

### 1. Volumen Named (PostgreSQL)
```yaml
volumes:
  postgres-data-development:
    driver: local
```
- **Persistencia:** Los datos sobreviven a `docker compose down`
- **Ubicación:** Gestionado por Docker
- **Limpieza:** `docker compose down -v`

### 2. Bind Mounts (Código)
```yaml
volumes:
  - ./:/var/www
```
- **Hot reload:** Cambios en tiempo real
- **Desarrollo:** Editas en host, se refleja en contenedor
- **Bidireccional:** Cambios en contenedor afectan host

---

## 🔍 Health Checks

### PostgreSQL
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U laravel -d laravel"]
  interval: 5s
  timeout: 5s
  retries: 5
```

### Redis
```yaml
healthcheck:
  test: ["CMD", "redis-cli", "ping"]
  interval: 5s
  timeout: 3s
  retries: 5
```

**Beneficios:**
- ✅ Garantiza disponibilidad antes de iniciar dependientes
- ✅ Auto-reinicio en caso de fallo
- ✅ Estado visible en `docker compose ps`

---

## 🔒 Seguridad

### En Desarrollo
- ✅ Usuario non-root (www, UID/GID sincronizado)
- ✅ .env no se incluye en imágenes (.dockerignore)
- ✅ Volúmenes con permisos apropiados
- ⚠️ Puertos expuestos en localhost (solo desarrollo)
- ⚠️ Xdebug habilitado (solo desarrollo)

### Para Producción (futuro)
- ✅ Multi-stage build (imagen más pequeña)
- ✅ OPcache configurado
- ✅ Sin Xdebug
- ✅ Código compilado (sin bind mounts)
- ✅ Secrets management
- ✅ Health checks

---

## 📊 Rendimiento

### Optimizaciones Incluidas

**PHP-FPM:**
- OPcache habilitado (validate_timestamps=0 en prod)
- pm.max_children optimizado
- FastCGI buffering configurado

**Nginx:**
- Gzip compression
- Static assets caching
- Keepalive connections
- Worker processes: auto

**PostgreSQL:**
- Volumen local (rápido)
- Health checks
- Connection pooling (Laravel)

**Redis:**
- Alpine image (ligero)
- En memoria (ultra rápido)

---

## 🎯 Casos de Uso

### Desarrollo Local
```bash
make up      # Inicia todo
make shell   # Accede al workspace
make logs    # Monitorea actividad
```

### Testing
```bash
make test           # Ejecuta PHPUnit
make fresh-seed     # Resetea DB con datos de prueba
```

### Debugging
```bash
# Xdebug está activo por defecto
# Configura tu IDE
# Coloca breakpoints
# ¡Debuguea!
```

### CI/CD (futuro)
```bash
docker compose -f compose.prod.yaml build
docker compose -f compose.prod.yaml up -d
```

---

## 🚀 Próximas Mejoras Sugeridas

- [ ] **compose.prod.yaml** para producción
- [ ] **GitHub Actions** para CI/CD
- [ ] **MailHog/Mailpit** para testing de emails
- [ ] **Adminer/pgAdmin** para gestión de DB
- [ ] **Nginx optimizado** con HTTP/2
- [ ] **Supervisor** para queue workers
- [ ] **Cron** para scheduled tasks
- [ ] **Backup automático** de PostgreSQL

---

## 📚 Referencias

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Laravel Docker Guide](https://docs.docker.com/guides/frameworks/laravel/development-setup/)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)
- [PHP Official Images](https://hub.docker.com/_/php)
- [Nginx Documentation](https://nginx.org/en/docs/)

---

**📝 Creado:** Octubre 2025
**🔧 Versión:** Laravel 12 | PHP 8.2 | PostgreSQL 16 | Node.js 22

