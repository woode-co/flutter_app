import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final bool userSex;
  final List<bool> userTastes;
  const MainPage({
    Key? key,
    required this.userSex,
    required this.userTastes,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('main page, Gender: ${widget.userSex ? "Male" : "Female"}'),
    );
  }
}