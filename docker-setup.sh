#!/bin/bash

# Script para inicializar el entorno de desarrollo con Docker
# Laravel 12 con PostgreSQL

set -e

echo "🚀 Inicializando entorno de desarrollo Laravel con Docker..."
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

# Construir y levantar los contenedores
echo ""
echo -e "${YELLOW}🏗️  Construyendo imágenes Docker (esto puede tomar varios minutos)...${NC}"
docker compose -f compose.dev.yaml build --no-cache

echo ""
echo -e "${YELLOW}🚢 Levantando contenedores...${NC}"
docker compose -f compose.dev.yaml up -d

echo ""
echo -e "${YELLOW}⏳ Esperando a que PostgreSQL esté listo...${NC}"
sleep 10

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
echo -e "   🌐 Aplicación: ${GREEN}http://localhost:8000${NC}"
echo -e "   🐘 PostgreSQL: ${GREEN}localhost:5432${NC}"
echo -e "      └─ Usuario: laravel"
echo -e "      └─ Contraseña: secret"
echo -e "      └─ Base de datos: laravel"
echo -e "   🔴 Redis: ${GREEN}localhost:6379${NC}"
echo ""
echo -e "${YELLOW}🛠️  Comandos útiles:${NC}"
echo -e "   Ver logs:           ${GREEN}docker compose -f compose.dev.yaml logs -f${NC}"
echo -e "   Detener:            ${GREEN}docker compose -f compose.dev.yaml stop${NC}"
echo -e "   Iniciar:            ${GREEN}docker compose -f compose.dev.yaml start${NC}"
echo -e "   Reiniciar:          ${GREEN}docker compose -f compose.dev.yaml restart${NC}"
echo -e "   Eliminar todo:      ${GREEN}docker compose -f compose.dev.yaml down -v${NC}"
echo ""
echo -e "   Entrar al workspace:  ${GREEN}docker compose -f compose.dev.yaml exec -u www workspace bash${NC}"
echo -e "   Ejecutar artisan:     ${GREEN}docker compose -f compose.dev.yaml exec -u www workspace php artisan${NC}"
echo -e "   Ejecutar composer:    ${GREEN}docker compose -f compose.dev.yaml exec -u www workspace composer${NC}"
echo -e "   Ejecutar npm:         ${GREEN}docker compose -f compose.dev.yaml exec -u www workspace bash -c 'source ~/.nvm/nvm.sh && npm'${NC}"
echo ""
echo -e "${GREEN}🎉 ¡Feliz desarrollo!${NC}"
echo ""

