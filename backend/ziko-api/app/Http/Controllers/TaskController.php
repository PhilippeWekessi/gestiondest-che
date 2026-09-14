<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index()
    {
        return Task::where('user_id', auth()->id())->orderBy('date_time', 'desc')->get();
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'nullable|string',
            'date_time' => 'required|date',
            'priority' => 'required|in:high,medium,low',
        ]);

        $validated['user_id'] = auth()->id();
        return response()->json(Task::create($validated), 201);
    }

    public function show(Task $task)
    {
        abort_unless($task->user_id === auth()->id(), 404);
        return $task;
    }

    public function update(Request $request, Task $task)
    {
        abort_unless($task->user_id === auth()->id(), 404);
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'nullable|string',
            'date_time' => 'required|date',
            'priority' => 'required|in:high,medium,low',
        ]);

        $task->update($validated);

        return response()->json($task);
    }

    public function destroy(Task $task)
    {
        abort_unless($task->user_id === auth()->id(), 404);
        $task->delete();

        return response()->json(null, 204);
    }
}
