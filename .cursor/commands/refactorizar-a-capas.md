# Refactorizar Endpoint a Arquitectura en Capas

## 🎯 Objetivo
Migrar un endpoint con lógica en closures de `routes/api.php` a arquitectura en capas siguiendo las buenas prácticas de Laravel 12.

## 📋 Antes de Empezar

### Verificar Estado Actual
```bash
# Ver el archivo de rutas actual
cat routes/api.php

# Contar líneas del endpoint a refactorizar
grep -A 50 "Route::post('/endpoint'" routes/api.php | wc -l
```

### Establecer Baseline
```bash
# Limpiar caché
make clear

# Ejecutar tests actuales
make test

# Guardar cobertura inicial
php artisan test --coverage > baseline-coverage.txt
```

## 🏗️ Proceso de Refactorización

### Fase 1: Crear Tests Faltantes (TDD)

**Si no existen tests para todos los verbos HTTP, créalos primero:**

```bash
# Editar archivo de tests
nano tests/Feature/NombreApiTest.php
```

**Estructura de tests necesarios:**
- `test_can_list_all_resources()` - GET /api/resource
- `test_can_show_single_resource()` - GET /api/resource/{id}
- `test_can_create_resource()` - POST /api/resource
- `test_can_update_resource()` - PUT /api/resource/{id}
- `test_can_delete_resource()` - DELETE /api/resource/{id}

**Patrón AAA obligatorio:**
```php
public function test_can_create_resource(): void
{
    // Arrange: Preparar datos
    $data = Resource::factory()->make()->toArray();
    
    // Act: Ejecutar acción
    $response = $this->postJson('/api/resources', $data);
    
    // Assert: Verificar resultado
    $response->assertStatus(201);
    $this->assertDatabaseHas('resources', ['title' => $data['title']]);
}
```

### Fase 2: Scaffolding con Artisan

```bash
# Acceder al workspace
make shell

# Generar archivos (NUNCA crearlos manualmente)
php artisan make:controller NombreController --api
php artisan make:request StoreNombreRequest
php artisan make:request UpdateNombreRequest
php artisan make:resource NombreResource
```

### Fase 3: Implementar Form Requests

**StoreNombreRequest.php:**
```php
public function authorize(): bool
{
    return true; // Cambiar de false a true
}

public function rules(): array
{
    return [
        // Migrar validaciones desde routes/api.php
        'campo' => 'required|string|max:255',
        'otro_campo' => 'nullable|string',
    ];
}
```

**UpdateNombreRequest.php:**
```php
public function rules(): array
{
    return [
        // Usar 'sometimes' para campos opcionales en update
        'campo' => 'sometimes|required|string|max:255',
        'otro_campo' => 'nullable|string',
    ];
}
```

### Fase 4: Implementar Resource

**NombreResource.php:**
```php
public function toArray(Request $request): array
{
    return [
        'id' => $this->id,
        'campo' => $this->campo,
        'created_at' => $this->created_at,
        'updated_at' => $this->updated_at,
    ];
}
```

### Fase 5: Implementar Controller

**NombreController.php:**
```php
use App\Http\Requests\StoreNombreRequest;
use App\Http\Requests\UpdateNombreRequest;
use App\Http\Resources\NombreResource;
use App\Models\Nombre;

public function index()
{
    return NombreResource::collection(Nombre::all());
}

public function store(StoreNombreRequest $request)
{
    $resource = Nombre::create($request->validated());
    return (new NombreResource($resource))
        ->response()
        ->setStatusCode(201);
}

public function show(string $id)
{
    $resource = Nombre::findOrFail($id); // 404 automático
    return new NombreResource($resource);
}

public function update(UpdateNombreRequest $request, string $id)
{
    $resource = Nombre::findOrFail($id);
    $resource->update($request->validated());
    return new NombreResource($resource);
}

public function destroy(string $id)
{
    $resource = Nombre::findOrFail($id);
    $resource->delete();
    return response()->json([
        'mensaje' => 'Recurso eliminado exitosamente',
        'deleted_id' => $id
    ], 200);
}
```

### Fase 6: Refactorizar Rutas

**routes/api.php:**

❌ **ANTES (múltiples líneas):**
```php
Route::get('/recursos', [NombreController::class, 'index']);
Route::post('/recursos', [NombreController::class, 'store']);
Route::get('/recursos/{id}', [NombreController::class, 'show']);
Route::put('/recursos/{id}', [NombreController::class, 'update']);
Route::delete('/recursos/{id}', [NombreController::class, 'destroy']);
```

✅ **DESPUÉS (una línea):**
```php
Route::apiResource('recursos', NombreController::class);
```

### Fase 7: Validación

```bash
# Limpiar caché
php artisan optimize:clear

# Ejecutar tests con cobertura
php artisan test --coverage

# Verificar que:
# ✅ Todos los tests pasen
# ✅ Cobertura > 80%
# ✅ 0 errores de linter
```

### Fase 8: Commits Lógicos

```bash
# Commit 1: Tests
git add tests/Feature/NombreApiTest.php
git commit -m "[TESTS] Agregar tests para CRUD de Nombre API"

# Commit 2: Form Requests
git add app/Http/Requests/
git commit -m "[REFACTOR] Mover validaciones a Form Requests"

# Commit 3: Resource
git add app/Http/Resources/
git commit -m "[REFACTOR] Agregar NombreResource para respuestas API"

# Commit 4: Controller
git add app/Http/Controllers/NombreController.php
git commit -m "[REFACTOR] Crear NombreController con métodos API"

# Commit 5: Rutas
git add routes/api.php
git commit -m "[REFACTOR] Simplificar rutas usando Route::apiResource"
```

## 📊 Métricas de Éxito

Después del refactor deberías ver:
- ✅ Reducción de líneas en routes/api.php (>80%)
- ✅ Cobertura de tests >80%
- ✅ Todos los tests pasando
- ✅ Código separado en capas claras

## 🚨 Errores Comunes

1. **❌ No cambiar `authorize()` a `true`** en Form Requests
2. **❌ Olvidar `findOrFail()`** en show/update/destroy
3. **❌ No usar `Resource::collection()`** en index
4. **❌ Crear archivos manualmente** en lugar de usar `php artisan make:`
5. **❌ No ejecutar `optimize:clear`** antes de tests

## 💡 Tips

- Usa Factory en tests, nunca datos manuales
- `findOrFail()` da 404 automático, no usar `find()` + if
- Resource::collection() para listas, new Resource() para items
- Status 201 para crear, 200 para actualizar/eliminar
- Commits lógicos por capa, no un commit gigante

## 📚 Ejemplo Real

Ver refactor exitoso de Tasks:
- PR: https://github.com/earhackerdem/clase3/pull/3
- Reducción: 230 líneas → 13 líneas (94.3%)
- Cobertura: 90.7%
- 19 tests pasando

