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
      routes: {
        '/main': (context) {
          final routeSettings = ModalRoute.of(context)!.settings;
          final args = routeSettings.arguments as Map<String, dynamic>? ?? {};

          // isMale 인자를 bool로 받고, 기본값은 true
          final bool userSex = args['userSex'] as bool? ?? true;

          // isSelected 인자를 List<bool>로 받고, 기본값은 길이 7의 모두 true인 리스트
          final List<bool> userTastes = args['userTastes'] as List<bool>? ?? [true, true, true, true, true, true, true];

          return MainPage(
            userSex: userSex, // 남자인지 여부
            userTastes: userTastes, // 취향 선택지 중에서 전자를 선택했는지 여부
          );
        },
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/result': (context) => const ResultPage(),
      }
    );
  }
}