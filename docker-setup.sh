#!/bin/bash

# Script para inicializar el entorno de desarrollo con Docker
# Laravel 12 con MySQL 8.4 (PostgreSQL también disponible)

set -e

echo "🚀 Inicializando entorno de desarrollo Laravel con Docker y MySQL..."
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado. Por favor, instala Docker primero.${NC}"
    exit 1
fi

# Verificar si Docker Compose está disponible
if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose no está disponible. Por favor, instala Docker Compose v2.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker y Docker Compose están instalados${NC}"

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    echo -e "${YELLOW}📝 Creando archivo .env desde .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Archivo .env creado${NC}"
else
    echo -e "${GREEN}✓ Archivo .env ya existe${NC}"
fi

# Obtener UID y GID del usuario actual
USER_UID=$(id -u)
USER_GID=$(id -g)

# Actualizar .env con los valores correctos de UID/GID
if grep -q "^UID=" .env; then
    sed -i "s/^UID=.*/UID=${USER_UID}/" .env
else
    echo "UID=${USER_UID}" >> .env
fi

if grep -q "^GID=" .env; then
    sed -i "s/^GID=.*/GID=${USER_GID}/" .env
else
    echo "GID=${USER_GID}" >> .env
fi

echo -e "${YELLOW}👤 Configurando permisos con UID=${USER_UID} y GID=${USER_GID}${NC}"

# Crear estructura de directorios de Laravel si no existe
echo ""
echo -e "${YELLOW}📁 Creando estructura de directorios de storage...${NC}"

# Crear directorios de storage/framework si no existen
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/framework/testing
mkdir -p storage/logs
mkdir -p storage/app/public
mkdir -p bootstrap/cache

# Establecer permisos correctos
chmod -R 775 storage bootstrap/cache
chown -R ${USER_UID}:${USER_GID} storage bootstrap/cache 2>/dev/null || true

echo -e "${GREEN}✓ Estructura de directorios de storage creada${NC}"

# Construir y levantar los contenedores
echo ""
echo -e "${YELLOW}🏗️  Construyendo imágenes Docker (esto puede tomar varios minutos)...${NC}"
docker compose -f compose.dev.yaml build --no-cache

echo ""
echo -e "${YELLOW}🚢 Levantando contenedores...${NC}"
docker compose -f compose.dev.yaml up -d

echo ""
echo -e "${YELLOW}⏳ Esperando a que MySQL y PostgreSQL estén listos...${NC}"
sleep 15

# Instalar dependencias de PHP
echo ""
echo -e "${YELLOW}📦 Instalando dependencias de Composer...${NC}"
docker compose -f compose.dev.yaml exec -u www workspace composer install

# Generar APP_KEY
echo ""
echo -e "${YELLOW}🔑 Generando APP_KEY...${NC}"
docker compose -f compose.dev.yaml exec -u www workspace php artisan key:generate

# Ejecutar migraciones
echo ""
echo -e "${YELLOW}💾 Ejecutando migraciones de base de datos...${NC}"
docker compose -f compose.dev.yaml exec -u www workspace php artisan migrate --force

# Instalar dependencias de Node
echo ""
echo -e "${YELLOW}📦 Instalando dependencias de npm...${NC}"
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm install"

# Construir assets
echo ""
echo -e "${YELLOW}🎨 Construyendo assets de frontend...${NC}"
docker compose -f compose.dev.yaml exec -u www workspace bash -c "source ~/.nvm/nvm.sh && npm run build"

# Crear enlace simbólico para storage
echo ""
echo -e "${YELLOW}🔗 Creando enlace simbólico para storage...${NC}"
docker compose -f compose.dev.yaml exec -u www workspace php artisan storage:link

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                           ║${NC}"
echo -e "${GREEN}║  ✅ ¡Entorno de desarrollo configurado exitosamente!     ║${NC}"
echo -e "${GREEN}║                                                           ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📋 Información del entorno:${NC}"
echo -e "   🌐 Aplicación Laravel: ${GREEN}http://localhost:8000${NC}"
echo ""
echo -e "   ${YELLOW}Bases de Datos:${NC}"
echo -e "   🐬 MySQL 8.4 (predeterminada): ${GREEN}localhost:3306${NC}"
echo -e "      └─ Usuario: laravel"
echo -e "      └─ Contraseña: secret"
echo -e "      └─ Base de datos: laravel"
echo -e "      └─ Root password: root_secret"
echo ""
echo -e "   🐘 PostgreSQL 16 (alternativa): ${GREEN}localhost:5432${NC}"
echo -e "      └─ Usuario: laravel"
echo -e "      └─ Contraseña: secret"
echo -e "      └─ Base de datos: laravel"
echo ""
echo -e "   ${YELLOW}Herramientas Web:${NC}"
echo -e "   🔧 phpMyAdmin: ${GREEN}http://localhost:8080${NC}"
echo -e "      └─ Usuario: root"
echo -e "      └─ Contraseña: root_secret"
echo ""
echo -e "   🔴 Redis: ${GREEN}localhost:6379${NC}"
echo ""
echo -e "${YELLOW}🛠️  Comandos útiles con Makefile:${NC}"
echo -e "   Ver ayuda:          ${GREEN}make help${NC}"
echo -e "   Ver logs:           ${GREEN}make logs${NC}"
echo -e "   Detener:            ${GREEN}make down${NC}"
echo -e "   Iniciar:            ${GREEN}make up${NC}"
echo -e "   Reiniciar:          ${GREEN}make restart${NC}"
echo -e "   Estado:             ${GREEN}make ps${NC}"
echo ""
echo -e "   Entrar al workspace: ${GREEN}make shell${NC}"
echo -e "   MySQL CLI:           ${GREEN}make mysql-shell${NC}"
echo -e "   PostgreSQL CLI:      ${GREEN}make db-shell${NC}"
echo -e "   Migraciones:         ${GREEN}make migrate${NC}"
echo -e "   Tests:               ${GREEN}make test${NC}"
echo ""
echo -e "${YELLOW}📊 Monitoreo de MySQL:${NC}"
echo -e "   Ver slow queries:    ${GREEN}make mysql-slow${NC}"
echo -e "   Performance stats:   ${GREEN}make mysql-perf${NC}"
echo -e "   Monitoreo completo:  ${GREEN}make mysql-monitor${NC}"
echo ""
echo -e "${GREEN}🎉 ¡Feliz desarrollo!${NC}"
echo ""

