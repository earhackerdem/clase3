# ⚡ Inicio Rápido - Laravel 12 con Docker

> **📌 Nota:** Si es la primera vez que usas este proyecto, comienza por el **[README.md](README.md)** que tiene instrucciones de instalación paso a paso. Este documento proporciona detalles adicionales sobre el funcionamiento del entorno.

---

## 🎯 Configuración Completa del Entorno

¡Tu proyecto Laravel 12 ya está completamente configurado con Docker y PostgreSQL! 

---

## 📦 ¿Qué se ha configurado?

✅ **Docker Compose** con arquitectura multi-etapa (desarrollo + producción)
✅ **PHP 8.2-FPM** con todas las extensiones necesarias para Laravel
✅ **PostgreSQL 16** como base de datos principal
✅ **Redis** para caché y sesiones
✅ **Nginx** como servidor web
✅ **Workspace** con PHP CLI, Composer, Node.js 22 y herramientas de desarrollo
✅ **Xdebug** configurado para debugging
✅ **Hot reload** de archivos durante el desarrollo

---

## 🚀 Iniciar el Entorno (3 opciones)

### Opción 1: Script Automático (MÁS FÁCIL) ⭐

```bash
./docker-setup.sh
```

Este script hace todo automáticamente:
- Crea el archivo `.env`
- Construye las imágenes Docker
- Levanta los contenedores
- Instala dependencias (Composer + npm)
- Genera la APP_KEY
- Ejecuta las migraciones
- Construye los assets

**Tiempo estimado:** 5-10 minutos (primera vez)

---

### Opción 2: Usar Makefile (RECOMENDADO)

```bash
# Configuración inicial completa
make setup

# Ver todos los comandos disponibles
make help
```

El Makefile incluye atajos para todos los comandos comunes:
- `make up` - Levantar contenedores
- `make down` - Detener contenedores
- `make shell` - Acceder al workspace
- `make migrate` - Ejecutar migraciones
- `make test` - Ejecutar tests
- Y muchos más...

---

### Opción 3: Manual

```bash
# 1. Crear archivo de entorno
cp .env.example .env

# 2. Levantar contenedores
docker compose -f compose.dev.yaml up -d --build

# 3. Instalar dependencias de Composer
docker compose -f compose.dev.yaml exec -u www workspace composer install

# 4. Generar APP_KEY
docker compose -f compose.dev.yaml exec -u www workspace php artisan key:generate

# 5. Ejecutar migraciones
docker compose -f compose.dev.yaml exec -u www workspace php artisan migrate

# 6. Instalar dependencias de npm
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm install"

# 7. Construir assets
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm run build"
```

---

## 🌐 Acceso a tu Aplicación

Una vez iniciado el entorno:

| Servicio | URL/Conexión | Credenciales |
|----------|--------------|--------------|
| **🌐 Aplicación Laravel** | http://localhost:8000 | - |
| **🐘 PostgreSQL** | localhost:5432 | Usuario: `laravel`<br>Password: `secret`<br>Base de datos: `laravel` |
| **🔴 Redis** | localhost:6379 | Sin password |

---

## 🛠️ Comandos Más Útiles

### Con Makefile (recomendado)
```bash
make shell          # Acceder al workspace
make artisan CMD="migrate"  # Ejecutar artisan
make composer CMD="require package/name"  # Instalar paquete
make npm CMD="run dev"  # Ejecutar npm
make test           # Ejecutar tests
make logs           # Ver logs
```

### Con Docker Compose directo
```bash
# Acceder al workspace
docker compose -f compose.dev.yaml exec -u www workspace bash

# Ejecutar comandos Artisan
docker compose -f compose.dev.yaml exec -u www workspace php artisan migrate

# Ver logs
docker compose -f compose.dev.yaml logs -f

# Detener todo
docker compose -f compose.dev.yaml down
```

---

## 📋 Checklist de Verificación

Después de iniciar, verifica que todo funciona:

```bash
# ✅ 1. Verificar que los contenedores están corriendo
docker compose -f compose.dev.yaml ps

# ✅ 2. Acceder a la aplicación
curl http://localhost:8000

# ✅ 3. Verificar conexión a PostgreSQL
docker compose -f compose.dev.yaml exec postgres psql -U laravel -d laravel -c "SELECT version();"

# ✅ 4. Verificar Redis
docker compose -f compose.dev.yaml exec redis redis-cli ping

# ✅ 5. Ejecutar un comando Artisan
docker compose -f compose.dev.yaml exec -u www workspace php artisan --version
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

3. Presiona F5 para iniciar el debugger
4. Coloca breakpoints en tu código
5. Recarga la página en el navegador

**Para deshabilitar Xdebug** (mejora el rendimiento):
```bash
# Editar .env
XDEBUG_ENABLED=false

# Reconstruir contenedores
docker compose -f compose.dev.yaml up -d --build php-fpm workspace
```

---

## 🎨 Desarrollo Frontend

```bash
# Instalar paquetes npm
make npm CMD="install package-name"

# Modo desarrollo (watch)
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm run dev"

# Build para producción
make npm CMD="run build"
```

---

## 💾 Gestión de Base de Datos

```bash
# Crear migración
make artisan CMD="make:migration create_products_table"

# Ejecutar migraciones
make migrate

# Revertir última migración
make rollback

# Refrescar base de datos (¡CUIDADO! Elimina todos los datos)
make fresh

# Refrescar y ejecutar seeders
make fresh-seed

# Acceder a PostgreSQL CLI
make db-shell
```

---

## 🧪 Testing

```bash
# Ejecutar todos los tests
make test

# Ejecutar tests con PHPUnit directamente
docker compose -f compose.dev.yaml exec -u www workspace ./vendor/bin/phpunit

# Ejecutar tests específicos
docker compose -f compose.dev.yaml exec -u www workspace php artisan test --filter=UserTest
```

---

## 🚨 Solución de Problemas Comunes

### Error: "No application encryption key"
```bash
make artisan CMD="key:generate"
```

### Los cambios no se reflejan
```bash
make clear  # Limpiar caché
```

### Problemas de permisos
```bash
# Verificar UID/GID en .env
echo "UID=$(id -u)" >> .env
echo "GID=$(id -g)" >> .env

# Reconstruir contenedores
docker compose -f compose.dev.yaml down
docker compose -f compose.dev.yaml up -d --build
```

### PostgreSQL no inicia
```bash
# Ver logs
docker compose -f compose.dev.yaml logs postgres

# Eliminar volumen y reiniciar
docker compose -f compose.dev.yaml down -v
docker compose -f compose.dev.yaml up -d
```

### Resetear todo el entorno
```bash
make clean  # Elimina contenedores y volúmenes
make setup  # Configura todo de nuevo
```

---

## 📚 Documentación Adicional

- **README.Docker.md** - Documentación completa y detallada
- **Makefile** - Lista completa de comandos disponibles
- **docker-setup.sh** - Script de configuración automática

---

## 🎯 Próximos Pasos

1. ✅ Inicia el entorno con `./docker-setup.sh` o `make setup`
2. 🌐 Accede a http://localhost:8000
3. 📝 Comienza a desarrollar tu aplicación
4. 🐛 Usa Xdebug para debugging
5. 🧪 Ejecuta tests con `make test`

---

## 💡 Tips de Productividad

1. **Usa el Makefile** para comandos rápidos: `make shell`, `make test`, etc.
2. **Mantén los logs abiertos** durante desarrollo: `make logs`
3. **Deshabilita Xdebug** si no lo necesitas para mejor rendimiento
4. **Usa alias** en tu shell para comandos frecuentes:
   ```bash
   alias dexec='docker compose -f compose.dev.yaml exec -u www workspace'
   alias dartisan='dexec php artisan'
   ```

---

## 🎉 ¡Todo Listo!

Tu entorno de desarrollo Laravel 12 con Docker y PostgreSQL está completamente configurado y listo para usar.

**¿Necesitas ayuda?** Revisa `README.Docker.md` para documentación completa.

---

**Creado con ❤️ para desarrollo con Laravel + Docker + PostgreSQL**

