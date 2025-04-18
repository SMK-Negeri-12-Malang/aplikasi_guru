import 'package:aplikasi_guru/PETUGAS_KEAMANAN/Home/home_petugas.dart';
import 'package:aplikasi_guru/main.dart';
import 'package:aplikasi_guru/ANIMASI/user_data_manager.dart';
import 'package:flutter/material.dart';
import '../SERVICE/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  Future<void> _checkExistingLogin() async {
    final isLoggedIn = await UserDataManager.isLoggedIn();
    if (isLoggedIn) {
      final email = await UserDataManager.getUserEmail();
      final password = await UserDataManager.getUserPassword();
      
      if (email != null && password != null) {
        setState(() => _isLoading = true);
        
        try {
          final response = await _authService.login(email, password);
          
          if (response.$1 != null) { // Guru login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => homeview()),
            );
            return; // Add return to prevent further execution
          } else if (response.$2 != null) { // Musyrif login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MusyrifDashboard()),
            );
            return; // Add return to prevent further execution
          } else if (response.$3 != null) { // Guru Quran login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GuruQuranDashboard()),
            );
            return; // Add return to prevent further execution
          } else if (response.$4 != null) { // Security Guard login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PetugasKeamananDashboard()),
            );
            return; // Add return to prevent further execution
          }
        } catch (e) {
          // If auto-login fails, we'll just show the login screen
          await UserDataManager.clearUserData(); // Clear invalid credentials
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final (guru, musyrif, guruQuran, securityGuard) = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (guru != null) {
        await UserDataManager.saveUserData(
          guru.name,
          guru.email,
          _passwordController.text
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => homeview()),
        );
      } else if (musyrif != null) {
        await UserDataManager.saveUserData(
          musyrif.name,
          musyrif.email,
          _passwordController.text
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MusyrifDashboard()),
        );
      } else if (guruQuran != null) {
        await UserDataManager.saveUserData(
          guruQuran.name,
          guruQuran.email,
          _passwordController.text
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GuruQuranDashboard()),
        );
      } else if (securityGuard != null) {
        await UserDataManager.saveUserData(
          securityGuard.name,
          securityGuard.email,
          _passwordController.text
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PetugasKeamananDashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal. Periksa email dan password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan. Silakan coba lagi')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 216, 238, 255),
              Color.fromARGB(255, 0, 122, 221),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png', // Replace with your asset path
                        height: 80,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Welcome Text Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(45),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email Input
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email:',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password Input
                        TextField(
                          controller: _passwordController,
                          obscureText:
                              !_isPasswordVisible, // Terkait visibilitas
                          decoration: InputDecoration(
                            labelText: 'Password:',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible =
                                      !_isPasswordVisible; // Toggle visibilitas
                                });
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            if (!_isLoading) {
                              _handleLogin();
                            }
                          },
                        ),



                        const SizedBox(height: 20),

                        // Login Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 140, 255),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
