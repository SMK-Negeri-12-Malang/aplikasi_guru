import 'dart:async';
import 'dart:developer' as developer;
import 'package:aplikasi_guru/PETUGAS_KEAMANAN/Home/home_petugas.dart';
import 'package:aplikasi_guru/main.dart';
import 'package:aplikasi_guru/ANIMASI/user_data_manager.dart';
import 'package:flutter/material.dart';
import '../SERVICE/auth_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _startLoadingTimer() {
    _loadingTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waktu login habis. Silakan coba lagi')),
        );
      }
    });
  }

  void _cancelLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
  }

  Future<void> _checkExistingLogin() async {
    final isLoggedIn = await UserDataManager.isLoggedIn();
    if (isLoggedIn) {
      final email = await UserDataManager.getUserEmail();
      final password = await UserDataManager.getUserPassword();
      
      if (email != null && password != null) {
        setState(() => _isLoading = true);
        _startLoadingTimer();
        
        try {
          bool hasInternet = await _checkInternetConnection();
          if (!hasInternet) {
            throw Exception('No internet connection');
          }
          
          final response = await _authService.login(email, password);
          _cancelLoadingTimer();
          
          if (response.$1 != null) { // Guru login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => homeview()),
            );
            return;
          } else if (response.$2 != null) { // Musyrif login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MusyrifDashboard()),
            );
            return;
          } else if (response.$3 != null) { // Guru Quran login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GuruQuranDashboard()),
            );
            return;
          } else if (response.$4 != null) { // Security Guard login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PetugasKeamananDashboard()),
            );
            return;
          } else {
            await UserDataManager.clearUserData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email atau password salah. Silakan login kembali')),
            );
          }
        } catch (e) {
          _cancelLoadingTimer();
          await UserDataManager.clearUserData();
          
          if (e.toString().contains('No internet connection')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak ada koneksi internet. Silakan periksa jaringan Anda')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terjadi kesalahan. Silakan coba lagi')),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showErrorMessage('Email dan password tidak boleh kosong');
      return;
    }
    
    setState(() => _isLoading = true);
    _startLoadingTimer();

    try {
      bool hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        throw Exception('No internet connection');
      }
      
      developer.log('Attempting login with email: ${_emailController.text.trim()}');
      
      final response = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Login timeout'),
      );

      _cancelLoadingTimer();
      
      developer.log('Login response received: $response');

      if (response.$1 != null) {
        print("Guru login successful");
        await UserDataManager.saveUserData(
          response.$1!.name,
          response.$1!.email,
          _passwordController.text
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => homeview()),
          );
        }
      } else if (response.$2 != null) {
        print("Musyrif login successful");
        await UserDataManager.saveUserData(
          response.$2!.name,
          response.$2!.email,
          _passwordController.text
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MusyrifDashboard()),
          );
        }
      } else if (response.$3 != null) {
        print("Guru Quran login successful");
        await UserDataManager.saveUserData(
          response.$3!.name,
          response.$3!.email,
          _passwordController.text
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GuruQuranDashboard()),
          );
        }
      } else if (response.$4 != null) {
        print("Security Guard login successful");
        await UserDataManager.saveUserData(
          response.$4!.name,
          response.$4!.email,
          _passwordController.text
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PetugasKeamananDashboard()),
          );
        }
      } else {
        developer.log('Login failed: Invalid credentials');
        _showErrorMessage('Email atau password salah');
      }
    } on TimeoutException {
      _cancelLoadingTimer();
      _showErrorMessage('Koneksi timeout. Silakan coba lagi');
    } catch (e) {
      _cancelLoadingTimer();
      developer.log('Login error: $e');
      if (e.toString().contains('No internet connection')) {
        _showErrorMessage('Tidak ada koneksi internet');
      } else {
        _showErrorMessage('Terjadi kesalahan: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cancelLoadingTimer();
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
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

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

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
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
 
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
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
                                  _isPasswordVisible = !_isPasswordVisible;
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