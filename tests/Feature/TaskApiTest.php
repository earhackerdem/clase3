<?php

namespace Tests\Feature;

use App\Models\Task;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class TaskApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test que se puede crear una tarea válida exitosamente.
     */
    public function test_can_create_task_successfully(): void
    {
        $taskData = [
            'title' => 'Nueva tarea de prueba',
            'description' => 'Descripción detallada de la tarea',
            'status' => 'pendiente',
        ];

        $response = $this->postJson('/api/tasks', $taskData);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'title',
                    'description',
                    'status',
                    'created_at',
                    'updated_at',
                ],
            ])
            ->assertJson([
                'data' => [
                    'title' => 'Nueva tarea de prueba',
                    'description' => 'Descripción detallada de la tarea',
                    'status' => 'pendiente',
                ],
            ]);

        $this->assertDatabaseHas('tasks', [
            'title' => 'Nueva tarea de prueba',
            'description' => 'Descripción detallada de la tarea',
            'status' => 'pendiente',
        ]);
    }

    /**
     * Test que se puede crear una tarea sin descripción.
     */
    public function test_can_create_task_without_description(): void
    {
        $taskData = [
            'title' => 'Tarea sin descripción',
            'status' => 'en progreso',
        ];

        $response = $this->postJson('/api/tasks', $taskData);

        $response->assertStatus(201)
            ->assertJson([
                'data' => [
                    'title' => 'Tarea sin descripción',
                    'description' => null,
                    'status' => 'en progreso',
                ],
            ]);
    }

    /**
     * Test que se puede crear una tarea sin status (usa default).
     */
    public function test_can_create_task_without_status(): void
    {
        $taskData = [
            'title' => 'Tarea con status default',
        ];

        $response = $this->postJson('/api/tasks', $taskData);

        $response->assertStatus(201)
            ->assertJson([
                'data' => [
                    'title' => 'Tarea con status default',
                    'status' => 'pendiente',
                ],
            ]);
    }

    /**
     * Test que falla cuando el título está vacío.
     */
    public function test_fails_when_title_is_empty(): void
    {
        $taskData = [
            'description' => 'Descripción sin título',
        ];

        $response = $this->postJson('/api/tasks', $taskData);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title']);
    }

    /**
     * Test que falla cuando el título excede el máximo permitido.
     */
    public function test_fails_when_title_exceeds_max_length(): void
    {
        $taskData = [
            'title' => str_repeat('a', 256), // 256 caracteres, máximo es 255
        ];

        $response = $this->postJson('/api/tasks', $taskData);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title']);
    }

    /**
     * Test que falla cuando el status es inválido.
     */
    public function test_fails_when_status_is_invalid(): void
    {
        $taskData = [
            'title' => 'Tarea con status inválido',
            'status' => 'status_invalido',
        ];

        $response = $this->postJson('/api/tasks', $taskData);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['status']);
    }

    /**
     * Test que acepta todos los status válidos.
     */
    public function test_accepts_all_valid_status(): void
    {
        $validStatuses = ['pendiente', 'en progreso', 'completada'];

        foreach ($validStatuses as $status) {
            $taskData = [
                'title' => "Tarea con status {$status}",
                'status' => $status,
            ];

            $response = $this->postJson('/api/tasks', $taskData);

            $response->assertStatus(201)
                ->assertJson([
                    'data' => [
                        'status' => $status,
                    ],
                ]);
        }

        $this->assertDatabaseCount('tasks', 3);
    }

    // ==================== GET /api/tasks (index) ====================

    /**
     * Test que puede listar todas las tareas.
     */
    public function test_can_list_all_tasks(): void
    {
        // Arrange: Crear 3 tareas usando factory
        $tasks = Task::factory()->count(3)->create();

        // Act: Hacer GET a /api/tasks
        $response = $this->getJson('/api/tasks');

        // Assert: Verificar respuesta (Resource::collection envuelve en 'data')
        $response->assertStatus(200)
            ->assertJsonCount(3, 'data');
    }

    /**
     * Test que retorna un array vacío cuando no hay tareas.
     */
    public function test_returns_empty_array_when_no_tasks(): void
    {
        // Arrange: No crear tareas

        // Act: Hacer GET a /api/tasks
        $response = $this->getJson('/api/tasks');

        // Assert: Verificar array vacío (Resource::collection envuelve en 'data')
        $response->assertStatus(200)
            ->assertJsonCount(0, 'data');
    }

    // ==================== GET /api/tasks/{id} (show) ====================

    /**
     * Test que puede mostrar una tarea específica.
     */
    public function test_can_show_single_task(): void
    {
        // Arrange: Crear una tarea usando factory
        $task = Task::factory()->create([
            'title' => 'Tarea de prueba',
            'description' => 'Descripción de prueba',
            'status' => 'pendiente',
        ]);

        // Act: Hacer GET a /api/tasks/{id}
        $response = $this->getJson("/api/tasks/{$task->id}");

        // Assert: Verificar respuesta
        $response->assertStatus(200)
            ->assertJsonFragment([
                'title' => 'Tarea de prueba',
                'description' => 'Descripción de prueba',
                'status' => 'pendiente',
            ]);
    }

    /**
     * Test que retorna 404 cuando la tarea no existe.
     */
    public function test_returns_404_when_task_not_found(): void
    {
        // Arrange: ID que no existe
        $nonExistentId = 99999;

        // Act: Hacer GET a /api/tasks/{id} inexistente
        $response = $this->getJson("/api/tasks/{$nonExistentId}");

        // Assert: Verificar 404
        $response->assertStatus(404);
    }

    // ==================== PUT /api/tasks/{id} (update) ====================

    /**
     * Test que puede actualizar una tarea exitosamente.
     */
    public function test_can_update_task_successfully(): void
    {
        // Arrange: Crear tarea con factory
        $task = Task::factory()->create([
            'title' => 'Título Original',
            'description' => 'Descripción Original',
            'status' => 'pendiente',
        ]);

        // Act: Actualizar todos los campos
        $updateData = [
            'title' => 'Título Actualizado',
            'description' => 'Descripción Actualizada',
            'status' => 'completada',
        ];

        $response = $this->putJson("/api/tasks/{$task->id}", $updateData);

        // Assert: Verificar respuesta y BD
        $response->assertStatus(200);

        $this->assertDatabaseHas('tasks', [
            'id' => $task->id,
            'title' => 'Título Actualizado',
            'description' => 'Descripción Actualizada',
            'status' => 'completada',
        ]);
    }

    /**
     * Test que puede actualizar solo algunos campos (actualización parcial).
     */
    public function test_can_update_partial_fields(): void
    {
        // Arrange: Crear tarea
        $task = Task::factory()->create([
            'title' => 'Título Original',
            'description' => 'Descripción Original',
            'status' => 'pendiente',
        ]);

        // Act: Actualizar solo el título
        $updateData = [
            'title' => 'Solo Título Actualizado',
        ];

        $response = $this->putJson("/api/tasks/{$task->id}", $updateData);

        // Assert: Verificar que solo el título cambió
        $response->assertStatus(200);

        $this->assertDatabaseHas('tasks', [
            'id' => $task->id,
            'title' => 'Solo Título Actualizado',
            'description' => 'Descripción Original', // No cambió
            'status' => 'pendiente', // No cambió
        ]);
    }

    /**
     * Test que falla al actualizar tarea que no existe.
     */
    public function test_fails_update_when_task_not_exists(): void
    {
        // Arrange: ID inexistente
        $nonExistentId = 99999;

        // Act: Intentar actualizar tarea inexistente
        $updateData = [
            'title' => 'Título Nuevo',
        ];

        $response = $this->putJson("/api/tasks/{$nonExistentId}", $updateData);

        // Assert: Verificar 404
        $response->assertStatus(404);
    }

    /**
     * Test que falla al actualizar con datos inválidos.
     */
    public function test_fails_update_with_invalid_data(): void
    {
        // Arrange: Crear tarea
        $task = Task::factory()->create();

        // Act: Intentar actualizar con título vacío
        $updateData = [
            'title' => '', // Título vacío (inválido)
        ];

        $response = $this->putJson("/api/tasks/{$task->id}", $updateData);

        // Assert: Verificar error de validación
        $response->assertStatus(422);
    }

    // ==================== DELETE /api/tasks/{id} (destroy) ====================

    /**
     * Test que puede eliminar una tarea exitosamente.
     */
    public function test_can_delete_task_successfully(): void
    {
        // Arrange: Crear tarea con factory
        $task = Task::factory()->create();

        // Act: Eliminar la tarea
        $response = $this->deleteJson("/api/tasks/{$task->id}");

        // Assert: Verificar respuesta y que ya no existe en BD
        $response->assertStatus(200);

        $this->assertDatabaseMissing('tasks', [
            'id' => $task->id,
        ]);
    }

    /**
     * Test que falla al eliminar tarea que no existe.
     */
    public function test_fails_delete_when_task_not_found(): void
    {
        // Arrange: ID inexistente
        $nonExistentId = 99999;

        // Act: Intentar eliminar tarea inexistente
        $response = $this->deleteJson("/api/tasks/{$nonExistentId}");

        // Assert: Verificar 404
        $response->assertStatus(404);
    }
}
