<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

/*
|--------------------------------------------------------------------------
| API Routes - Version 1
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group with the "v1" prefix.
|
*/

// Authentication Routes
Route::prefix('v1')->group(function () {

    // Public routes
    Route::post('/login', function (Request $request) {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Invalid credentials'
            ], 401);
        }

        // Create token with optional abilities
        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ]
        ]);
    })->name('api.v1.login');

    // Protected routes (require authentication)
    Route::middleware('auth:sanctum')->group(function () {

        // Get authenticated user
        Route::get('/user', function (Request $request) {
            return response()->json([
                'user' => $request->user()
            ]);
        })->name('api.v1.user');

        // Logout (revoke current token)
        Route::post('/logout', function (Request $request) {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'message' => 'Token revoked successfully'
            ]);
        })->name('api.v1.logout');

        // Logout all devices (revoke all tokens)
        Route::post('/logout-all', function (Request $request) {
            $request->user()->tokens()->delete();

            return response()->json([
                'message' => 'All tokens revoked successfully'
            ]);
        })->name('api.v1.logout-all');

        // Example: List user's active tokens
        Route::get('/tokens', function (Request $request) {
            return response()->json([
                'tokens' => $request->user()->tokens()->get(['id', 'name', 'last_used_at', 'created_at'])
            ]);
        })->name('api.v1.tokens');

        // Add your protected API routes here
        // Example:
        // Route::apiResource('posts', PostController::class);
    });
});
