
import 'package:aplikasi_ortu/LOGIN/login.dart';
import 'package:flutter/material.dart';

class DaftarPage extends StatelessWidget {
  const DaftarPage({super.key});

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
                      const SizedBox(height: 8),
                      const Text(
                        'IBS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const Text(
                        'Islamic Boarding School',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
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
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45),
                        bottomRight: Radius.circular(45),
                        bottomLeft: Radius.circular(45),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email Input
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Nama:',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email Input
                        TextField(
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
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password:',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            //suffixIcon: const Icon(Icons.visibility_off),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login Button
                        ElevatedButton(
                            onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 140, 255),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              color: Colors
                                  .white, // Warna teks putih agar lebih jelas
                              fontSize: 16, // Ukuran teks sedikit lebih besar
                              fontWeight:
                                  FontWeight.bold, // Membuat teks lebih tegas
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
