# Laravel 12 con Docker + PostgreSQL

<p align="center">
<a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a>
</p>

Este es un proyecto Laravel 12 completamente configurado con Docker, PostgreSQL 16, Redis y Nginx. El entorno está optimizado para desarrollo con hot-reload, Xdebug y todas las herramientas necesarias.

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
- **🐘 PostgreSQL:** localhost:5432
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
| **postgres** | PostgreSQL 16 | 5432 | Base de datos principal |
| **redis** | Redis Alpine | 6379 | Caché y sesiones |

### Características

- ✅ **Hot Reload:** Los cambios en el código se reflejan automáticamente
- ✅ **Xdebug:** Configurado para debugging (puerto 9003)
- ✅ **Node.js 22:** Incluido en workspace con NVM
- ✅ **Composer:** Última versión instalada
- ✅ **Multi-stage builds:** Imágenes optimizadas
- ✅ **Health checks:** Auto-reinicio de servicios
- ✅ **Persistencia:** Datos de PostgreSQL persistentes

---

## 🔧 Configuración

### Variables de Entorno

El archivo `.env` se genera automáticamente desde `.env.example`. Configuración principal:

```bash
# Base de Datos
DB_CONNECTION=pgsql
DB_HOST=postgres      # Nombre del servicio Docker
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

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

### Acceso a PostgreSQL

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

### Acceder a PostgreSQL CLI

```bash
# Usando Makefile
make db-shell

# O con Docker Compose
docker compose -f compose.dev.yaml exec postgres psql -U laravel -d laravel
```

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

### PostgreSQL no inicia

```bash
# Ver logs
docker compose -f compose.dev.yaml logs postgres

# Reiniciar con volúmenes limpios
make clean
make setup
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
