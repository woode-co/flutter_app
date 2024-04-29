import 'package:flutter/material.dart';
import 'package:woodeco/app/main_page.dart';
import 'package:woodeco/app/result_page.dart';
import 'package:woodeco/app/sign_in_page.dart';
import 'package:woodeco/app/sign_up_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'woodeco',
      debugShowCheckedModeBanner: false,
      initialRoute: '/signin',
      routes: {
        '/main': (context) => const MainPage(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/result': (context) => const ResultPage(),
      }
    );
  }
}