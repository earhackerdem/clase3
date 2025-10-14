<?php

namespace Database\Factories;

use App\Models\Task;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Task>
 */
class TaskFactory extends Factory
{
    protected $model = Task::class;

    public function definition(): array
    {
        $statuses = ['pendiente', 'en progreso', 'completada'];

        return [
            'title' => $this->faker->sentence(6, true),
            'description' => $this->faker->optional()->paragraphs(2, true),
            'status' => $this->faker->randomElement($statuses),
        ];
    }
}
