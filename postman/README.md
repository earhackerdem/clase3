# 📮 Postman Collections - Lidr Tasks API

Esta carpeta contiene las colecciones de Postman para probar la API de tareas del proyecto Lidr.

## 🚀 Colección en Postman Cloud

La colección ya está disponible en tu workspace de Postman:

- **Workspace:** LaravelAPI
- **Colección:** Lidr - Tasks API
- **Environment:** Lidr - Local Development

### 🔗 Enlaces Directos

- **Colección ID:** `56cbad24-57d8-47e2-b7cb-3e1dd1c92608`
- **Environment ID:** `31c785fc-41a2-46a0-a498-c9408565fcaa`

## 📂 Archivos Locales

Si prefieres importar manualmente, usa estos archivos:

- `Lidr_Tasks_API.postman_collection.json` - Colección completa con todos los endpoints
- `Lidr_Local_Environment.postman_environment.json` - Variables de entorno para desarrollo local

## 🎯 Endpoints Incluidos

### POST /api/tasks - Crear Tarea

**Request Body:**
```json
{
  "title": "Implementar autenticación de usuarios",
  "description": "Configurar sistema de autenticación con Laravel Sanctum",
  "status": "en progreso"
}
```

**Response (201):**
```json
{
  "data": {
    "id": 1,
    "title": "Implementar autenticación de usuarios",
    "description": "Configurar sistema de autenticación con Laravel Sanctum",
    "status": "en progreso",
    "created_at": "2025-10-07T23:17:17.000000Z",
    "updated_at": "2025-10-07T23:17:17.000000Z"
  }
}
```

## 🧪 Tests Automatizados

Cada request incluye tests automáticos de Postman que validan:

- ✅ Status code 201
- ✅ Estructura correcta de la respuesta
- ✅ Presencia de todos los campos requeridos
- ✅ Validación de datos

## 📝 Casos de Prueba Incluidos

1. **Crear Tarea** - Caso exitoso completo con todos los campos
2. **Crear Tarea - Sin Descripción** - Valida campos opcionales
3. **Crear Tarea - Error Validación** - Prueba error 422 sin título
4. **Crear Tarea - Status Inválido** - Prueba validación de status

## ⚙️ Variables de Entorno

### Local Development

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `base_url` | `http://localhost:8000` | URL base de la API local |
| `api_version` | `v1` | Versión de la API |

## 🔧 Cómo Usar

### Opción 1: Acceder desde Postman Cloud (Recomendado)

1. Abre Postman
2. Ve al workspace **LaravelAPI**
3. Busca la colección **Lidr - Tasks API**
4. Selecciona el environment **Lidr - Local Development**
5. ¡Listo para probar!

### Opción 2: Importar Archivos Locales

1. Abre Postman
2. Click en **Import**
3. Arrastra los archivos `.json` de esta carpeta
4. Selecciona el environment importado
5. ¡Listo para probar!

## 🔗 Referencias

- **GitHub:** https://github.com/earhackerdem/clase3
- **Jira:** SCRUM-1
- **Pull Request:** https://github.com/earhackerdem/clase3/pull/1

## 📊 Validaciones

La API implementa las siguientes validaciones:

- `title`: **required** | string | max:255
- `description`: **nullable** | string
- `status`: **sometimes** | in:pendiente,en progreso,completada

## 🎨 Estado de las Tareas

La API soporta tres estados para las tareas:

- `pendiente` - Estado inicial por defecto
- `en progreso` - Tarea en desarrollo
- `completada` - Tarea finalizada

---

**Creado para:** SCRUM-1 - Implementar endpoint POST /api/tasks  
**Fecha:** Octubre 2025  
**Autor:** Earvin Pérez
