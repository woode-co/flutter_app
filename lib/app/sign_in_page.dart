import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:woodeco/app/main_view_model.dart';
import 'package:woodeco/app/kakao_login.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final viewModel = MainViewModel(KakaoLogin());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, // Left alignment
            children: <Widget>[
              SizedBox(height: 100), // Top margin for logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '우데코',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 10), // Space between "우데코" and its description
                  Text(
                    '우리들의\n데이트 코스',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              RichText(
                text: TextSpan(
                  text: '당신을 생각하는\n',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontFamily: 'Roboto', // Assuming Roboto, change as needed
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '맞춤형 데이트 코스 추천',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 60),
              Center( // Centering SignIn Buttons
                child: Column(
                  children: <Widget>[
                    Image.network(viewModel.user?.kakaoAccount?.profile?.profileImageUrl ?? ''),
                    Text('${viewModel.isLogined}'),
                    ElevatedButton(
                      onPressed: () async {
                        await viewModel.login();
                        setState(() {});
                      },
                      child: Text('Kakao Login')
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await viewModel.logout();
                        setState(() {});
                      },
                      child: Text('Kakao Logout')
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
