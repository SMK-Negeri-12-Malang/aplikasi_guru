import 'dart:async';
import 'package:aplikasi_guru/LOGIN/login.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageAnimation;
  late Animation<double> _scaleAnimation;

  String _text = "Islamic Boarding School";
  String _displayedText = "";
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _imageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    Future.delayed(Duration(milliseconds: 1000), () {
      _startTextAnimation();
    });

    Timer(Duration(seconds: 4), () {
      _textTimer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  void _startTextAnimation() {
    int currentIndex = 0;
    _textTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        if (currentIndex < _text.length) {
          _displayedText = _text.substring(0, currentIndex + 1);
          currentIndex++;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _imageAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset('assets/logo/ibs.png', width: 350),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _displayedText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 153, 51),
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
