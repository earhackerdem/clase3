# Demostración de Refactorización - API de Tareas

## 📋 Descripción

Este proyecto contiene **intencionalmente código con malas prácticas** en el archivo `routes/api.php` para demostrar la importancia de la refactorización y las buenas prácticas en Laravel.

## 🚫 Malas Prácticas Implementadas

### 1. **Validación Manual Campo por Campo**

❌ **MAL:**
```php
if (!$request->has('title') || $request->input('title') === '') {
    return response()->json([
        'message' => 'El campo title es requerido.',
    ], 422);
}

if (strlen($request->input('title')) > 255) {
    return response()->json([
        'message' => 'El title no debe ser mayor a 255 caracteres.',
    ], 422);
}
```

✅ **BIEN:**
```php
// Usar FormRequest
class StoreTaskRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'sometimes|in:pendiente,en progreso,completada',
        ];
    }
}
```

**Problemas:**
- Código verboso y difícil de mantener
- Validación dispersa y repetitiva
- No se aprovecha el sistema de validación de Laravel
- Mensajes de error inconsistentes

---

### 2. **Lógica de Negocio Mezclada con Definición de Rutas**

❌ **MAL:**
```php
Route::post('/tasks', function (Request $request) {
    // Validación...
    
    try {
        $task = new Task();
        $task->title = $request->input('title');
        $task->description = $request->input('description');
        $task->status = $request->input('status', 'pendiente');
        $task->save();
        
        return response()->json([...], 201);
    } catch (\Exception $e) {
        return response()->json([...], 500);
    }
});
```

✅ **BIEN:**
```php
// En routes/api.php
Route::post('/tasks', [TaskController::class, 'store']);

// En TaskController.php
public function store(StoreTaskRequest $request): JsonResponse
{
    $task = Task::create($request->validated());
    
    return (new TaskResource($task))
        ->response()
        ->setStatusCode(201);
}
```

**Problemas:**
- Violación del principio de responsabilidad única (SRP)
- Archivo de rutas difícil de leer y mantener
- Imposible reutilizar lógica
- Difícil de testear aisladamente

---

### 3. **Código Duplicado**

❌ **MAL:**
```php
// En POST /tasks
$allowedStatus = ['pendiente', 'en progreso', 'completada'];
if ($request->has('status') && !in_array($request->input('status'), $allowedStatus)) {
    // ...
}

// En PUT /tasks/{id}
$allowedStatus = ['pendiente', 'en progreso', 'completada'];
if ($request->has('status') && !in_array($request->input('status'), $allowedStatus)) {
    // ...
}
```

✅ **BIEN:**
```php
// La validación se define una vez en StoreTaskRequest
// y se reutiliza donde sea necesario
```

**Problemas:**
- Violación del principio DRY (Don't Repeat Yourself)
- Si cambian las reglas, hay que modificar múltiples lugares
- Mayor probabilidad de inconsistencias

---

### 4. **Respuestas Inconsistentes**

❌ **MAL:**
```php
// POST /tasks
return response()->json(['data' => [...]], 201);

// GET /tasks
return response()->json([...], 200);

// GET /tasks/{id}
return response()->json(['task' => [...]], 200);

// PUT /tasks/{id}
return response()->json(['success' => true, 'data' => ...], 200);

// DELETE /tasks/{id}
return response()->json(['mensaje' => '...', 'deleted_id' => $id], 200);
```

✅ **BIEN:**
```php
// Usar Resources para formato consistente
return new TaskResource($task);
return TaskResource::collection($tasks);
```

**Problemas:**
- API difícil de consumir
- Clientes deben manejar múltiples formatos
- No hay estándar en la respuesta

---

### 5. **Manejo de Errores Genérico**

❌ **MAL:**
```php
catch (\Exception $e) {
    return response()->json([
        'message' => 'Ocurrió un error inesperado.',
        'error' => $e->getMessage()
    ], 500);
}
```

✅ **BIEN:**
```php
// Laravel maneja automáticamente las excepciones
// Se pueden crear excepciones específicas y handlers personalizados
```

**Problemas:**
- Expone detalles internos del sistema
- No distingue entre tipos de errores
- Difícil de debuggear
- Posible vulnerabilidad de seguridad

---

### 6. **Sin Separación de Responsabilidades**

❌ **MAL:**
```php
// Todo en una función anónima en routes/api.php
Route::post('/tasks', function (Request $request) {
    // Validación
    // Lógica de negocio
    // Acceso a base de datos
    // Formateo de respuesta
    // Manejo de errores
});
```

✅ **BIEN:**
```php
// routes/api.php - Solo define rutas
Route::post('/tasks', [TaskController::class, 'store']);

// StoreTaskRequest.php - Maneja validación
// TaskController.php - Coordina la operación
// Task.php (Model) - Lógica del modelo
// TaskResource.php - Formateo de respuesta
```

**Problemas:**
- Difícil de testear
- Imposible de reutilizar
- Difícil de mantener
- No sigue patrones de diseño establecidos

---

### 7. **Sin Paginación ni Filtros**

❌ **MAL:**
```php
Route::get('/tasks', function () {
    $tasks = Task::all(); // Obtiene TODAS las tareas
    return response()->json($tasks, 200);
});
```

✅ **BIEN:**
```php
public function index(Request $request)
{
    return TaskResource::collection(
        Task::query()
            ->when($request->status, fn($q, $status) => $q->where('status', $status))
            ->paginate(15)
    );
}
```

**Problemas:**
- No escala con muchos registros
- Mal rendimiento
- Experiencia de usuario pobre

---

## 📊 Endpoints Implementados (con malas prácticas)

| Método | Endpoint | Descripción | Estado |
|--------|----------|-------------|---------|
| POST | `/api/tasks` | Crear tarea | ✅ Con tests |
| GET | `/api/tasks` | Listar tareas | ✅ |
| GET | `/api/tasks/{id}` | Obtener tarea | ✅ |
| PUT | `/api/tasks/{id}` | Actualizar tarea | ✅ |
| DELETE | `/api/tasks/{id}` | Eliminar tarea | ✅ |

## 🧪 Tests

Todos los tests existentes pasan correctamente:

```bash
php artisan test --filter TaskApiTest
```

```
✓ can create task successfully
✓ can create task without description
✓ can create task without status
✓ fails when title is empty
✓ fails when title exceeds max length
✓ fails when status is invalid
✓ accepts all valid status

Tests: 7 passed (30 assertions)
```

## 🔄 Plan de Refactorización

### Fase 1: Separar Responsabilidades
1. Crear `TaskController` con métodos CRUD
2. Mover lógica de rutas a controlador

### Fase 2: Implementar Validación Correcta
1. Crear `StoreTaskRequest` para POST
2. Crear `UpdateTaskRequest` para PUT
3. Eliminar validación manual

### Fase 3: Estandarizar Respuestas
1. Crear/usar `TaskResource` para formatear respuestas
2. Asegurar formato consistente en todos los endpoints

### Fase 4: Mejorar Consultas
1. Agregar paginación a listado
2. Implementar filtros
3. Optimizar queries

### Fase 5: Mejorar Manejo de Errores
1. Implementar excepciones específicas
2. Crear handlers personalizados
3. Eliminar exposición de errores internos

## 📝 Notas

- Este código es **intencionalmente malo** para fines educativos
- La versión refactorizada debe implementarse en el controlador
- Los tests deben pasar antes y después de la refactorización
- Este es un ejemplo perfecto de **deuda técnica**

## 🎯 Objetivo de la Demostración

Mostrar cómo el código aparentemente "funcional" puede ser:
- Difícil de mantener
- Propenso a errores
- No escalable
- Difícil de testear
- No reutilizable

Y cómo la refactorización hacia buenas prácticas mejora:
- Mantenibilidad
- Testabilidad
- Escalabilidad
- Legibilidad
- Reutilización de código

---

**Archivo de rutas malo:** `routes/api.php`  
**Archivos con buenas prácticas:** `app/Http/Controllers/Api/TaskController.php`, `app/Http/Requests/StoreTaskRequest.php`, `app/Http/Resources/TaskResource.php`

