# 📁 Configuración de Cursor para el Proyecto

Esta carpeta contiene toda la configuración personalizada de Cursor para el proyecto Laravel.

## 📂 Estructura

```
.cursor/
├── README.md              # Este archivo
├── MCP-SETUP.md          # Guía de configuración de MCPs
├── mcp.json              # Configuración de MCPs (compartida)
│
├── commands/             # Comandos personalizados
│   ├── revisar-tareas.md
│   ├── verificar-asignacion-y-ramas.md
│   ├── verificar-flujo.md
│   ├── verificar-flujo-trabajo.md
│   ├── asignar-tarea-prioritaria.md
│   ├── generar-daily-standup.md
│   └── generar-reporte-semanal.md
│
└── rules/                # Reglas de desarrollo (compartidas)
    ├── development-flow.mdc
    ├── environment-setup.mdc
    ├── git-workflow.mdc
    ├── testing-requirements.mdc
    ├── laravel-best-practices.mdc
    └── jira-integration.mdc
```

## 🎯 ¿Qué hay en esta carpeta?

### 1. **Reglas (`rules/*.mdc`)**
Reglas de desarrollo que Cursor aplica automáticamente. Definen:
- Flujo de trabajo estándar
- Buenas prácticas de Laravel
- Requisitos de testing
- Proceso de Git y PRs
- Integración con Jira

**Activación:** Todas tienen `alwaysApply: true`

### 2. **Comandos (`commands/*.md`)**
Comandos personalizados que puedes ejecutar con `/nombre-comando`:

| Comando | Descripción |
|---------|-------------|
| `/revisar-tareas` | Verifica que las tareas de Jira tengan descripciones completas |
| `/verificar-asignacion-y-ramas` | Detecta tareas sin asignar o sin rama de Git |
| `/verificar-flujo` | Auditoría completa (versión corta) |
| `/asignar-tarea-prioritaria` | Asigna automáticamente la tarea más prioritaria |
| `/generar-daily-standup` | Genera reporte para daily meetings |
| `/generar-reporte-semanal` | Genera reporte semanal del equipo |

### 3. **MCPs (`mcp.json`)**
Configuración de Model Context Protocol para herramientas externas:
- **Postgres** - Conexión a base de datos
- **Postman** - Gestión de APIs
- **Atlassian** - Integración con Jira/Confluence
- **BD** - Queries en lenguaje natural
- **Context7** - Búsqueda semántica

**⚠️ IMPORTANTE:** Lee `MCP-SETUP.md` para configurar tus credenciales locales.

## 🚀 Configuración Inicial

### Para nuevos desarrolladores:

1. **Configurar variables de entorno:**
   ```bash
   cp .env.example .env
   ```

2. **Agregar tu Postman API Key al `.env`:**
   ```bash
   POSTMAN_API_KEY=tu_api_key_aqui
   ```

3. **Verificar que las credenciales de DB coincidan con Docker:**
   ```bash
   DB_HOST=postgres
   DB_USERNAME=laravel
   DB_PASSWORD=secret
   ```

4. **Reiniciar Cursor** para que cargue la configuración.

## 📚 Documentación Detallada

- **MCPs:** Ver `MCP-SETUP.md` para instrucciones completas
- **Reglas:** Cada archivo `.mdc` en `rules/` tiene documentación inline
- **Comandos:** Cada archivo `.md` en `commands/` describe su funcionalidad

## 🔒 Seguridad

**NUNCA subas al repositorio:**
- ❌ Archivos `.env` con credenciales reales
- ❌ API keys o tokens personales
- ❌ Contraseñas de base de datos de producción

**SÍ puedes subir:**
- ✅ Este archivo de configuración (`mcp.json`) - usa variables de entorno
- ✅ Archivos `.env.example` - con valores de ejemplo
- ✅ Todas las reglas y comandos
- ✅ Esta documentación

## 🤝 Contribuir

Si agregas nuevas reglas o comandos:
1. Documenta su propósito claramente
2. Incluye ejemplos de uso
3. Actualiza este README si es necesario
4. Comparte con el equipo

## ❓ Problemas Comunes

### Los MCPs no funcionan
- Verifica que tu `.env` tenga todas las variables necesarias
- Reinicia Cursor
- Revisa que Docker esté corriendo (`make ps`)

### Los comandos no aparecen
- Asegúrate de que los archivos estén en `commands/`
- Reinicia Cursor
- Verifica que los archivos tengan extensión `.md`

### Las reglas no se aplican
- Verifica que tengan `alwaysApply: true` en el header
- Reinicia Cursor
- Verifica la sintaxis del archivo `.mdc`

## 📞 Contacto

Si tienes dudas sobre la configuración, contacta al equipo de desarrollo.

