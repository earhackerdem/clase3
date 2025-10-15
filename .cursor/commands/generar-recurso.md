# Generar Recurso API con CRUD Completo

## 🎯 Uso Rápido

```
@generar-recurso.md [NOMBRE_RECURSO] [PROPIEDADES]
```

### Formato de Propiedades

```
campo:tipo[:reglas]
```

### Ejemplos de Uso

**Ejemplo 1: Product Simple**
```
@generar-recurso.md Product name:string:required,max:255 price:decimal:required stock:integer:default:0
```

**Ejemplo 2: Post de Blog**
```
@generar-recurso.md Post title:string:required,max:255 content:text:required slug:string:unique category:enum:draft|published|archived author_id:foreignId:required
```

**Ejemplo 3: Cliente**
```
@generar-recurso.md Customer name:string:required email:string:required,email,unique phone:string:nullable status:enum:active|inactive|pending
```

## 📝 Tipos de Datos Disponibles

### Strings
- `string` → `$table->string('campo')`
- `text` → `$table->text('campo')`
- `longText` → `$table->longText('campo')`

### Números
- `integer` → `$table->integer('campo')`
- `bigInteger` → `$table->bigInteger('campo')`
- `decimal` → `$table->decimal('campo', 10, 2)`
- `float` → `$table->float('campo')`

### Fechas
- `date` → `$table->date('campo')`
- `datetime` → `$table->dateTime('campo')`
- `timestamp` → `$table->timestamp('campo')`

### Booleanos
- `boolean` → `$table->boolean('campo')`

### Relaciones
- `foreignId` → `$table->foreignId('campo')`

### Especiales
- `enum:val1|val2|val3` → `$table->enum('campo', ['val1', 'val2', 'val3'])`
- `json` → `$table->json('campo')`

## 🔧 Reglas de Validación

### Básicas
- `required` - Campo obligatorio
- `nullable` - Puede ser nulo
- `unique` - Valor único en la tabla
- `email` - Formato de email
- `url` - Formato de URL

### Tamaño
- `min:X` - Mínimo X caracteres/valor
- `max:X` - Máximo X caracteres/valor
- `between:X,Y` - Entre X y Y

### Números
- `integer` - Debe ser entero
- `numeric` - Debe ser numérico
- `digits:X` - Debe tener exactamente X dígitos

### Valores por Defecto
- `default:valor` - Valor por defecto

## 📋 Proceso Automático

Cuando ejecutes el comando, se generará automáticamente:

### 1. Modelo y Migración
```bash
php artisan make:model NombreRecurso -m
```

### 2. Factory
```bash
php artisan make:factory NombreRecursoFactory
```

### 3. Seeder
```bash
php artisan make:seeder NombreRecursoSeeder
```

### 4. Controller
```bash
php artisan make:controller NombreRecursoController --api
```

### 5. Form Requests
```bash
php artisan make:request StoreNombreRecursoRequest
php artisan make:request UpdateNombreRecursoRequest
```

### 6. API Resource
```bash
php artisan make:resource NombreRecursoResource
```

### 7. Tests
```bash
php artisan make:test NombreRecursoApiTest
```

### 8. Rutas
Agregará automáticamente en `routes/api.php`:
```php
Route::apiResource('nombre-recursos', NombreRecursoController::class);
```

## 🎨 Ejemplo Completo: Generar Product

### Comando
```
@generar-recurso.md Product name:string:required,max:255 description:text:nullable price:decimal:required,min:0 stock:integer:default:0 category:enum:electronics|clothing|food is_active:boolean:default:true
```

### Resultado

#### Migración Generada
```php
Schema::create('products', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->text('description')->nullable();
    $table->decimal('price', 10, 2);
    $table->integer('stock')->default(0);
    $table->enum('category', ['electronics', 'clothing', 'food']);
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

#### Modelo Generado
```php
class Product extends Model
{
    protected $fillable = [
        'name',
        'description',
        'price',
        'stock',
        'category',
        'is_active',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'stock' => 'integer',
        'is_active' => 'boolean',
    ];

    protected $attributes = [
        'stock' => 0,
        'is_active' => true,
    ];
}
```

#### Factory Generado
```php
public function definition(): array
{
    return [
        'name' => fake()->words(3, true),
        'description' => fake()->paragraph(),
        'price' => fake()->randomFloat(2, 10, 1000),
        'stock' => fake()->numberBetween(0, 100),
        'category' => fake()->randomElement(['electronics', 'clothing', 'food']),
        'is_active' => fake()->boolean(80),
    ];
}
```

#### StoreProductRequest Generado
```php
public function rules(): array
{
    return [
        'name' => 'required|string|max:255',
        'description' => 'nullable|string',
        'price' => 'required|numeric|min:0',
        'stock' => 'sometimes|integer',
        'category' => 'required|in:electronics,clothing,food',
        'is_active' => 'sometimes|boolean',
    ];
}
```

#### Controller Generado
```php
class ProductController extends Controller
{
    public function index()
    {
        return ProductResource::collection(Product::all());
    }

    public function store(StoreProductRequest $request)
    {
        $product = Product::create($request->validated());
        return (new ProductResource($product))
            ->response()
            ->setStatusCode(201);
    }

    public function show(string $id)
    {
        return new ProductResource(Product::findOrFail($id));
    }

    public function update(UpdateProductRequest $request, string $id)
    {
        $product = Product::findOrFail($id);
        $product->update($request->validated());
        return new ProductResource($product);
    }

    public function destroy(string $id)
    {
        Product::findOrFail($id)->delete();
        return response()->json([
            'mensaje' => 'Producto eliminado exitosamente',
            'deleted_id' => $id
        ], 200);
    }
}
```

#### Tests Generados (12 tests)
- ✅ POST - Crear producto
- ✅ POST - Validaciones
- ✅ GET /products - Listar todos
- ✅ GET /products/{id} - Mostrar uno
- ✅ PUT /products/{id} - Actualizar
- ✅ DELETE /products/{id} - Eliminar

## 🚀 Ejecución

Después de generar los archivos, ejecuta:

```bash
# Migración
php artisan migrate

# Tests
php artisan test --coverage

# Si todo pasa, hacer commits
git add .
git commit -m "[FEATURE] Agregar CRUD completo de Product"
```

## 📊 Salida Esperada

```
✅ Modelo creado: app/Models/Product.php
✅ Migración creada: database/migrations/..._create_products_table.php
✅ Factory creado: database/factories/ProductFactory.php
✅ Seeder creado: database/seeders/ProductSeeder.php
✅ Controller creado: app/Http/Controllers/ProductController.php
✅ Request creado: app/Http/Requests/StoreProductRequest.php
✅ Request creado: app/Http/Requests/UpdateProductRequest.php
✅ Resource creado: app/Http/Resources/ProductResource.php
✅ Tests creados: tests/Feature/ProductApiTest.php
✅ Rutas registradas en routes/api.php

📊 Estadísticas:
- 9 archivos creados
- 12 tests implementados
- Cobertura esperada: >85%
- Tiempo estimado: ~3 minutos
```

## 💡 Tips

### Nombres
- **Singular en inglés** para el modelo: `Product`, `Customer`, `Order`
- **Plural en rutas**: `/api/products`, `/api/customers`
- **Snake_case para BD**: `is_active`, `created_at`, `user_id`

### Relaciones
Para relaciones, usa `foreignId`:
```
@generar-recurso.md Order user_id:foreignId:required product_id:foreignId:required quantity:integer:required,min:1 total:decimal:required
```

### Enums
Separa valores con pipe `|`:
```
status:enum:pending|processing|completed|cancelled
```

### Defaults
Usa `default:valor`:
```
is_active:boolean:default:true
stock:integer:default:0
```

## 🔗 Comandos Relacionados

- `@crear-crud-completo.md` - Guía detallada paso a paso
- `@refactorizar-a-capas.md` - Para refactorizar existentes
- `@verificar-cobertura-tests.md` - Validar tests

## ⚠️ Notas

- Este comando ejecuta scaffolding automático
- Revisa y ajusta el código generado según necesites
- Ejecuta tests antes de commitear
- Mantén cobertura >80%

