# 🧪 Guía para Probar el Proyecto en Otra Computadora

Esta guía te ayudará a verificar que la configuración de Docker funcione correctamente al clonar el proyecto en una nueva máquina.

---

## ✅ Checklist de Verificación

### Pre-requisitos en la Nueva Máquina

Verifica que tengas instalado:

```bash
# Verificar Docker
docker --version
# Debe mostrar: Docker version 20.10+ o superior

# Verificar Docker Compose
docker compose version
# Debe mostrar: Docker Compose version v2.0+ o superior

# Verificar Git
git --version
```

---

## 🚀 Proceso de Instalación

### 1. Clonar el Repositorio

```bash
git clone <url-del-repositorio>
cd clase3
```

### 2. Verificar Archivos Necesarios

```bash
# Estos archivos DEBEN existir:
ls -la docker-setup.sh          # ✅ Script de configuración
ls -la .env.example              # ✅ Template de configuración
ls -la compose.dev.yaml          # ✅ Docker Compose
ls -la Makefile                  # ✅ Comandos simplificados
ls -la docker/                   # ✅ Configuraciones de Docker
```

### 3. Ejecutar el Script de Configuración

```bash
# Dar permisos de ejecución (si es necesario)
chmod +x docker-setup.sh

# Ejecutar el script
./docker-setup.sh
```

**⏱️ Tiempo esperado:** 5-10 minutos (primera vez)

El script debe:
- ✅ Crear el archivo `.env`
- ✅ Construir las imágenes Docker
- ✅ Levantar los contenedores
- ✅ Instalar dependencias
- ✅ Generar APP_KEY
- ✅ Ejecutar migraciones
- ✅ Construir assets

---

## 🔍 Verificaciones Post-Instalación

### 1. Verificar Contenedores

```bash
docker compose -f compose.dev.yaml ps
```

**Resultado esperado:**
```
NAME                 STATUS
clase3-web-1         Up
clase3-php-fpm-1     Up
clase3-postgres-1    Up (healthy)
clase3-redis-1       Up (healthy)
clase3-workspace-1   Up
```

✅ **Todos los contenedores deben estar "Up"**

### 2. Verificar Aplicación Web

```bash
curl http://localhost:8000
```

✅ **Debe mostrar HTML de Laravel (no errores 502 o 500)**

O abre en el navegador: **http://localhost:8000**

### 3. Verificar Conexión a PostgreSQL

```bash
docker compose -f compose.dev.yaml exec -u www workspace php artisan tinker --execute="echo 'Driver: ' . DB::connection()->getDriverName() . PHP_EOL; echo 'Database: ' . DB::connection()->getDatabaseName() . PHP_EOL;"
```

**Resultado esperado:**
```
Driver: pgsql
Database: laravel
```

✅ **Debe usar "pgsql", NO "sqlite"**

### 4. Verificar Tablas en PostgreSQL

```bash
docker compose -f compose.dev.yaml exec postgres psql -U laravel -d laravel -c "\dt"
```

**Resultado esperado:**
```
          List of relations
 Schema |         Name          | Type  | Owner
--------+-----------------------+-------+--------
 public | cache                 | table | laravel
 public | cache_locks           | table | laravel
 public | failed_jobs           | table | laravel
 public | job_batches           | table | laravel
 public | jobs                  | table | laravel
 public | migrations            | table | laravel
 public | password_reset_tokens | table | laravel
 public | sessions              | table | laravel
 public | users                 | table | laravel
```

✅ **Deben existir 9 tablas**

### 5. Verificar Redis

```bash
docker compose -f compose.dev.yaml exec redis redis-cli ping
```

**Resultado esperado:**
```
PONG
```

### 6. Verificar Assets Compilados

```bash
ls -la public/build/
```

**Resultado esperado:**
```
manifest.json
assets/app-*.css
assets/app-*.js
```

✅ **Los assets deben estar compilados**

---

## 🧪 Pruebas Funcionales

### Crear un Modelo de Prueba

```bash
# Acceder al workspace
docker compose -f compose.dev.yaml exec -u www workspace bash

# Crear modelo, migración y controlador
php artisan make:model Product -mc

# Salir
exit
```

✅ **No debe mostrar errores**

### Ejecutar Tests

```bash
make test
# o
docker compose -f compose.dev.yaml exec -u www workspace php artisan test
```

✅ **Los tests deben pasar**

---

## 📊 Puntos de Acceso

Una vez verificado todo, confirma estos accesos:

### Aplicación Web
- **URL:** http://localhost:8000
- **Debe mostrar:** Página de inicio de Laravel

### Base de Datos (desde tu host)
- **Host:** localhost
- **Puerto:** 5432
- **Usuario:** laravel
- **Contraseña:** secret
- **Base de datos:** laravel

Prueba con pgAdmin o DBeaver.

### Redis (desde tu host)
- **Host:** localhost
- **Puerto:** 6379

Prueba con RedisInsight o redis-cli.

---

## ❌ Problemas Comunes y Soluciones

### Error: "Port is already allocated"

**Problema:** Otro servicio usa el puerto 8000, 5432 o 6379

**Solución:**
```bash
# Detener servicio conflictivo o cambiar puerto en .env
echo "NGINX_PORT=8080" >> .env
make restart
```

### Error: "No application encryption key"

**Solución:**
```bash
docker compose -f compose.dev.yaml exec -u www workspace php artisan key:generate
```

### Error: Contenedores no inician

**Solución:**
```bash
# Ver logs
docker compose -f compose.dev.yaml logs

# Reiniciar desde cero
make clean
make setup
```

### Error: Sigue usando SQLite

**Solución:**
```bash
# Verificar que DB_HOST=postgres en .env
grep DB_HOST .env

# Si es 127.0.0.1, cambiar a postgres
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=postgres/' .env

# Reiniciar
make restart
```

### Error de permisos

**Solución:**
```bash
# Configurar UID/GID
echo "UID=$(id -u)" >> .env
echo "GID=$(id -g)" >> .env

# Reconstruir
make build
make up
```

---

## ✅ Checklist Final de Verificación

Marca cada punto al verificarlo:

- [ ] Docker y Docker Compose instalados
- [ ] Repositorio clonado correctamente
- [ ] Script `./docker-setup.sh` ejecutado sin errores
- [ ] 5 contenedores corriendo (web, php-fpm, postgres, redis, workspace)
- [ ] Aplicación accesible en http://localhost:8000
- [ ] Laravel conectado a PostgreSQL (no SQLite)
- [ ] 9 tablas creadas en PostgreSQL
- [ ] Redis responde con PONG
- [ ] Assets compilados en public/build/
- [ ] Tests pasan correctamente
- [ ] Puedes acceder al workspace
- [ ] Puedes ejecutar comandos Artisan

---

## 📝 Reporte de Problemas

Si encuentras algún problema durante la prueba, documenta:

1. **Sistema Operativo:** (Windows/macOS/Linux)
2. **Versiones:**
   - Docker: `docker --version`
   - Docker Compose: `docker compose version`
3. **Error exacto:** (logs, mensajes de error)
4. **Comando que falló:** (paso exacto)
5. **Logs relevantes:**
   ```bash
   docker compose -f compose.dev.yaml logs [servicio]
   ```

---

## 🎉 Si Todo Funciona

¡Felicitaciones! El proyecto está correctamente configurado y listo para desarrollo.

**Próximos pasos:**
1. Revisa el [README.md](README.md) para comandos diarios
2. Consulta [README.Docker.md](README.Docker.md) para detalles de Docker
3. Comienza a desarrollar tu aplicación

---

**¡Buena suerte con las pruebas!** 🚀

