<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Field;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use App\Models\Schedule;

class FieldController extends Controller
{
    public function index()
    {

        $fields = Field::all();
        $schedules = Schedule::all();

        return response()->json(
            Field::all(['id', 'name', 'foto_lapangan', 'type', 'price', 'status', 'description', 'capacity', 'location_type'])
        );
    }

    public function show($id)
    {
        $field = Field::findOrFail($id);
        return response()->json($field);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'          => 'required|string|max:255',
            'foto_lapangan' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:4096',
            'type'          => 'required|string|max:100',
            'price'         => 'required|numeric|min:0',
            'status'        => ['required', Rule::in(['available', 'unavailable'])],
            'description'   => 'nullable|string',
        ]);

        if ($request->hasFile('foto_lapangan')) {
            $path = $request->file('foto_lapangan')->store('fields', 'public');
            $validated['foto_lapangan'] = $path;
        }

        $field = Field::create($validated);

        return response()->json($field, 201);
    }

    public function update(Request $request, $id)
    {
        try {
            $field = Field::findOrFail($id);

            $validated = $request->validate([
                'name'          => 'required|string|max:255',
                'foto_lapangan' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:4096',
                'type'          => 'required|string|max:100',
                'price'         => 'required|numeric|min:0',
                'status'        => ['required', Rule::in(['available', 'unavailable'])],
                'description'   => 'nullable|string',
            ]);

            if ($request->hasFile('foto_lapangan')) {
                // Hapus foto lama jika ada
                if ($field->foto_lapangan && Storage::disk('public')->exists($field->foto_lapangan)) {
                    Storage::disk('public')->delete($field->foto_lapangan);
                }
                $path = $request->file('foto_lapangan')->store('fields', 'public');
                $validated['foto_lapangan'] = $path;
            }

            $field->update($validated);

            return response()->json([
                'status' => 'success',
                'message' => 'Lapangan berhasil diperbarui',
                'data' => $field->fresh()
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        $field = Field::findOrFail($id);

        // Hapus foto dari storage
        if ($field->foto_lapangan) {
            Storage::disk('public')->delete($field->foto_lapangan);
        }

        $field->delete();

        return response()->json(['message' => 'Lapangan berhasil dihapus']);
    }
}
