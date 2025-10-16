<?php

use App\Http\Controllers\PostController;
use App\Http\Controllers\TaskController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Tasks API Resource - Todas las rutas CRUD en una línea
Route::apiResource('tasks', TaskController::class);

// Posts API Resource - Todas las rutas CRUD en una línea
Route::apiResource('posts', PostController::class);

