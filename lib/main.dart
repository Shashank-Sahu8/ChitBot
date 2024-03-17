import 'package:flutter/material.dart';
import 'package:untitled/bot.dart';
import 'package:untitled/splash%20screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff0077FF)),
        useMaterial3: true,
      ),
      home: splash_screen1(),
    );
  }
}
