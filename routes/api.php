<?php

use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// ============================================================================
// MALAS PRÁCTICAS INTENCIONALES - PARA DEMOSTRACIÓN DE REFACTORIZACIÓN
// ============================================================================
// Este código muestra deliberadamente malas prácticas:
// - Validación manual mezclada con lógica de negocio
// - Sin separación de responsabilidades
// - Código duplicado
// - Sin usar FormRequests, Resources ni Controllers
// - Manejo de errores genérico
// ============================================================================

/**
 * POST /api/tasks - Crear una nueva tarea
 * Ejemplo de MALAS PRÁCTICAS:
 * - Validación manual campo por campo
 * - Lógica de negocio en la ruta
 * - Respuesta sin formato consistente
 */
Route::post('/tasks', function (Request $request) {
    // 1. Validación manual, campo por campo (MAL)
    if (!$request->has('title') || $request->input('title') === '') {
        return response()->json([
            'message' => 'El campo title es requerido.',
            'errors' => [
                'title' => ['El campo title es requerido.']
            ]
        ], 422);
    }

    if (strlen($request->input('title')) > 255) {
        return response()->json([
            'message' => 'El title no debe ser mayor a 255 caracteres.',
            'errors' => [
                'title' => ['El title no debe ser mayor a 255 caracteres.']
            ]
        ], 422);
    }

    if ($request->has('description') && !is_string($request->input('description'))) {
        return response()->json([
            'message' => 'La descripción debe ser una cadena de texto.',
        ], 422);
    }

    $allowedStatus = ['pendiente', 'en progreso', 'completada'];
    if ($request->has('status') && !in_array($request->input('status'), $allowedStatus)) {
        return response()->json([
            'message' => 'El status seleccionado es inválido.',
            'errors' => [
                'status' => ['El status debe ser uno de: pendiente, en progreso, completada']
            ]
        ], 422);
    }
    
    // 2. Lógica de negocio mezclada con la definición de la ruta (MAL)
    try {
        $task = new Task();
        $task->title = $request->input('title');
        $task->description = $request->input('description'); // Si no viene, será null
        $task->status = $request->input('status', 'pendiente'); // Default manual
        $task->save();

        // 3. Respuesta manual sin formato consistente (MAL)
        return response()->json([
            'data' => [
                'id' => $task->id,
                'title' => $task->title,
                'description' => $task->description,
                'status' => $task->status,
                'created_at' => $task->created_at,
                'updated_at' => $task->updated_at,
            ]
        ], 201);

    } catch (\Exception $e) {
        // 4. Manejo de errores genérico y poco informativo (MAL)
        return response()->json([
            'message' => 'Ocurrió un error inesperado al crear la tarea.',
            'error' => $e->getMessage()
        ], 500);
    }
});

/**
 * GET /api/tasks - Listar todas las tareas
 * Ejemplo de MALAS PRÁCTICAS:
 * - Sin paginación
 * - Sin filtros
 * - Respuesta sin formato consistente
 */
Route::get('/tasks', function (Request $request) {
    try {
        // Sin paginación ni filtros (MAL)
        $tasks = Task::all();
        
        // Respuesta inconsistente con el POST (MAL)
        $tasksArray = [];
        foreach ($tasks as $task) {
            $tasksArray[] = [
                'id' => $task->id,
                'title' => $task->title,
                'description' => $task->description,
                'status' => $task->status,
                'created_at' => $task->created_at->format('Y-m-d H:i:s'),
                'updated_at' => $task->updated_at->format('Y-m-d H:i:s'),
            ];
        }
        
        return response()->json($tasksArray, 200);
        
    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Error al obtener las tareas.',
            'error' => $e->getMessage()
        ], 500);
    }
});

/**
 * GET /api/tasks/{id} - Obtener una tarea específica
 * Ejemplo de MALAS PRÁCTICAS:
 * - Sin validación de ID
 * - Manejo de errores inconsistente
 */
Route::get('/tasks/{id}', function ($id) {
    try {
        // Sin validación del ID (MAL)
        $task = Task::find($id);
        
        // Validación mezclada con lógica (MAL)
        if (!$task) {
            return response()->json([
                'message' => 'Tarea no encontrada',
            ], 404);
        }
        
        // Formato diferente otra vez (MAL)
        return response()->json([
            'task' => [
                'id' => $task->id,
                'title' => $task->title,
                'description' => $task->description,
                'status' => $task->status,
                'created_at' => $task->created_at,
                'updated_at' => $task->updated_at,
            ]
        ], 200);
        
    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Error al buscar la tarea.',
            'error' => $e->getMessage()
        ], 500);
    }
});

/**
 * PUT /api/tasks/{id} - Actualizar una tarea
 * Ejemplo de MALAS PRÁCTICAS:
 * - Validación duplicada del POST
 * - Sin reutilización de código
 */
Route::put('/tasks/{id}', function (Request $request, $id) {
    try {
        $task = Task::find($id);
        
        if (!$task) {
            return response()->json([
                'message' => 'La tarea no existe',
            ], 404);
        }
        
        // Validación duplicada (MAL - código copiado del POST)
        if ($request->has('title')) {
            if ($request->input('title') === '') {
                return response()->json([
                    'message' => 'El campo title no puede estar vacío.',
                ], 422);
            }
            
            if (strlen($request->input('title')) > 255) {
                return response()->json([
                    'message' => 'El title no debe ser mayor a 255 caracteres.',
                ], 422);
            }
            
            $task->title = $request->input('title');
        }
        
        if ($request->has('description')) {
            if (!is_string($request->input('description'))) {
                return response()->json([
                    'message' => 'La descripción debe ser texto.',
                ], 422);
            }
            $task->description = $request->input('description');
        }
        
        if ($request->has('status')) {
            $allowedStatus = ['pendiente', 'en progreso', 'completada'];
            if (!in_array($request->input('status'), $allowedStatus)) {
                return response()->json([
                    'message' => 'Status inválido.',
                ], 422);
            }
            $task->status = $request->input('status');
        }
        
        $task->save();
        
        // Otro formato diferente (MAL)
        return response()->json([
            'success' => true,
            'data' => $task
        ], 200);
        
    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Error al actualizar.',
            'error' => $e->getMessage()
        ], 500);
    }
});

/**
 * DELETE /api/tasks/{id} - Eliminar una tarea
 * Ejemplo de MALAS PRÁCTICAS:
 * - Sin validación adecuada
 * - Manejo inconsistente de respuestas
 */
Route::delete('/tasks/{id}', function ($id) {
    try {
        // Sin validación del formato del ID (MAL)
        $task = Task::find($id);
        
        if (!$task) {
            return response()->json([
                'error' => 'No se encontró la tarea',
            ], 404);
        }
        
        $task->delete();
        
        // Respuesta inconsistente con otros endpoints (MAL)
        return response()->json([
            'mensaje' => 'Tarea eliminada exitosamente',
            'deleted_id' => $id
        ], 200);
        
    } catch (\Exception $e) {
        return response()->json([
            'message' => 'No se pudo eliminar la tarea.',
            'error' => $e->getMessage()
        ], 500);
    }
});

// ============================================================================
// RUTA ORIGINAL CON BUENAS PRÁCTICAS (comentada para comparación)
// ============================================================================
// Route::post('/tasks', [TaskController::class, 'store']);
