<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $data = $request->validate([
            'full_name' => ['required', 'string', 'max:191'],
            'phone' => ['nullable', 'string', 'max:30'],
            'email' => ['required', 'email', 'max:191', 'unique:users,email'],
            'password' => ['required', 'string', Password::min(6)],
        ]);

        $user = User::create([
            'name' => $data['full_name'],
            'full_name' => $data['full_name'],
            'phone' => $data['phone'] ?? null,
            'email' => strtolower($data['email']),
            'password' => $data['password'],
        ]);

        return response()->json(['user' => $this->userData($user)], 201);
    }

    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);
        $user = User::where('email', strtolower($data['email']))->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            return response()->json(['message' => 'Email ou mot de passe incorrect.'], 422);
        }

        return response()->json([
            'token' => $user->createToken('flutter')->plainTextToken,
            'user' => $this->userData($user),
        ]);
    }

    public function me(Request $request)
    {
        return response()->json($this->userData($request->user()));
    }

    public function update(Request $request)
    {
        $user = $request->user();
        $data = $request->validate([
            'full_name' => ['required', 'string', 'max:191'],
            'phone' => ['nullable', 'string', 'max:30'],
            'email' => ['required', 'email', 'max:191', 'unique:users,email,' . $user->id],
            'photo_url' => ['nullable', 'string', 'max:500'],
        ]);
        $user->update([
            ...$data,
            'name' => $data['full_name'],
            'email' => strtolower($data['email']),
        ]);

        return response()->json($this->userData($user->fresh()));
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();
        return response()->noContent();
    }

    private function userData(User $user): array
    {
        return [
            'id' => $user->id,
            'full_name' => $user->full_name,
            'phone' => $user->phone ?? '',
            'email' => $user->email,
            'photo_url' => $user->photo_url ?? '',
        ];
    }
}