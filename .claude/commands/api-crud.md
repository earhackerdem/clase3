---
description: Crea una API siguiendo las buenas practicas de Laravel
argument-hint : Nombre del modelo  | Campos y sus reglas
---

Crea un CRUD completo siguiendo las siguientes especificaciones.

## 🎯 Parseo de Argumentos de Claude CLI

Los argumentos vienen en `$ARGUMENTS` en el formato:
```
NombreModelo | campo1:tipo:reglas, campo2:tipo:reglas, ...
```

**Ejemplo de uso en Claude CLI:**
```bash
claude api-crud Product | name:string:required|max:255, price:decimal:required, description:text:nullable
```

**INSTRUCCIONES DE PARSEO:**

1. **Extraer de `$ARGUMENTS`**:
   - **Modelo**: Primera parte antes del `|` → convertir a PascalCase
   - **Campos**: Segunda parte después del `|` → separar por comas

2. **Transformaciones automáticas**:
   - `Product` → Modelo: `Product`, Tabla: `products`, Ruta: `products`
   - `UserProfile` → Modelo: `UserProfile`, Tabla: `user_profiles`, Ruta: `user-profiles`

3. **Parsear cada campo**:
   - Formato: `nombre:tipo:reglas`
   - Ejemplo: `name:string:required|max:255`
   - Resultado: nombre=`name`, tipo=`string`, reglas=`required|max:255`

## 🔄 Mapeo de Tipos de Datos

| Tipo Usuario | Migration | Faker | Validación Base |
|-------------|-----------|-------|-----------------|
| `string` | `$table->string('campo')` | `fake()->words(3, true)` | `string\|max:255` |
| `text` | `$table->text('campo')` | `fake()->paragraph()` | `string` |
| `integer` | `$table->integer('campo')` | `fake()->numberBetween(1, 100)` | `integer` |
| `decimal` | `$table->decimal('campo', 10, 2)` | `fake()->randomFloat(2, 0, 1000)` | `numeric` |
| `boolean` | `$table->boolean('campo')` | `fake()->boolean()` | `boolean` |
| `date` | `$table->date('campo')` | `fake()->date()` | `date` |
| `datetime` | `$table->timestamp('campo')` | `fake()->dateTime()` | `date` |
| `email` | `$table->string('campo')` | `fake()->safeEmail()` | `email` |

**Modificadores de reglas:**
- `required` → campo obligatorio
- `nullable` → `->nullable()` en migration
- `unique` → `->unique()` en migration
- `min:X` → validación mínima
- `max:X` → validación máxima
- `in:val1,val2` → `fake()->randomElement(['val1', 'val2'])`

---

## 📝 Ejemplo Completo: Posts de Laravel

**Comando en Claude CLI:**
```bash
claude api-crud Post | title:string:required|max:255, content:text:required, excerpt:text:nullable|max:500, status:string:in:published,draft,archived, featured:boolean:nullable, published_at:datetime:nullable
```

**Parseo de $ARGUMENTS:**
- **Modelo**: `Post`
- **Tabla**: `posts`
- **Ruta**: `posts`

**Campos parseados:**
1. `title` - Tipo: `string` - Reglas: `required|max:255`
2. `content` - Tipo: `text` - Reglas: `required`
3. `excerpt` - Tipo: `text` - Reglas: `nullable|max:500`
4. `status` - Tipo: `string` - Reglas: `in:published,draft,archived`
5. `featured` - Tipo: `boolean` - Reglas: `nullable`
6. `published_at` - Tipo: `datetime` - Reglas: `nullable`

**Resultado esperado:**
- Modelo: `Post.php`
- Migración: `create_posts_table.php`
- Controller: `PostController.php`
- Tests: `PostApiTest.php`
- Rutas: `/api/posts`

## 📋 Pre-requisitos

```bash
# Verificar que Docker esté corriendo
make ps

# Acceder al workspace
make shell
```

## 🚀 Proceso Completo (Paso a Paso)

**⚠️ IMPORTANTE:** En TODOS los pasos siguientes, reemplaza los placeholders con los valores parseados de `$ARGUMENTS`:
- `[ModeloNombre]` → nombre del modelo en PascalCase (ej: `Post`)
- `[tabla_nombre]` → nombre de tabla en plural snake_case (ej: `posts`)
- `[modelo-kebab]` → nombre en kebab-case para rutas (ej: `posts`)
- `[campos]` → campos parseados del usuario

**Los ejemplos usan placeholders, pero TÚ debes usar los valores reales extraídos de `$ARGUMENTS`.**

### Paso 1: Crear Modelo y Migración

```bash
# Crear modelo con migración, factory y seeder
# Reemplaza [ModeloNombre] con el nombre real del modelo parseado
php artisan make:model [ModeloNombre] -mfs

# Esto crea:
# - app/Models/[ModeloNombre].php
# - database/migrations/YYYY_MM_DD_HHMMSS_create_[tabla_nombre]_table.php
# - database/factories/[ModeloNombre]Factory.php
# - database/seeders/[ModeloNombre]Seeder.php
```

**Editar migración:**
```php
// database/migrations/..._create_[tabla_nombre]_table.php
public function up(): void
{
    Schema::create('[tabla_nombre]', function (Blueprint $table) {
        $table->id();
        
        // ⚠️ AQUÍ: Agrega los campos parseados de $ARGUMENTS
        // Usa el tipo de dato correcto según el parseo
        // Ejemplo para Posts:
        // $table->string('title');
        // $table->text('content');
        // $table->text('excerpt')->nullable();
        // $table->string('status');
        // $table->boolean('featured')->nullable();
        // $table->timestamp('published_at')->nullable();
        
        $table->timestamps();
    });
}
```

**Configurar modelo:**
```php
// app/Models/[ModeloNombre].php
protected $fillable = [
    // ⚠️ AQUÍ: Lista todos los nombres de campos parseados de $ARGUMENTS
    // Ejemplo para Posts: 'title', 'content', 'excerpt', 'status', 'featured', 'published_at'
];

// Opcional: valores por defecto
protected $attributes = [
    // Si algún campo tiene valor por defecto
    // Ejemplo: 'status' => 'active'
];
```

**Ejecutar migración:**
```bash
php artisan migrate
```

### Paso 2: Configurar Factory

```php
// database/factories/[ModeloNombre]Factory.php
public function definition(): array
{
    return [
        // ⚠️ AQUÍ: Usa los campos parseados con datos faker apropiados
        // Según el tipo de campo, usa el método faker correspondiente:
        // - string corto: fake()->word() o fake()->sentence()
        // - text largo: fake()->paragraph()
        // - decimal/integer: fake()->randomFloat() o fake()->numberBetween()
        // - boolean: fake()->boolean()
        // - date: fake()->date()
        // - enum/status: fake()->randomElement(['valor1', 'valor2'])
        
        // Ejemplo para Posts:
        // 'title' => fake()->sentence(),
        // 'content' => fake()->paragraphs(3, true),
        // 'excerpt' => fake()->paragraph(),
        // 'status' => fake()->randomElement(['published', 'draft', 'archived']),
        // 'featured' => fake()->boolean(),
        // 'published_at' => fake()->dateTime(),
    ];
}
```

### Paso 3: Configurar Seeder

```php
// database/seeders/[ModeloNombre]Seeder.php
public function run(): void
{
    [ModeloNombre]::factory()->count(20)->create();
}
```

**Ejecutar seeder (opcional):**
```bash
php artisan db:seed --class=[ModeloNombre]Seeder
```

### Paso 4: Crear Tests (TDD)

```bash
# Crear archivo de tests
php artisan make:test [ModeloNombre]ApiTest
```

**Implementar tests completos:**

⚠️ **IMPORTANTE:** Reemplaza en los tests:
- `[ModeloNombre]` con el nombre del modelo
- `[modelo-kebab]` con la ruta en kebab-case
- `[tabla_nombre]` con el nombre de la tabla
- `[campo_requerido]` con un campo requerido parseado
- `[datos_ejemplo]` con datos de ejemplo según los campos parseados

```php
// tests/Feature/[ModeloNombre]ApiTest.php
<?php

namespace Tests\Feature;

use App\Models\[ModeloNombre];
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class [ModeloNombre]ApiTest extends TestCase
{
    use RefreshDatabase;

    // ==================== POST /api/[modelo-kebab] ====================
    
    public function test_can_create_[modelo_snake]_successfully(): void
    {
        // Arrange
        $data = [
        // ⚠️ Usa los campos parseados del usuario con valores de prueba
        // Ejemplo para Posts:
        // 'title' => 'Test Post Title',
        // 'content' => 'This is test content for the post',
        // 'excerpt' => 'Test excerpt',
        // 'status' => 'published',
        // 'featured' => true,
        // 'published_at' => now(),
        ];

        // Act
        $response = $this->postJson('/api/[modelo-kebab]', $data);

        // Assert
        $response->assertStatus(201);
        
        $this->assertDatabaseHas('[tabla_nombre]', [
            // Verifica al menos un campo único
        ]);
    }

    public function test_fails_when_[campo_requerido]_is_empty(): void
    {
        $response = $this->postJson('/api/[modelo-kebab]', [
            // Omite un campo requerido
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['[campo_requerido]']);
    }

    // ==================== GET /api/[modelo-kebab] ====================
    
    public function test_can_list_all_[modelo_snake_plural](): void
    {
        [ModeloNombre]::factory()->count(3)->create();

        $response = $this->getJson('/api/[modelo-kebab]');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data');
    }

    public function test_returns_empty_array_when_no_[modelo_snake_plural](): void
    {
        $response = $this->getJson('/api/[modelo-kebab]');

        $response->assertStatus(200)
            ->assertJsonCount(0, 'data');
    }

    // ==================== GET /api/[modelo-kebab]/{id} ====================
    
    public function test_can_show_single_[modelo_snake](): void
    {
        $modelo = [ModeloNombre]::factory()->create();

        $response = $this->getJson("/api/[modelo-kebab]/{$modelo->id}");

        $response->assertStatus(200)
            ->assertJsonFragment(['id' => $modelo->id]);
    }

    public function test_returns_404_when_[modelo_snake]_not_found(): void
    {
        $response = $this->getJson('/api/[modelo-kebab]/99999');

        $response->assertStatus(404);
    }

    // ==================== PUT /api/[modelo-kebab]/{id} ====================
    
    public function test_can_update_[modelo_snake]_successfully(): void
    {
        $modelo = [ModeloNombre]::factory()->create();

        $response = $this->putJson("/api/[modelo-kebab]/{$modelo->id}", [
            // Datos actualizados según campos parseados
        ]);

        $response->assertStatus(200);
        
        $this->assertDatabaseHas('[tabla_nombre]', [
            'id' => $modelo->id,
            // Verifica campos actualizados
        ]);
    }

    public function test_fails_update_when_[modelo_snake]_not_exists(): void
    {
        $response = $this->putJson('/api/[modelo-kebab]/99999', [
            // Datos de prueba
        ]);

        $response->assertStatus(404);
    }

    // ==================== DELETE /api/[modelo-kebab]/{id} ====================
    
    public function test_can_delete_[modelo_snake]_successfully(): void
    {
        $modelo = [ModeloNombre]::factory()->create();

        $response = $this->deleteJson("/api/[modelo-kebab]/{$modelo->id}");

        $response->assertStatus(200);
        
        $this->assertDatabaseMissing('[tabla_nombre]', [
            'id' => $modelo->id,
        ]);
    }

    public function test_fails_delete_when_[modelo_snake]_not_found(): void
    {
        $response = $this->deleteJson('/api/[modelo-kebab]/99999');

        $response->assertStatus(404);
    }
}
```

**Ejecutar tests (deben fallar porque no hay rutas):**
```bash
php artisan test tests/Feature/[ModeloNombre]ApiTest.php
```

### Paso 5: Crear Componentes con Scaffolding

```bash
# Controller API
php artisan make:controller [ModeloNombre]Controller --api

# Form Requests
php artisan make:request Store[ModeloNombre]Request
php artisan make:request Update[ModeloNombre]Request

# API Resource
php artisan make:resource [ModeloNombre]Resource
```

### Paso 6: Implementar Form Requests

**Store[ModeloNombre]Request.php:**
```php
public function authorize(): bool
{
    return true;
}

public function rules(): array
{
    return [
        // ⚠️ AQUÍ: Usa las reglas de validación parseadas del usuario
        // Toma las reglas del parseo inicial
        
        // Ejemplo para Posts:
        // 'title' => 'required|string|max:255',
        // 'content' => 'required|string',
        // 'excerpt' => 'nullable|string|max:500',
        // 'status' => 'required|in:published,draft,archived',
        // 'featured' => 'nullable|boolean',
        // 'published_at' => 'nullable|date',
    ];
}
```

**Update[ModeloNombre]Request.php:**
```php
public function authorize(): bool
{
    return true;
}

public function rules(): array
{
    return [
        // ⚠️ AQUÍ: Mismas reglas pero con 'sometimes' para hacer campos opcionales en updates
        // Agrega 'sometimes|' al inicio de campos que pueden ser opcionales en update
        
        // Ejemplo para Posts:
        // 'title' => 'sometimes|required|string|max:255',
        // 'content' => 'sometimes|required|string',
        // 'excerpt' => 'nullable|string|max:500',
        // 'status' => 'sometimes|in:published,draft,archived',
        // 'featured' => 'nullable|boolean',
        // 'published_at' => 'nullable|date',
    ];
}
```

### Paso 7: Implementar Resource

```php
// app/Http/Resources/[ModeloNombre]Resource.php
public function toArray(Request $request): array
{
    return [
        'id' => $this->id,
        
        // ⚠️ AQUÍ: Lista todos los campos parseados del modelo
        // Ejemplo para Posts:
        // 'title' => $this->title,
        // 'content' => $this->content,
        // 'excerpt' => $this->excerpt,
        // 'status' => $this->status,
        // 'featured' => $this->featured,
        // 'published_at' => $this->published_at,
        
        'created_at' => $this->created_at,
        'updated_at' => $this->updated_at,
    ];
}
```

### Paso 8: Implementar Controller

```php
// app/Http/Controllers/[ModeloNombre]Controller.php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\Store[ModeloNombre]Request;
use App\Http\Requests\Update[ModeloNombre]Request;
use App\Http\Resources\[ModeloNombre]Resource;
use App\Models\[ModeloNombre];

class [ModeloNombre]Controller extends Controller
{
    public function index()
    {
        $modelos = [ModeloNombre]::all();
        return [ModeloNombre]Resource::collection($modelos);
    }

    public function store(Store[ModeloNombre]Request $request)
    {
        $modelo = [ModeloNombre]::create($request->validated());
        return (new [ModeloNombre]Resource($modelo))
            ->response()
            ->setStatusCode(201);
    }

    public function show(string $id)
    {
        $modelo = [ModeloNombre]::findOrFail($id);
        return new [ModeloNombre]Resource($modelo);
    }

    public function update(Update[ModeloNombre]Request $request, string $id)
    {
        $modelo = [ModeloNombre]::findOrFail($id);
        $modelo->update($request->validated());
        return new [ModeloNombre]Resource($modelo);
    }

    public function destroy(string $id)
    {
        $modelo = [ModeloNombre]::findOrFail($id);
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
use App\Http\Controllers\[ModeloNombre]Controller;

Route::apiResource('[modelo-kebab]', [ModeloNombre]Controller::class);
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
# Crear rama (usa nombre en kebab-case)
git checkout -b feature/add-[modelo-kebab]-crud

# Commit 1: Modelo y migración
git add app/Models/[ModeloNombre].php database/migrations/ database/factories/ database/seeders/
git commit -m "[FEATURE] Agregar modelo [ModeloNombre] con migración, factory y seeder"

# Commit 2: Tests
git add tests/Feature/[ModeloNombre]ApiTest.php
git commit -m "[TESTS] Agregar tests completos para CRUD de [ModeloNombre] API"

# Commit 3: Form Requests
git add app/Http/Requests/Store[ModeloNombre]Request.php app/Http/Requests/Update[ModeloNombre]Request.php
git commit -m "[FEATURE] Agregar Form Requests para validación de [ModeloNombre]"

# Commit 4: Resource
git add app/Http/Resources/[ModeloNombre]Resource.php
git commit -m "[FEATURE] Agregar [ModeloNombre]Resource para respuestas API"

# Commit 5: Controller
git add app/Http/Controllers/[ModeloNombre]Controller.php
git commit -m "[FEATURE] Crear [ModeloNombre]Controller con métodos CRUD"

# Commit 6: Rutas
git add routes/api.php
git commit -m "[FEATURE] Registrar rutas API para [ModeloNombre]"

# Push
git push -u origin feature/add-[modelo-kebab]-crud
```

### Paso 12: Crear Pull Request

```bash
gh pr create --title "[FEATURE] Implementar CRUD completo de [ModeloNombre]" \
  --body "## Funcionalidad Nueva

CRUD completo para [ModeloNombre] con arquitectura en capas.

## Componentes Creados
- ✅ Modelo con migración, factory y seeder
- ✅ Controller con 5 métodos RESTful
- ✅ Form Requests (Store y Update)
- ✅ API Resource para respuestas
- ✅ Tests completos (12 tests mínimo)

## Testing
- ✅ XX tests pasando
- ✅ Cobertura: XX%
- ✅ Todos los verbos HTTP cubiertos

## Rutas Generadas
- GET    /api/[modelo-kebab]
- POST   /api/[modelo-kebab]
- GET    /api/[modelo-kebab]/{id}
- PUT    /api/[modelo-kebab]/{id}
- DELETE /api/[modelo-kebab]/{id}"
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

