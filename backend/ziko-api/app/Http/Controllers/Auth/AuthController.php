public function login(Request $request)
{
    $validated = $request->validate([
        'identifier' => 'required|string', // email ou téléphone
        'password' => 'required|string',
    ]);

    $user = User::where('email', $validated['identifier'])
        ->orWhere('phone', $validated['identifier'])
        ->first();

    if (!$user || !Hash::check($validated['password'], $user->password)) {
        throw ValidationException::withMessages([
            'identifier' => ['Identifiants incorrects.'],
        ]);
    }

    $token = $user->createToken('ziko-token')->plainTextToken;

    return response()->json([
        'user' => $user,
        'token' => $token,
    ], 200);
}

public function updateProfile(Request $request)
{
    $user = $request->user();

    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'phone' => 'nullable|string|max:20',
        'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
    ]);

    $user->update($validated);

    return response()->json($user, 200);
}