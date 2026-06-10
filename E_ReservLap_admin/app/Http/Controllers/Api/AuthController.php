<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class AuthController extends Controller
{
    /**
     * Handle API Login
     */
    public function apilogin(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'Email atau password salah.'
            ], 401);
        }

        //cek apakah user adalah admin
        if ($user->role === 'admin') {
            return response()->json([
                'message' => 'Akses ditolak: Admin tidak diperbolehkan login melalui aplikasi ini.'
            ], 403);
        }

        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email atau password salah.'
            ], 401);
        }

        // Generate Sanctum Token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
            'message' => 'Login berhasil'
        ]);
    }

    /**
     * Handle API Register
     */
    public function apiregister(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:20',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'role' => 'user',
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
            'message' => 'Registrasi berhasil'
        ], 201);
    }

    /**
     * Forgot Password — Reset langsung tanpa email
     * POST /api/forgot-password
     * Body: { email, password, password_confirmation }
     */
    public function forgotPassword(Request $request)
    {
        $request->validate([
            'email'                 => ['required', 'email'],
            'password'              => ['required', 'string', 'min:6', 'confirmed'],
            'password_confirmation' => ['required'],
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'Email tidak ditemukan. Pastikan email yang Anda masukkan sudah terdaftar.'
            ], 404);
        }

        // Cegah admin reset via app
        if ($user->role === 'admin') {
            return response()->json([
                'message' => 'Akses ditolak.'
            ], 403);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'message' => 'Password berhasil diperbarui. Silakan login dengan password baru Anda.'
        ]);
    }

    /**
     * Handle API Logout
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil'
        ]);
    }

    /**
     * Upload Foto Profil
     * POST /api/profile/photo  (auth:sanctum)
     */
    public function uploadProfilePhoto(Request $request)
    {
        $request->validate([
            'photo' => ['required', 'file', 'image', 'mimes:jpg,jpeg,png,webp', 'max:3072'], // max 3MB
        ]);

        $user = $request->user();

        // Hapus foto lama jika ada (ambil nilai mentah dari DB, bukan accessor)
        $oldPath = $user->getAttributes()['photo_url'] ?? null;
        if ($oldPath && !str_starts_with($oldPath, 'http')) {
            Storage::disk('public')->delete($oldPath);
        }

        // Simpan file baru → storage/app/public/profile_photos/{userId}_{timestamp}.jpg
        $path = $request->file('photo')->store(
            'profile_photos',
            'public'
        );

        // Simpan path mentah ke DB
        $user->setAttribute('photo_url', $path);
        $user->save();

        // Refresh model agar accessor mengembalikan URL lengkap
        $user->refresh();

        return response()->json([
            'message'   => 'Foto profil berhasil diperbarui.',
            'photo_url' => $user->photo_url, // accessor sudah mengembalikan URL penuh
            'user'      => $user,
        ]);
    }

    /**
     * Update Profil (nama & telepon)
     * PUT /api/profile  (auth:sanctum)
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name'  => ['required', 'string', 'max:255'],
            'phone' => ['required', 'string', 'max:20'],
        ]);

        $user->name  = $request->name;
        $user->phone = $request->phone;
        $user->save();

        return response()->json([
            'message' => 'Profil berhasil diperbarui.',
            'user'    => $user,
        ]);
    }

    /**
     * Ubah Password
     * PUT /api/profile/password  (auth:sanctum)
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => ['required', 'string'],
            'password'     => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $user = $request->user();

        if (!Hash::check($request->old_password, $user->password)) {
            return response()->json([
                'message' => 'Password lama tidak cocok.'
            ], 422);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'message' => 'Password berhasil diubah.'
        ]);
    }
}

