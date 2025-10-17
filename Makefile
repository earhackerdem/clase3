# Makefile para Laravel 12 con Docker
# Facilita la ejecución de comandos comunes

.PHONY: help build up down restart logs shell artisan composer npm test migrate fresh seed

# Archivo de compose
COMPOSE_FILE = compose.dev.yaml
COMPOSE = docker compose -f $(COMPOSE_FILE)
EXEC = $(COMPOSE) exec -u www workspace
EXEC_BASH = $(EXEC) bash -c

# Colores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m # No Color

## help: Muestra esta ayuda
help:
	@echo "$(GREEN)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(GREEN)║         Laravel 12 Docker - Comandos Disponibles          ║$(NC)"
	@echo "$(GREEN)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)🏗️  Gestión de Contenedores:$(NC)"
	@echo "  make setup         - Configuración inicial completa"
	@echo "  make build         - Construir imágenes Docker"
	@echo "  make up            - Levantar contenedores"
	@echo "  make down          - Detener y eliminar contenedores"
	@echo "  make restart       - Reiniciar contenedores"
	@echo "  make stop          - Detener contenedores"
	@echo "  make start         - Iniciar contenedores detenidos"
	@echo "  make ps            - Ver estado de contenedores"
	@echo "  make logs          - Ver logs de todos los servicios"
	@echo ""
	@echo "$(YELLOW)🔧 Desarrollo:$(NC)"
	@echo "  make shell         - Acceder al workspace"
	@echo "  make artisan CMD=  - Ejecutar comando artisan"
	@echo "  make composer CMD= - Ejecutar comando composer"
	@echo "  make npm CMD=      - Ejecutar comando npm"
	@echo "  make test          - Ejecutar tests"
	@echo ""
	@echo "$(YELLOW)💾 Base de Datos:$(NC)"
	@echo "  make migrate       - Ejecutar migraciones"
	@echo "  make rollback      - Revertir última migración"
	@echo "  make fresh         - Refrescar base de datos"
	@echo "  make seed          - Ejecutar seeders"
	@echo "  make fresh-seed    - Refrescar DB y ejecutar seeders"
	@echo "  make mysql-shell   - Acceder a MySQL CLI"
	@echo "  make mysql-slow    - Ver slow query log"
	@echo "  make mysql-perf    - Ver performance stats"
	@echo "  make mysql-monitor - Monitoreo completo de MySQL"
	@echo "  make db-shell      - Acceder a PostgreSQL CLI"
	@echo ""
	@echo "$(YELLOW)🧹 Caché y Limpieza:$(NC)"
	@echo "  make clear         - Limpiar todas las cachés"
	@echo "  make optimize      - Optimizar aplicación"
	@echo "  make clean         - Limpiar todo (contenedores + volúmenes)"
	@echo ""

## setup: Configuración inicial completa del proyecto
setup:
	@echo "$(YELLOW)🚀 Configurando entorno de desarrollo...$(NC)"
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)📝 Creando archivo .env...$(NC)"; \
		cp .env.example .env; \
	fi
	@echo "$(YELLOW)🏗️  Construyendo imágenes...$(NC)"
	@$(COMPOSE) build
	@echo "$(YELLOW)🚢 Levantando contenedores...$(NC)"
	@$(COMPOSE) up -d
	@sleep 10
	@echo "$(YELLOW)📦 Instalando dependencias de Composer...$(NC)"
	@$(EXEC) composer install
	@echo "$(YELLOW)🔑 Generando APP_KEY...$(NC)"
	@$(EXEC) php artisan key:generate
	@echo "$(YELLOW)💾 Ejecutando migraciones...$(NC)"
	@$(EXEC) php artisan migrate --force
	@echo "$(YELLOW)📦 Instalando dependencias de npm...$(NC)"
	@$(EXEC_BASH) "source ~/.nvm/nvm.sh && npm install"
	@echo "$(YELLOW)🎨 Construyendo assets...$(NC)"
	@$(EXEC_BASH) "source ~/.nvm/nvm.sh && npm run build"
	@echo "$(YELLOW)🔗 Creando enlace simbólico para storage...$(NC)"
	@$(EXEC) php artisan storage:link
	@echo ""
	@echo "$(GREEN)✅ ¡Configuración completada!$(NC)"
	@echo "$(GREEN)🌐 Aplicación disponible en: http://localhost:8000$(NC)"

## build: Construir imágenes Docker
build:
	@echo "$(YELLOW)🏗️  Construyendo imágenes Docker...$(NC)"
	@$(COMPOSE) build

## up: Levantar contenedores en modo detached
up:
	@echo "$(YELLOW)🚢 Levantando contenedores...$(NC)"
	@$(COMPOSE) up -d
	@echo "$(GREEN)✅ Contenedores iniciados$(NC)"
	@echo "$(GREEN)🌐 Aplicación: http://localhost:8000$(NC)"

## down: Detener y eliminar contenedores
down:
	@echo "$(YELLOW)🛑 Deteniendo contenedores...$(NC)"
	@$(COMPOSE) down
	@echo "$(GREEN)✅ Contenedores detenidos$(NC)"

## restart: Reiniciar contenedores
restart:
	@echo "$(YELLOW)🔄 Reiniciando contenedores...$(NC)"
	@$(COMPOSE) restart
	@echo "$(GREEN)✅ Contenedores reiniciados$(NC)"

## stop: Detener contenedores sin eliminarlos
stop:
	@echo "$(YELLOW)⏸️  Deteniendo contenedores...$(NC)"
	@$(COMPOSE) stop

## start: Iniciar contenedores detenidos
start:
	@echo "$(YELLOW)▶️  Iniciando contenedores...$(NC)"
	@$(COMPOSE) start

## ps: Ver estado de los contenedores
ps:
	@$(COMPOSE) ps

## logs: Ver logs de todos los servicios
logs:
	@$(COMPOSE) logs -f

## shell: Acceder al workspace
shell:
	@echo "$(GREEN)🐚 Accediendo al workspace...$(NC)"
	@$(COMPOSE) exec -u www workspace bash

## artisan: Ejecutar comando artisan (uso: make artisan CMD="migrate")
artisan:
	@$(EXEC) php artisan $(CMD)

## composer: Ejecutar comando composer (uso: make composer CMD="require package")
composer:
	@$(EXEC) composer $(CMD)

## npm: Ejecutar comando npm (uso: make npm CMD="install")
npm:
	@$(EXEC_BASH) "source ~/.nvm/nvm.sh && npm $(CMD)"

## test: Ejecutar tests
test:
	@echo "$(YELLOW)🧪 Ejecutando tests...$(NC)"
	@$(EXEC) php artisan test

## migrate: Ejecutar migraciones
migrate:
	@echo "$(YELLOW)💾 Ejecutando migraciones...$(NC)"
	@$(EXEC) php artisan migrate
	@echo "$(GREEN)✅ Migraciones completadas$(NC)"

## rollback: Revertir última migración
rollback:
	@echo "$(YELLOW)⏪ Revirtiendo migraciones...$(NC)"
	@$(EXEC) php artisan migrate:rollback

## fresh: Refrescar base de datos
fresh:
	@echo "$(YELLOW)🔄 Refrescando base de datos...$(NC)"
	@$(EXEC) php artisan migrate:fresh
	@echo "$(GREEN)✅ Base de datos refrescada$(NC)"

## seed: Ejecutar seeders
seed:
	@echo "$(YELLOW)🌱 Ejecutando seeders...$(NC)"
	@$(EXEC) php artisan db:seed
	@echo "$(GREEN)✅ Seeders completados$(NC)"

## fresh-seed: Refrescar DB y ejecutar seeders
fresh-seed:
	@echo "$(YELLOW)🔄 Refrescando base de datos y ejecutando seeders...$(NC)"
	@$(EXEC) php artisan migrate:fresh --seed
	@echo "$(GREEN)✅ Base de datos refrescada y sembrada$(NC)"

## mysql-shell: Acceder a MySQL CLI
mysql-shell:
	@echo "$(GREEN)🐬 Accediendo a MySQL...$(NC)"
	@$(COMPOSE) exec mysql mysql -u laravel -psecret laravel

## mysql-slow: Ver slow query log
mysql-slow:
	@echo "$(YELLOW)🐌 Visualizando slow query log...$(NC)"
	@if [ -f storage/logs/mysql/mysql-slow.log ]; then \
		tail -n 50 storage/logs/mysql/mysql-slow.log; \
	else \
		echo "$(RED)No se encontró el archivo de slow query log$(NC)"; \
	fi

## mysql-perf: Ver performance stats desde Performance Schema
mysql-perf:
	@echo "$(YELLOW)📊 Performance Statistics (Top 10 Slowest Queries):$(NC)"
	@$(COMPOSE) exec mysql mysql -u root -proot_secret -e "\
		SELECT \
			DIGEST_TEXT as query, \
			COUNT_STAR as exec_count, \
			ROUND(AVG_TIMER_WAIT/1000000000000, 2) as avg_time_sec, \
			ROUND(SUM_TIMER_WAIT/1000000000000, 2) as total_time_sec \
		FROM performance_schema.events_statements_summary_by_digest \
		WHERE DIGEST_TEXT IS NOT NULL \
		ORDER BY SUM_TIMER_WAIT DESC \
		LIMIT 10;"

## mysql-monitor: Ejecutar script de monitoreo completo de MySQL
mysql-monitor:
	@./scripts/mysql-monitor.sh all

## db-shell: Acceder a PostgreSQL CLI
db-shell:
	@echo "$(GREEN)🐘 Accediendo a PostgreSQL...$(NC)"
	@$(COMPOSE) exec postgres psql -U laravel -d laravel

## clear: Limpiar todas las cachés
clear:
	@echo "$(YELLOW)🧹 Limpiando cachés...$(NC)"
	@$(EXEC) php artisan optimize:clear
	@echo "$(GREEN)✅ Cachés limpiadas$(NC)"

## optimize: Optimizar aplicación
optimize:
	@echo "$(YELLOW)⚡ Optimizando aplicación...$(NC)"
	@$(EXEC) php artisan config:cache
	@$(EXEC) php artisan route:cache
	@$(EXEC) php artisan view:cache
	@echo "$(GREEN)✅ Aplicación optimizada$(NC)"

## clean: Limpiar todo (contenedores + volúmenes)
clean:
	@echo "$(RED)⚠️  Esta acción eliminará todos los contenedores y volúmenes$(NC)"
	@read -p "¿Estás seguro? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(YELLOW)🗑️  Limpiando todo...$(NC)"; \
		$(COMPOSE) down -v; \
		echo "$(GREEN)✅ Limpieza completada$(NC)"; \
	fi

## install: Alias para setup
install: setup

## dev: Levantar contenedores y ver logs
dev: up logs

.DEFAULT_GOAL := help

