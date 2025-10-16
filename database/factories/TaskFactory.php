<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Task>
 */
class TaskFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $taskTitles = [
            'Revisar documentación del proyecto',
            'Implementar autenticación de usuarios',
            'Corregir bugs reportados',
            'Actualizar dependencias del proyecto',
            'Escribir tests unitarios',
            'Realizar code review',
            'Optimizar consultas de base de datos',
            'Diseñar interfaz de usuario',
            'Configurar servidor de producción',
            'Preparar presentación para el cliente',
            'Refactorizar código legacy',
            'Crear backup de la base de datos',
            'Actualizar documentación técnica',
            'Investigar nueva tecnología',
            'Resolver issue de GitHub',
        ];

        return [
            'title' => fake()->randomElement($taskTitles),
            'description' => fake()->optional(0.7)->paragraph(),
            'status' => fake()->randomElement(['pendiente', 'en progreso', 'completada']),
        ];
    }
}
