# Configuración de MCPs (Model Context Protocol)

Este proyecto utiliza varios MCPs para mejorar la experiencia de desarrollo con Cursor.

## 📋 Variables de Entorno Requeridas

Para que los MCPs funcionen correctamente, necesitas agregar las siguientes variables a tu archivo `.env`:

### 1. Postman MCP

```bash
# Postman MCP
# Obtén tu API key de: https://www.postman.com/settings/me/api-keys
POSTMAN_API_KEY=your_postman_api_key_here
```

### 2. Base de Datos (Postgres y BD MCPs)

Estas variables ya deberían estar en tu `.env` de Laravel:

```bash
# Database
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
```

Los MCPs de Postgres y BD usarán automáticamente estas variables.

## 🔧 Configuración por Desarrollador

### Paso 1: Copiar el archivo de ejemplo

```bash
cp .env.example .env
```

### Paso 2: Configurar Postman API Key

1. Ve a https://www.postman.com/settings/me/api-keys
2. Crea un nuevo API Key
3. Copia el key generado
4. Pégalo en tu `.env`:

```bash
POSTMAN_API_KEY=PMAK-tu-api-key-aqui
```

### Paso 3: Verificar credenciales de base de datos

Asegúrate de que las credenciales de la base de datos coincidan con tu configuración de Docker en `compose.dev.yaml`:

```bash
DB_HOST=postgres      # Nombre del servicio en Docker
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
```

## 📝 Agregar al .env.example

Si el archivo `.env.example` no existe, créalo con este contenido:

```bash
# Application
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_TIMEZONE=UTC
APP_URL=http://localhost:8000

# Database
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

# ==============================================================================
# MCP (Model Context Protocol) Configuration
# ==============================================================================

# Postman MCP
# Obtén tu API key de: https://www.postman.com/settings/me/api-keys
POSTMAN_API_KEY=your_postman_api_key_here
```

## 🔒 Seguridad

**IMPORTANTE:**
- ❌ **NUNCA** subas tu archivo `.env` al repositorio
- ❌ **NUNCA** compartas tus API keys
- ✅ **SIEMPRE** usa el `.env.example` como plantilla
- ✅ **SIEMPRE** mantén tus credenciales locales

El archivo `.env` debe estar en tu `.gitignore`.

## ✅ MCPs Configurados

### 1. **Context7** (Upstash)
- No requiere configuración adicional
- Se ejecuta con: `npx -y @upstash/context7-mcp`

### 2. **Postgres**
- Usa las variables: `DB_USERNAME`, `DB_PASSWORD`, `DB_PORT`, `DB_DATABASE`
- Se conecta a través de Docker

### 3. **Postman**
- Requiere: `POSTMAN_API_KEY`
- Permite gestionar colecciones, entornos, mocks, etc.

### 4. **BD (Base de Datos)**
- Usa las mismas variables que Postgres
- Proporciona queries en lenguaje natural

### 5. **Atlassian (Jira/Confluence)**
- No requiere API key (usa OAuth)
- Se autentica a través del navegador

## 🧪 Verificar Configuración

Para verificar que los MCPs están configurados correctamente:

1. Abre Cursor
2. Los MCPs deberían aparecer automáticamente disponibles
3. Prueba ejecutar un comando que use algún MCP (ej: `/revisar-tareas`)

Si tienes problemas, verifica:
- ✅ Que tu `.env` tenga las variables necesarias
- ✅ Que Docker esté corriendo (`make ps`)
- ✅ Que las credenciales sean correctas

