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

    public function test_can_get_all_tasks(): void
    {
        Task::factory()->count(3)->create();

        $response = $this->getJson('/api/tasks');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data');
    }

    public function test_can_get_a_single_task(): void
    {
        $task = Task::factory()->create();

        $response = $this->getJson('/api/tasks/' . $task->id);

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'id' => $task->id,
                    'title' => $task->title,
                ]
            ]);
    }

    public function test_returns_404_for_non_existent_task(): void
    {
        $response = $this->getJson('/api/tasks/999');

        $response->assertStatus(404);
    }

    public function test_can_update_a_task(): void
    {
        $task = Task::factory()->create();

        $updateData = [
            'title' => 'Título actualizado',
            'status' => 'completada',
        ];

        $response = $this->putJson('/api/tasks/' . $task->id, $updateData);

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'title' => 'Título actualizado',
                    'status' => 'completada',
                ]
            ]);

        $this->assertDatabaseHas('tasks', [
            'id' => $task->id,
            'title' => 'Título actualizado',
        ]);
    }

    public function test_can_delete_a_task(): void
    {
        $task = Task::factory()->create();

        $response = $this->deleteJson('/api/tasks/' . $task->id);

        $response->assertStatus(204);

        $this->assertDatabaseMissing('tasks', ['id' => $task->id]);
    }
}
