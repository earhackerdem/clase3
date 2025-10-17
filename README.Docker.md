# 🐳 Entorno de Desarrollo Docker para Laravel 12

Este proyecto está configurado para ejecutarse en un entorno de desarrollo completo usando Docker y Docker Compose con MySQL 8.4 como base de datos predeterminada y PostgreSQL 16 como alternativa.

## 📋 Requisitos Previos

- Docker Engine 20.10+
- Docker Compose v2+
- Git

## 🏗️ Arquitectura de Servicios

El entorno incluye los siguientes servicios:

- **web (Nginx)**: Servidor web en el puerto 8000
- **php-fpm**: Procesador PHP-FPM 8.2 con extensiones para Laravel (MySQL, PostgreSQL, Redis)
- **workspace**: Contenedor de trabajo con PHP CLI, Composer, Node.js y herramientas de desarrollo
- **mysql**: MySQL 8.4 LTS en el puerto 3306 (base de datos predeterminada)
- **postgres**: PostgreSQL 16 en el puerto 5432 (base de datos alternativa)
- **redis**: Redis Alpine para caché y sesiones
- **phpmyadmin**: phpMyAdmin en el puerto 8080 para gestión de MySQL

## 🚀 Inicio Rápido

### Opción 1: Script Automático (Recomendado)

```bash
# Ejecutar el script de configuración automática
./docker-setup.sh
```

Este script se encargará de:
- ✅ Crear el archivo `.env`
- ✅ Construir las imágenes Docker
- ✅ Levantar los contenedores
- ✅ Instalar dependencias de Composer y npm
- ✅ Generar la clave de aplicación
- ✅ Ejecutar migraciones
- ✅ Construir assets de frontend

### Opción 2: Manual

```bash
# 1. Copiar archivo de entorno
cp .env.example .env

# 2. Configurar variables de entorno (opcional)
nano .env

# 3. Construir y levantar contenedores
docker compose -f compose.dev.yaml up -d --build

# 4. Instalar dependencias de Composer
docker compose -f compose.dev.yaml exec -u www workspace composer install

# 5. Generar clave de aplicación
docker compose -f compose.dev.yaml exec -u www workspace php artisan key:generate

# 6. Ejecutar migraciones
docker compose -f compose.dev.yaml exec -u www workspace php artisan migrate

# 7. Instalar dependencias de npm
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm install"

# 8. Construir assets
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm run build"
```

## 🌐 Acceso a Servicios

Una vez iniciado, los servicios estarán disponibles en:

- **Aplicación Laravel**: http://localhost:8000
- **phpMyAdmin**: http://localhost:8080
  - Usuario: `root`
  - Contraseña: `root_secret`
- **MySQL 8.4** (predeterminado): localhost:3306
  - Base de datos: `laravel`
  - Usuario: `laravel`
  - Contraseña: `secret`
  - Root password: `root_secret`
- **PostgreSQL 16** (alternativa): localhost:5432
  - Base de datos: `laravel`
  - Usuario: `laravel`
  - Contraseña: `secret`
- **Redis**: localhost:6379

## 🛠️ Comandos Útiles

### Gestión de Contenedores

```bash
# Ver estado de contenedores
docker compose -f compose.dev.yaml ps

# Ver logs de todos los servicios
docker compose -f compose.dev.yaml logs -f

# Ver logs de un servicio específico
docker compose -f compose.dev.yaml logs -f php-fpm

# Detener contenedores (sin eliminarlos)
docker compose -f compose.dev.yaml stop

# Iniciar contenedores detenidos
docker compose -f compose.dev.yaml start

# Reiniciar contenedores
docker compose -f compose.dev.yaml restart

# Detener y eliminar contenedores
docker compose -f compose.dev.yaml down

# Detener y eliminar contenedores + volúmenes
docker compose -f compose.dev.yaml down -v
```

### Workspace (Contenedor de Desarrollo)

```bash
# Acceder al workspace
docker compose -f compose.dev.yaml exec -u www workspace bash

# Ejecutar comandos Artisan
docker compose -f compose.dev.yaml exec -u www workspace php artisan migrate
docker compose -f compose.dev.yaml exec -u www workspace php artisan make:model Product
docker compose -f compose.dev.yaml exec -u www workspace php artisan tinker

# Ejecutar Composer
docker compose -f compose.dev.yaml exec -u www workspace composer require package/name
docker compose -f compose.dev.yaml exec -u www workspace composer update

# Ejecutar npm (requiere cargar NVM)
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm install"
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm run dev"
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm run build"

# Ejecutar tests
docker compose -f compose.dev.yaml exec -u www workspace php artisan test
docker compose -f compose.dev.yaml exec -u www workspace ./vendor/bin/phpunit
```

### Base de Datos

```bash
# Acceder a MySQL CLI (base de datos predeterminada)
docker compose -f compose.dev.yaml exec mysql mysql -u laravel -psecret laravel

# Acceder a PostgreSQL CLI (alternativa)
docker compose -f compose.dev.yaml exec postgres psql -U laravel -d laravel

# Ejecutar migraciones
docker compose -f compose.dev.yaml exec -u www workspace php artisan migrate

# Rollback de migraciones
docker compose -f compose.dev.yaml exec -u www workspace php artisan migrate:rollback

# Refrescar base de datos (drop + migrate)
docker compose -f compose.dev.yaml exec -u www workspace php artisan migrate:fresh

# Sembrar base de datos
docker compose -f compose.dev.yaml exec -u www workspace php artisan db:seed

# Refrescar y sembrar
docker compose -f compose.dev.yaml exec -u www workspace php artisan migrate:fresh --seed
```

### Monitoreo de MySQL

```bash
# Ver queries lentas (> 1 segundo)
tail -f storage/logs/mysql/mysql-slow.log

# Ver estadísticas de performance
docker compose -f compose.dev.yaml exec mysql mysql -u root -proot_secret -e "
  SELECT DIGEST_TEXT as query,
         COUNT_STAR as exec_count,
         ROUND(AVG_TIMER_WAIT/1000000000000, 2) as avg_time_sec
  FROM performance_schema.events_statements_summary_by_digest
  WHERE DIGEST_TEXT IS NOT NULL
  ORDER BY SUM_TIMER_WAIT DESC
  LIMIT 10;"

# Ver conexiones activas
docker compose -f compose.dev.yaml exec mysql mysql -u root -proot_secret -e "SHOW PROCESSLIST;"

# Ver estadísticas de tablas
docker compose -f compose.dev.yaml exec mysql mysql -u root -proot_secret laravel -e "
  SELECT table_name,
         table_rows,
         ROUND(data_length / 1024 / 1024, 2) as data_mb
  FROM information_schema.tables
  WHERE table_schema = 'laravel'
  ORDER BY data_length DESC;"

# O usar el script de monitoreo completo
./scripts/mysql-monitor.sh all
```

### Caché y Optimización

```bash
# Limpiar caché de configuración
docker compose -f compose.dev.yaml exec -u www workspace php artisan config:clear

# Cachear configuración
docker compose -f compose.dev.yaml exec -u www workspace php artisan config:cache

# Limpiar caché de rutas
docker compose -f compose.dev.yaml exec -u www workspace php artisan route:clear

# Cachear rutas
docker compose -f compose.dev.yaml exec -u www workspace php artisan route:cache

# Limpiar todas las cachés
docker compose -f compose.dev.yaml exec -u www workspace php artisan optimize:clear
```

## 🐛 Debugging con Xdebug

El entorno incluye Xdebug configurado para debugging. Para usarlo:

### Visual Studio Code

1. Instala la extensión "PHP Debug"
2. Crea `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www": "${workspaceFolder}"
            }
        }
    ]
}
```

3. Coloca breakpoints en tu código
4. Inicia el debugger (F5)
5. Recarga la página en tu navegador

### PhpStorm

1. Ve a Settings → PHP → Servers
2. Crea un nuevo servidor:
   - Name: `docker`
   - Host: `localhost`
   - Port: `8000`
   - Debugger: `Xdebug`
   - Path mappings: `/var/www` → tu carpeta del proyecto
3. Activa "Start Listening for PHP Debug Connections"
4. Coloca breakpoints y recarga la página

## 📁 Estructura de Docker

```
proyecto/
├── docker/
│   ├── common/
│   │   └── php-fpm/
│   │       └── Dockerfile          # Imagen base de PHP-FPM (producción + desarrollo)
│   ├── development/
│   │   ├── php-fpm/
│   │   │   └── entrypoint.sh       # Script de inicialización de PHP-FPM
│   │   ├── workspace/
│   │   │   └── Dockerfile          # Imagen del workspace con herramientas dev
│   │   └── nginx/
│   │       └── nginx.conf          # Configuración de Nginx
│   └── production/                  # (Para configuración futura de producción)
├── compose.dev.yaml                 # Docker Compose para desarrollo
├── .dockerignore                    # Archivos excluidos de las imágenes
├── docker-setup.sh                  # Script de inicialización automática
└── README.Docker.md                 # Este archivo
```

## ⚙️ Variables de Entorno

Las principales variables en `.env` relacionadas con Docker:

```env
# Base de Datos MySQL (predeterminada)
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

# MySQL Configuración Adicional
MYSQL_ROOT_PASSWORD=root_secret
MYSQL_USER=laravel
MYSQL_PASSWORD=secret
MYSQL_DATABASE=laravel
MYSQL_PORT=3306

# PostgreSQL (alternativa)
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DATABASE=laravel
POSTGRES_USERNAME=laravel
POSTGRES_PASSWORD=secret

# phpMyAdmin
PHPMYADMIN_PORT=8080

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Docker
NGINX_PORT=8000
UID=1000
GID=1000

# Xdebug
XDEBUG_ENABLED=true
XDEBUG_HOST=host.docker.internal
XDEBUG_IDE_KEY=DOCKER
```

## 🔧 Personalización

### Cambiar de MySQL a PostgreSQL

Para usar PostgreSQL en lugar de MySQL:

1. Edita `.env`:
```env
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
```

2. Refresca la base de datos:
```bash
docker compose -f compose.dev.yaml exec -u www workspace php artisan migrate:fresh --seed
```

### Cambiar el Puerto de Nginx

Edita `.env`:
```env
NGINX_PORT=9000
```

Reinicia los contenedores:
```bash
docker compose -f compose.dev.yaml restart web
```

### Cambiar el Puerto de phpMyAdmin

Edita `.env`:
```env
PHPMYADMIN_PORT=9080
```

Reinicia los contenedores:
```bash
docker compose -f compose.dev.yaml restart phpmyadmin
```

### Deshabilitar Xdebug (mejora el rendimiento)

Edita `.env`:
```env
XDEBUG_ENABLED=false
```

Reconstruye el contenedor:
```bash
docker compose -f compose.dev.yaml up -d --build php-fpm workspace
```

### Cambiar la Versión de Node.js

Edita `docker/development/workspace/Dockerfile`:
```dockerfile
ARG NODE_VERSION=20.0.0
```

Reconstruye:
```bash
docker compose -f compose.dev.yaml build workspace
```

## 🚨 Solución de Problemas

### Los permisos de archivos son incorrectos

Asegúrate de que UID y GID en `.env` coincidan con tu usuario:
```bash
echo "UID=$(id -u)" >> .env
echo "GID=$(id -g)" >> .env
```

Reconstruye los contenedores:
```bash
docker compose -f compose.dev.yaml down
docker compose -f compose.dev.yaml up -d --build
```

### MySQL no inicia

Verifica los logs:
```bash
docker compose -f compose.dev.yaml logs mysql
```

Revisa el archivo de error:
```bash
cat storage/logs/mysql/mysql-error.log
```

Elimina el volumen y vuelve a crear:
```bash
docker compose -f compose.dev.yaml down -v
docker compose -f compose.dev.yaml up -d
```

### PostgreSQL no inicia

Verifica los logs:
```bash
docker compose -f compose.dev.yaml logs postgres
```

Elimina el volumen y vuelve a crear:
```bash
docker compose -f compose.dev.yaml down -v
docker compose -f compose.dev.yaml up -d
```

### Error de conexión a MySQL desde Laravel

Asegúrate de usar el nombre del servicio Docker en `.env`:
```env
DB_HOST=mysql  # NO uses localhost o 127.0.0.1
DB_PORT=3306
```

### phpMyAdmin no puede conectarse a MySQL

Verifica que MySQL esté saludable:
```bash
docker compose -f compose.dev.yaml ps mysql
```

Debe mostrar "healthy" en la columna STATUS.

### Error "No application encryption key has been specified"

Genera la clave:
```bash
docker compose -f compose.dev.yaml exec -u www workspace php artisan key:generate
```

### Los cambios en el código no se reflejan

Limpia la caché de Laravel:
```bash
docker compose -f compose.dev.yaml exec -u www workspace php artisan optimize:clear
```

## 📚 Recursos

- [Documentación oficial de Docker](https://docs.docker.com/)
- [Guía de Laravel con Docker](https://docs.docker.com/guides/frameworks/laravel/development-setup/)
- [Documentación de Laravel 12](https://laravel.com/docs/12.x)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)

## 📝 Notas

- Este entorno está optimizado para **desarrollo**, no para producción
- **MySQL 8.4 LTS** es la base de datos predeterminada
- **PostgreSQL 16** está disponible como alternativa
- Slow Query Log captura automáticamente queries > 1 segundo
- Performance Schema está habilitado para monitoreo avanzado
- Los archivos se montan como volúmenes para permitir hot-reload
- Las dependencias se instalan dentro del contenedor workspace
- Redis está configurado para sesiones y caché por defecto
- El workspace incluye Xdebug para debugging
- phpMyAdmin está disponible para gestión visual de MySQL

## 📊 Archivos de Configuración MySQL

- **Configuración personalizada**: `docker/development/mysql/my.cnf`
- **Slow Query Log**: `storage/logs/mysql/mysql-slow.log`
- **Error Log**: `storage/logs/mysql/mysql-error.log`
- **Script de monitoreo**: `scripts/mysql-monitor.sh`

Estos archivos están excluidos del control de versiones via `.gitignore`.

---

**¿Necesitas ayuda?** Abre un issue o consulta la documentación oficial.

