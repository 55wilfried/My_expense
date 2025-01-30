import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_expense/screen/base_screen.dart';


///
///this is the class for the splash screen
///author: i-tech sarl
///created at: May 2023
///
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      Get.offAll(() =>  BaseScreen(selectedIndex: 0));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const foregroundMaterials = 0xFFD0CECC;
    return Scaffold(
      backgroundColor: const Color(foregroundMaterials),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Image.asset(
                "assets/images/sketch7M.png",
                height: 500.0,
                width: 500.0,
              ),
              const Text(
                'My Expenses',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                ),
              ),
            ],
          ),
          const Text(
            'F-Wilfried',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }
}
