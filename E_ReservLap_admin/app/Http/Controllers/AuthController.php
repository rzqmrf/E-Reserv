<?php

namespace App\Http\Controllers;


use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function index()
    {
        return view('admin.dashboard');
    }

    public function register(Request $request)
    {
        // 1. Validasi Input
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed', // Harus ada input password_confirmation
        ]);

        // 2. Simpan ke Database
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'user', // Default role
        ]);

        // 3. Otomatis Login setelah daftar (Opsional)
        Auth::login($user);

        // 4. Redirect
        return redirect('/login')->with('success', 'Akun berhasil dibuat!');
    }

    public function showLogin()
    {
        return view('auth.Login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();

            // Redirect dinamis berdasarkan role
            if (Auth::user()->role === 'admin') {
                return redirect()->intended(route('admin'));
            }

            return redirect()->intended('/dashboard');
        }

        return back()->withErrors(['email' => 'Kredensial tidak cocok.']);
    }
}
