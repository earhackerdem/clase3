# Verificar Cobertura de Tests

## 🎯 Objetivo
Validar que los tests cumplan con los estándares de calidad: todos pasan, cobertura >80%, y buenas prácticas aplicadas.

## 🧪 Ejecución Rápida

```bash
# Paso 1: Limpiar caché (OBLIGATORIO)
make clear

# Paso 2: Ejecutar tests con cobertura
make test
# o con cobertura detallada:
php artisan test --coverage

# Paso 3: Verificar resultados
```

## 📊 Checklist de Validación

### ✅ Tests Pasando
```bash
# Deben pasar TODOS los tests
# Output esperado:
# Tests: X passed (Y assertions)
# Duration: Z.XXs

# ❌ Si hay failures:
# - Revisar el error específico
# - NO hacer commits hasta que todos pasen
```

### ✅ Cobertura Mínima

**Objetivo: >80% de cobertura**

```bash
# Ver cobertura detallada por archivo
php artisan test --coverage --min=80

# Archivos críticos que DEBEN tener 100%:
# - Controllers
# - Form Requests
# - Resources
# - Modelos (con lógica de negocio)

# Puede ser <100%:
# - Providers (si solo configuración)
# - Middleware (si es genérico)
```

### ✅ Estructura de Tests

**Verificar que los tests sigan el patrón AAA:**

```php
public function test_descripcion_clara(): void
{
    // Arrange: Preparar datos y estado
    $data = Model::factory()->make()->toArray();
    
    // Act: Ejecutar la acción
    $response = $this->postJson('/api/endpoint', $data);
    
    // Assert: Verificar resultado
    $response->assertStatus(201);
    $this->assertDatabaseHas('tabla', ['campo' => $data['campo']]);
}
```

### ✅ Cobertura por Verbo HTTP

**Cada endpoint CRUD debe tener tests para:**

- [ ] GET /api/resource (index)
  - [ ] Listar todos los recursos
  - [ ] Retornar array vacío si no hay datos
  
- [ ] GET /api/resource/{id} (show)
  - [ ] Mostrar recurso existente
  - [ ] Retornar 404 si no existe
  
- [ ] POST /api/resource (store)
  - [ ] Crear recurso con datos válidos
  - [ ] Crear sin campos opcionales
  - [ ] Fallar con datos inválidos
  - [ ] Fallar con campo requerido vacío
  
- [ ] PUT /api/resource/{id} (update)
  - [ ] Actualizar todos los campos
  - [ ] Actualización parcial
  - [ ] Fallar si recurso no existe (404)
  - [ ] Fallar con datos inválidos
  
- [ ] DELETE /api/resource/{id} (destroy)
  - [ ] Eliminar recurso existente
  - [ ] Fallar si no existe (404)

## 🔍 Análisis de Cobertura

### Ver Cobertura por Directorio

```bash
# Cobertura de Controllers
php artisan test --coverage --path=app/Http/Controllers

# Cobertura de Requests
php artisan test --coverage --path=app/Http/Requests

# Cobertura de Resources
php artisan test --coverage --path=app/Http/Resources

# Cobertura de Models
php artisan test --coverage --path=app/Models
```

### Identificar Gaps de Cobertura

```bash
# Ver líneas NO cubiertas
php artisan test --coverage --min=100

# Esto mostrará qué archivos están bajo 100%
# y qué líneas específicas no están cubiertas
```

## 📈 Interpretar Resultados

### Ejemplo de Output Exitoso

```
Tests:    19 passed (50 assertions)
Duration: 2.55s

Http/Controllers/Controller ......................................... 100.0%  
Http/Controllers/TaskController ..................................... 100.0%  
Http/Requests/StoreTaskRequest ...................................... 100.0%  
Http/Requests/UpdateTaskRequest ..................................... 100.0%  
Http/Resources/TaskResource ......................................... 100.0%  
Models/Task ......................................................... 100.0%  
────────────────────────────────────────────────────────────────────────────  
                                                                 Total: 90.7 %  
```

**✅ Esto es EXCELENTE:**
- Todos los tests pasan
- Cobertura >80% (90.7%)
- Componentes críticos al 100%

### Ejemplo de Output con Problemas

```
Tests:    2 failed, 17 passed (48 assertions)

Http/Controllers/TaskController ...................................... 45.0%  
────────────────────────────────────────────────────────────────────────────  
                                                                 Total: 52.3 %  
```

**❌ Problemas:**
- Tests fallando (arreglar primero)
- Cobertura <80% (52.3%)
- Controller con baja cobertura (45%)

**Acción requerida:**
1. Arreglar tests que fallan
2. Agregar tests para cubrir casos faltantes
3. NO hacer commits hasta resolver

## 🚨 Reglas Críticas

### ❌ NUNCA hacer commits si:
1. Algún test falla
2. Cobertura <80%
3. No se ejecutó `php artisan optimize:clear` antes

### ✅ SIEMPRE hacer commits si:
1. Todos los tests pasan
2. Cobertura >80%
3. Tests siguen patrón AAA
4. Usan Factory pattern

## 🛠️ Resolver Problemas Comunes

### Tests Fallan con Error 500

```bash
# Ver logs de Laravel
tail -50 storage/logs/laravel.log

# Causa común: tabla no existe
php artisan migrate:fresh

# Limpiar caché
php artisan optimize:clear
```

### Tests Fallan por Formato de Respuesta

```php
// ❌ INCORRECTO: Comparar directamente
$response->assertJsonCount(3);

// ✅ CORRECTO: Con Resource::collection envuelve en 'data'
$response->assertJsonCount(3, 'data');
```

### Cobertura Baja

```bash
# Identificar qué falta cubrir
php artisan test --coverage --min=100

# Agregar tests para:
# - Casos de error (404, 422)
# - Validaciones
# - Casos edge (valores límite)
```

## 📝 Generar Reporte

### Guardar Resultados

```bash
# Guardar output de tests
php artisan test --coverage > test-results.txt

# Ver resultados
cat test-results.txt

# Comparar con baseline
diff baseline-coverage.txt test-results.txt
```

### Para Pull Request

```bash
# Resumen para incluir en PR:
echo "✅ Tests ejecutados: $(grep 'passed' test-results.txt)"
echo "✅ Cobertura: $(grep 'Total:' test-results.txt)"
```

## 💡 Tips

1. **Ejecuta `make clear` SIEMPRE** antes de tests
2. **Usa Factory** en todos los tests, nunca datos manuales
3. **RefreshDatabase trait** es obligatorio en tests de Feature
4. **Un test por caso**, no múltiples assertions no relacionadas
5. **Nombres descriptivos**: `test_can_create_task_successfully`

## 📚 Ejemplo Real

Refactor de Tasks API:
- **Antes:** 9 tests, ~50% cobertura
- **Después:** 19 tests, 90.7% cobertura
- **Tiempo:** ~3 segundos
- **Resultado:** TODOS pasando ✅

## 🔗 Siguiente Paso

Si todos los tests pasan y cobertura >80%:
```bash
# Ver comando para commits
cat .cursor/commands/crear-commits-logicos.md
```

