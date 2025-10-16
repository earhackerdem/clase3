# Crear CRUD Completo con Buenas Prácticas

## 🎯 Objetivo
Crear un CRUD completo desde cero siguiendo las buenas prácticas de Laravel 12, con arquitectura en capas, tests completos y cobertura >80%.

## 📋 Pre-requisitos

```bash
# Verificar que Docker esté corriendo
make ps

# Acceder al workspace
make shell
```

## 🚀 Proceso Completo (Paso a Paso)

### Paso 1: Crear Modelo y Migración

```bash
# Crear modelo con migración, factory y seeder
php artisan make:model NombreModelo -mfs

# Esto crea:
# - app/Models/NombreModelo.php
# - database/migrations/YYYY_MM_DD_HHMMSS_create_nombre_modelos_table.php
# - database/factories/NombreModeloFactory.php
# - database/seeders/NombreModeloSeeder.php
```

**Editar migración:**
```php
// database/migrations/..._create_nombre_modelos_table.php
public function up(): void
{
    Schema::create('nombre_modelos', function (Blueprint $table) {
        $table->id();
        $table->string('titulo');
        $table->text('descripcion')->nullable();
        $table->string('status')->default('activo');
        $table->timestamps();
    });
}
```

**Configurar modelo:**
```php
// app/Models/NombreModelo.php
protected $fillable = [
    'titulo',
    'descripcion',
    'status',
];

protected $attributes = [
    'status' => 'activo',
];
```

**Ejecutar migración:**
```bash
php artisan migrate
```

### Paso 2: Configurar Factory

```php
// database/factories/NombreModeloFactory.php
public function definition(): array
{
    return [
        'titulo' => fake()->sentence(),
        'descripcion' => fake()->paragraph(),
        'status' => fake()->randomElement(['activo', 'inactivo', 'pendiente']),
    ];
}
```

### Paso 3: Configurar Seeder

```php
// database/seeders/NombreModeloSeeder.php
public function run(): void
{
    NombreModelo::factory()->count(20)->create();
}
```

**Ejecutar seeder (opcional):**
```bash
php artisan db:seed --class=NombreModeloSeeder
```

### Paso 4: Crear Tests (TDD)

```bash
# Crear archivo de tests
php artisan make:test NombreModeloApiTest
```

**Implementar tests completos:**
```php
// tests/Feature/NombreModeloApiTest.php
<?php

namespace Tests\Feature;

use App\Models\NombreModelo;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NombreModeloApiTest extends TestCase
{
    use RefreshDatabase;

    // ==================== POST /api/nombre-modelos ====================
    
    public function test_can_create_nombre_modelo_successfully(): void
    {
        // Arrange
        $data = [
            'titulo' => 'Test Título',
            'descripcion' => 'Test Descripción',
            'status' => 'activo',
        ];

        // Act
        $response = $this->postJson('/api/nombre-modelos', $data);

        // Assert
        $response->assertStatus(201)
            ->assertJsonFragment(['titulo' => 'Test Título']);
        
        $this->assertDatabaseHas('nombre_modelos', [
            'titulo' => 'Test Título',
        ]);
    }

    public function test_fails_when_titulo_is_empty(): void
    {
        $response = $this->postJson('/api/nombre-modelos', [
            'descripcion' => 'Sin título',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['titulo']);
    }

    // ==================== GET /api/nombre-modelos ====================
    
    public function test_can_list_all_nombre_modelos(): void
    {
        NombreModelo::factory()->count(3)->create();

        $response = $this->getJson('/api/nombre-modelos');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data');
    }

    public function test_returns_empty_array_when_no_nombre_modelos(): void
    {
        $response = $this->getJson('/api/nombre-modelos');

        $response->assertStatus(200)
            ->assertJsonCount(0, 'data');
    }

    // ==================== GET /api/nombre-modelos/{id} ====================
    
    public function test_can_show_single_nombre_modelo(): void
    {
        $modelo = NombreModelo::factory()->create();

        $response = $this->getJson("/api/nombre-modelos/{$modelo->id}");

        $response->assertStatus(200)
            ->assertJsonFragment(['id' => $modelo->id]);
    }

    public function test_returns_404_when_nombre_modelo_not_found(): void
    {
        $response = $this->getJson('/api/nombre-modelos/99999');

        $response->assertStatus(404);
    }

    // ==================== PUT /api/nombre-modelos/{id} ====================
    
    public function test_can_update_nombre_modelo_successfully(): void
    {
        $modelo = NombreModelo::factory()->create([
            'titulo' => 'Original',
        ]);

        $response = $this->putJson("/api/nombre-modelos/{$modelo->id}", [
            'titulo' => 'Actualizado',
        ]);

        $response->assertStatus(200);
        
        $this->assertDatabaseHas('nombre_modelos', [
            'id' => $modelo->id,
            'titulo' => 'Actualizado',
        ]);
    }

    public function test_fails_update_when_nombre_modelo_not_exists(): void
    {
        $response = $this->putJson('/api/nombre-modelos/99999', [
            'titulo' => 'Test',
        ]);

        $response->assertStatus(404);
    }

    // ==================== DELETE /api/nombre-modelos/{id} ====================
    
    public function test_can_delete_nombre_modelo_successfully(): void
    {
        $modelo = NombreModelo::factory()->create();

        $response = $this->deleteJson("/api/nombre-modelos/{$modelo->id}");

        $response->assertStatus(200);
        
        $this->assertDatabaseMissing('nombre_modelos', [
            'id' => $modelo->id,
        ]);
    }

    public function test_fails_delete_when_nombre_modelo_not_found(): void
    {
        $response = $this->deleteJson('/api/nombre-modelos/99999');

        $response->assertStatus(404);
    }
}
```

**Ejecutar tests (deben fallar porque no hay rutas):**
```bash
php artisan test tests/Feature/NombreModeloApiTest.php
```

### Paso 5: Crear Componentes con Scaffolding

```bash
# Controller API
php artisan make:controller NombreModeloController --api

# Form Requests
php artisan make:request StoreNombreModeloRequest
php artisan make:request UpdateNombreModeloRequest

# API Resource
php artisan make:resource NombreModeloResource
```

### Paso 6: Implementar Form Requests

**StoreNombreModeloRequest.php:**
```php
public function authorize(): bool
{
    return true;
}

public function rules(): array
{
    return [
        'titulo' => 'required|string|max:255',
        'descripcion' => 'nullable|string',
        'status' => 'sometimes|in:activo,inactivo,pendiente',
    ];
}
```

**UpdateNombreModeloRequest.php:**
```php
public function authorize(): bool
{
    return true;
}

public function rules(): array
{
    return [
        'titulo' => 'sometimes|required|string|max:255',
        'descripcion' => 'nullable|string',
        'status' => 'sometimes|in:activo,inactivo,pendiente',
    ];
}
```

### Paso 7: Implementar Resource

```php
// app/Http/Resources/NombreModeloResource.php
public function toArray(Request $request): array
{
    return [
        'id' => $this->id,
        'titulo' => $this->titulo,
        'descripcion' => $this->descripcion,
        'status' => $this->status,
        'created_at' => $this->created_at,
        'updated_at' => $this->updated_at,
    ];
}
```

### Paso 8: Implementar Controller

```php
// app/Http/Controllers/NombreModeloController.php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreNombreModeloRequest;
use App\Http\Requests\UpdateNombreModeloRequest;
use App\Http\Resources\NombreModeloResource;
use App\Models\NombreModelo;

class NombreModeloController extends Controller
{
    public function index()
    {
        $modelos = NombreModelo::all();
        return NombreModeloResource::collection($modelos);
    }

    public function store(StoreNombreModeloRequest $request)
    {
        $modelo = NombreModelo::create($request->validated());
        return (new NombreModeloResource($modelo))
            ->response()
            ->setStatusCode(201);
    }

    public function show(string $id)
    {
        $modelo = NombreModelo::findOrFail($id);
        return new NombreModeloResource($modelo);
    }

    public function update(UpdateNombreModeloRequest $request, string $id)
    {
        $modelo = NombreModelo::findOrFail($id);
        $modelo->update($request->validated());
        return new NombreModeloResource($modelo);
    }

    public function destroy(string $id)
    {
        $modelo = NombreModelo::findOrFail($id);
        $modelo->delete();
        return response()->json([
            'mensaje' => 'Recurso eliminado exitosamente',
            'deleted_id' => $id
        ], 200);
    }
}
```

### Paso 9: Registrar Rutas

```php
// routes/api.php
use App\Http\Controllers\NombreModeloController;

Route::apiResource('nombre-modelos', NombreModeloController::class);
```

### Paso 10: Validar

```bash
# Limpiar caché
php artisan optimize:clear

# Ejecutar tests
php artisan test --coverage

# Verificar:
# ✅ Todos los tests pasan
# ✅ Cobertura >80%
```

### Paso 11: Crear Rama y Commits

```bash
# Crear rama
git checkout -b feature/add-nombre-modelo-crud

# Commit 1: Modelo y migración
git add app/Models/NombreModelo.php database/migrations/ database/factories/ database/seeders/
git commit -m "[FEATURE] Agregar modelo NombreModelo con migración, factory y seeder"

# Commit 2: Tests
git add tests/Feature/NombreModeloApiTest.php
git commit -m "[TESTS] Agregar tests completos para CRUD de NombreModelo API"

# Commit 3: Form Requests
git add app/Http/Requests/
git commit -m "[FEATURE] Agregar Form Requests para validación de NombreModelo"

# Commit 4: Resource
git add app/Http/Resources/NombreModeloResource.php
git commit -m "[FEATURE] Agregar NombreModeloResource para respuestas API"

# Commit 5: Controller
git add app/Http/Controllers/NombreModeloController.php
git commit -m "[FEATURE] Crear NombreModeloController con métodos CRUD"

# Commit 6: Rutas
git add routes/api.php
git commit -m "[FEATURE] Registrar rutas API para NombreModelo"

# Push
git push -u origin feature/add-nombre-modelo-crud
```

### Paso 12: Crear Pull Request

```bash
gh pr create --title "[FEATURE] Implementar CRUD completo de NombreModelo" \
  --body "## Funcionalidad Nueva

CRUD completo para NombreModelo con arquitectura en capas.

## Componentes Creados
- ✅ Modelo con migración, factory y seeder
- ✅ Controller con 5 métodos RESTful
- ✅ Form Requests (Store y Update)
- ✅ API Resource para respuestas
- ✅ Tests completos (12 tests)

## Testing
- ✅ 12 tests pasando
- ✅ Cobertura: XX%
- ✅ Todos los verbos HTTP cubiertos

## Rutas Generadas
- GET    /api/nombre-modelos
- POST   /api/nombre-modelos
- GET    /api/nombre-modelos/{id}
- PUT    /api/nombre-modelos/{id}
- DELETE /api/nombre-modelos/{id}"
```

## 📊 Checklist Final

- [ ] Modelo configurado con fillable
- [ ] Migración ejecutada
- [ ] Factory implementado
- [ ] Seeder configurado
- [ ] 12 tests creados (mínimo)
- [ ] Controller con 5 métodos
- [ ] Form Requests para validación
- [ ] Resource para transformación
- [ ] Rutas con apiResource
- [ ] Todos los tests pasan
- [ ] Cobertura >80%
- [ ] 6 commits lógicos
- [ ] Pull Request creado

## 🚨 Errores Comunes

1. ❌ Olvidar `use RefreshDatabase` en tests
2. ❌ No cambiar `authorize()` a true en Requests
3. ❌ Usar `find()` en lugar de `findOrFail()`
4. ❌ No ejecutar `optimize:clear` antes de tests
5. ❌ Crear archivos manualmente en lugar de usar artisan
6. ❌ No usar Factory en tests

## 💡 Tips

- **Nombres en plural** para rutas: `/api/tasks` no `/api/task`
- **Nombres en singular** para modelo: `Task` no `Tasks`
- **Factory siempre** para datos de prueba en tests
- **Status code 201** para crear, 200 para update/delete
- **findOrFail()** da 404 automático, úsalo siempre

## 📚 Tiempo Estimado

- Modelo + Migración: 5 min
- Factory + Seeder: 5 min
- Tests: 15 min
- Form Requests: 5 min
- Resource: 3 min
- Controller: 10 min
- Rutas + Validación: 5 min
- Commits + PR: 5 min

**Total: ~53 minutos** para un CRUD completo con cobertura >80%

