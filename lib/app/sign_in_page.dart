import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:woodeco/app/main_view_model.dart';
import 'package:woodeco/app/kakao_login.dart';
import 'package:flutter_svg/svg.dart';
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
              SizedBox(height: 200), // Top margin for logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '우데코',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 10), // Space between "우데코" and its description
                  Text(
                    '우리들의\n데이트 코스',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 100),
              RichText(
                text: TextSpan(
                  text: '당신을 생각하는\n',
                  style: TextStyle(
                    fontSize: 20,
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
              SizedBox(height: 100),
              Center( // Centering SignIn Buttons
                child: Column(
                  children: <Widget>[
                    Text('카카오 로그인 여부 : ${viewModel.isLogined}'),
                    SizedBox(height:30),
                    InkWell(
                      onTap: () async {
                        await viewModel.login();
                        setState(() {});
                        if (viewModel.isLogined){
                          Navigator.of(context).pushNamed('/signup');
                        }
                      },
                      child: SvgPicture.asset(
                        'images/kakao_login.svg',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.contain
                      ),
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
