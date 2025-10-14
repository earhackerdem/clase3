<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTaskRequest;
use App\Models\Task;
use Illuminate\Http\JsonResponse;

class TaskController extends Controller
{
    public function store(StoreTaskRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $task = Task::create($validated);

        return response()->json([
            'data' => $task,
            'message' => 'Tarea creada correctamente',
        ], 201);
    }
}
