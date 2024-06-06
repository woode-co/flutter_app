import 'package:flutter/material.dart';
import 'package:woodeco/app/main_page.dart';
import 'package:woodeco/app/result_page.dart';
import 'package:woodeco/app/sign_in_page.dart';
import 'package:woodeco/app/sign_up_page.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  KakaoSdk.init(nativeAppKey: '816b6c407a299db3d999c961bfd82dc3');
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
      onGenerateRoute: (settings) {
        if (settings.name == '/result') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return ResultPage(result: args);
            },
          );
        }
        // Handle other routes here
        switch (settings.name) {
          case '/main':
            return MaterialPageRoute(builder: (context) => const MainPage());
          case '/signin':
            return MaterialPageRoute(builder: (context) => const SignInPage());
          case '/signup':
            return MaterialPageRoute(builder: (context) => const SignUpPage());
          default:
            return null;
        }
      },
    );
  }
}