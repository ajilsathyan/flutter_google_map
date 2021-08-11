import 'package:flutter/material.dart';
import 'package:google_map/screens/MapHome.dart';
import 'package:google_map/screens/splash_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home:SplashScreen(),
    );
  }
}