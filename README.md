# Laravel 12 con Docker + MySQL

<p align="center">
<a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a>
</p>

Este es un proyecto Laravel 12 completamente configurado con Docker, MySQL 8.4, PostgreSQL 16, Redis y Nginx. El entorno está optimizado para desarrollo con hot-reload, Xdebug, monitoreo de performance y todas las herramientas necesarias.

---

## 🚀 Inicio Rápido

### Requisitos Previos

- Docker Engine 20.10+
- Docker Compose v2+
- Git

### Instalación (Primera Vez)

```bash
# 1. Clonar el repositorio
git clone <tu-repositorio>
cd clase3

# 2. Ejecutar el script de configuración
./docker-setup.sh
```

El script automáticamente:
- ✅ Crea el archivo `.env` desde `.env.example`
- ✅ Detecta y configura permisos (UID/GID)
- ✅ Construye las imágenes Docker
- ✅ Levanta todos los contenedores
- ✅ Instala dependencias de Composer
- ✅ Genera la APP_KEY
- ✅ Ejecuta las migraciones
- ✅ Instala dependencias de npm
- ✅ Construye los assets

**Tiempo estimado:** 5-10 minutos

### Acceso a la Aplicación

Una vez completada la instalación:

- **🌐 Aplicación Web:** http://localhost:8000
- **🔧 phpMyAdmin:** http://localhost:8080
- **🐬 MySQL:** localhost:3306 (base de datos predeterminada)
- **🐘 PostgreSQL:** localhost:5432 (alternativa)
- **🔴 Redis:** localhost:6379

---

## 🛠️ Uso Diario

### Iniciar el Entorno

```bash
# Usando Makefile (recomendado)
make up

# O con Docker Compose
docker compose -f compose.dev.yaml up -d
```

### Detener el Entorno

```bash
# Usando Makefile
make down

# O con Docker Compose
docker compose -f compose.dev.yaml down
```

### Comandos Útiles

```bash
# Ver todos los comandos disponibles
make help

# Ver estado de los servicios
make ps

# Ver logs en tiempo real
make logs

# Acceder al workspace
make shell

# Ejecutar comandos Artisan
make artisan CMD="migrate"
make artisan CMD="make:model Product"

# Ejecutar tests
make test

# Limpiar cachés
make clear

# Reiniciar servicios
make restart
```

---

## 📦 Servicios Incluidos

| Servicio | Tecnología | Puerto | Descripción |
|----------|------------|--------|-------------|
| **web** | Nginx latest | 8000 | Servidor web optimizado |
| **php-fpm** | PHP 8.2-FPM | 9000 | Procesador PHP con extensiones |
| **workspace** | PHP 8.2 CLI | - | Herramientas de desarrollo |
| **mysql** | MySQL 8.4 LTS | 3306 | **Base de datos predeterminada** |
| **postgres** | PostgreSQL 16 | 5432 | Base de datos alternativa |
| **redis** | Redis Alpine | 6379 | Caché y sesiones |
| **phpmyadmin** | phpMyAdmin | 8080 | Interfaz web para MySQL |

### Características

- ✅ **Hot Reload:** Los cambios en el código se reflejan automáticamente
- ✅ **MySQL 8.4 LTS:** Base de datos predeterminada con monitoreo avanzado
- ✅ **Slow Query Log:** Queries > 1 segundo se registran automáticamente
- ✅ **Performance Schema:** Análisis detallado de rendimiento
- ✅ **phpMyAdmin:** Interfaz web para gestión de MySQL
- ✅ **PostgreSQL 16:** Disponible como alternativa
- ✅ **Xdebug:** Configurado para debugging (puerto 9003)
- ✅ **Node.js 22:** Incluido en workspace con NVM
- ✅ **Composer:** Última versión instalada
- ✅ **Multi-stage builds:** Imágenes optimizadas
- ✅ **Health checks:** Auto-reinicio de servicios
- ✅ **Persistencia:** Datos de MySQL y PostgreSQL persistentes

---

## 🔧 Configuración

### Variables de Entorno

El archivo `.env` se genera automáticamente desde `.env.example`. Configuración principal:

```bash
# Base de Datos (MySQL predeterminado)
DB_CONNECTION=mysql
DB_HOST=mysql         # Nombre del servicio Docker
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

# MySQL Adicional
MYSQL_ROOT_PASSWORD=root_secret
MYSQL_PORT=3306

# PostgreSQL (Alternativa)
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# phpMyAdmin
PHPMYADMIN_PORT=8080

# Redis
REDIS_HOST=redis      # Nombre del servicio Docker
REDIS_PORT=6379

# Docker
NGINX_PORT=8000
UID=1000
GID=1000

# Xdebug (desarrollo)
XDEBUG_ENABLED=true
XDEBUG_HOST=host.docker.internal
```

### Acceso a MySQL (Predeterminado)

**Desde tu host (MySQL Workbench, DBeaver, phpMyAdmin, etc.):**
```
Host: localhost
Puerto: 3306
Usuario: laravel
Contraseña: secret
Base de datos: laravel

# Para tareas administrativas
Root password: root_secret
```

**Desde otros contenedores Docker:**
```
Host: mysql
Puerto: 3306
Usuario: laravel
Contraseña: secret
Base de datos: laravel
```

**phpMyAdmin (interfaz web):**
```
URL: http://localhost:8080
Usuario: root
Contraseña: root_secret
```

### Acceso a PostgreSQL (Alternativa)

**Desde tu host (pgAdmin, DBeaver, etc.):**
```
Host: localhost
Puerto: 5432
Usuario: laravel
Contraseña: secret
Base de datos: laravel
```

**Desde otros contenedores Docker:**
```
Host: postgres
Puerto: 5432
Usuario: laravel
Contraseña: secret
Base de datos: laravel
```

**Para cambiar a PostgreSQL:**
Edita `.env` y cambia:
```bash
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
```
Luego ejecuta: `make fresh`

---

## 🐛 Debugging con Xdebug

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

3. Presiona **F5** para iniciar el debugger
4. Coloca breakpoints en tu código
5. Recarga la página en el navegador

### Deshabilitar Xdebug (mejor rendimiento)

Edita `.env`:
```bash
XDEBUG_ENABLED=false
```

Reconstruye los contenedores:
```bash
make build
make up
```

---

## 🗃️ Base de Datos

### Migraciones

```bash
# Ejecutar migraciones
make migrate

# Revertir última migración
make rollback

# Refrescar base de datos (⚠️ elimina datos)
make fresh

# Refrescar y ejecutar seeders
make fresh-seed
```

### Acceso a Consolas de Base de Datos

```bash
# MySQL CLI (base de datos predeterminada)
make mysql-shell

# PostgreSQL CLI (alternativa)
make db-shell

# O con Docker Compose
docker compose -f compose.dev.yaml exec mysql mysql -u laravel -psecret laravel
docker compose -f compose.dev.yaml exec postgres psql -U laravel -d laravel
```

### 📊 Monitoreo de Performance MySQL

El proyecto incluye herramientas avanzadas de monitoreo para MySQL:

```bash
# Ver queries lentas (> 1 segundo)
make mysql-slow

# Ver estadísticas de performance
make mysql-perf

# Monitoreo completo (slow queries, performance, conexiones, tablas)
make mysql-monitor

# O usar el script directamente
./scripts/mysql-monitor.sh all
./scripts/mysql-monitor.sh perf     # Solo performance
./scripts/mysql-monitor.sh slow     # Solo slow queries
./scripts/mysql-monitor.sh conn     # Solo conexiones
./scripts/mysql-monitor.sh tables   # Solo tablas
./scripts/mysql-monitor.sh innodb   # Solo InnoDB stats
./scripts/mysql-monitor.sh noindex  # Queries sin índices
```

**Características del Monitoreo:**
- 🐌 **Slow Query Log**: Queries > 1 segundo en `storage/logs/mysql/mysql-slow.log`
- 📈 **Performance Schema**: Análisis detallado de queries con tiempos de ejecución
- 🔍 **Detección de Queries sin Índices**: Identifica consultas que necesitan optimización
- 📊 **Estadísticas de InnoDB**: Buffer pool, cache hits, y métricas de rendimiento
- 🔌 **Monitoreo de Conexiones**: Conexiones activas, threads y estados

---

## 🎨 Frontend (Vite)

### Desarrollo

```bash
# Instalar dependencias
make npm CMD="install"

# Modo watch (desarrollo)
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm run dev"

# Build para producción
make npm CMD="run build"
```

---

## 🧪 Testing

```bash
# Ejecutar todos los tests
make test

# Ejecutar tests específicos
docker compose -f compose.dev.yaml exec -u www workspace php artisan test --filter=UserTest
```

---

## 📚 Documentación Adicional

Este proyecto incluye documentación detallada:

- **[INICIO-RAPIDO.md](INICIO-RAPIDO.md)** → ⚡ Guía de inicio rápido
- **[README.Docker.md](README.Docker.md)** → 📚 Documentación completa de Docker
- **[ARQUITECTURA.md](ARQUITECTURA.md)** → 🏗️ Diagramas y diseño del sistema
- **[RESUMEN-CONFIGURACION.md](RESUMEN-CONFIGURACION.md)** → ✅ Resumen de la configuración

---

## 🚨 Solución de Problemas

### Los cambios no se reflejan

```bash
make clear
```

### Error de permisos

Asegúrate de que UID/GID en `.env` coincidan con tu usuario:
```bash
echo "UID=$(id -u)" >> .env
echo "GID=$(id -g)" >> .env
make restart
```

### MySQL o PostgreSQL no inicia

```bash
# Ver logs de MySQL
docker compose -f compose.dev.yaml logs mysql

# Ver logs de PostgreSQL
docker compose -f compose.dev.yaml logs postgres

# Reiniciar con volúmenes limpios
make clean
make setup
```

### Error de conexión a MySQL

Verifica que `DB_HOST=mysql` en `.env` (no localhost):
```bash
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
```

### Error "No application encryption key"

```bash
make artisan CMD="key:generate"
```

---

## 🧹 Limpieza

### Reiniciar desde cero

```bash
# Elimina contenedores y volúmenes
make clean

# Configura todo de nuevo
make setup
```

---

## 📖 Sobre Laravel

Laravel es un framework de aplicaciones web con una sintaxis expresiva y elegante. Para más información:

- **Documentación:** https://laravel.com/docs
- **Laracasts:** https://laracasts.com
- **Laravel Bootcamp:** https://bootcamp.laravel.com

---

## 🤝 Contribuir

Si deseas contribuir a este proyecto, por favor:

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

## 🆘 Soporte

Si encuentras algún problema o tienes preguntas:

1. Revisa la [documentación](README.Docker.md)
2. Verifica los [logs](#-solución-de-problemas)
3. Abre un issue en el repositorio

---

**Desarrollado con ❤️ usando Laravel 12 + Docker + PostgreSQL**
