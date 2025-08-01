import 'package:hb_booking_mobile_app/bottom_navigation/landing_page.dart';
import 'package:hb_booking_mobile_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/splash/splash1.gif',
        fit: BoxFit.cover,  // Ensures the GIF covers the entire screen
        width: double.infinity,  // Set width to fill the screen
        height: double.infinity,// Set the desired height
      ),
    );
  }
}
