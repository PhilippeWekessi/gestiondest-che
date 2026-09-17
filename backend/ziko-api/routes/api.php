<?php

use App\Http\Controllers\TaskController;
use App\Http\Controllers\Auth\AuthController;
use Illuminate\Support\Facades\Route;

// Routes publiques (pas besoin d'être connecté)
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Routes des tâches — publiques pour l'instant (Livrable 2)
Route::apiResource('tasks', TaskController::class);

// Routes protégées (nécessitent un token valide)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);
});