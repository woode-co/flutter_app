import 'package:woodeco/app/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:woodeco/app/token_manager.dart' as woodeco_token_manager; // 별칭 추가
import 'package:woodeco/app/kakao_login.dart'; // KakaoLogin import 추가

class MainViewModel {
  final SocialLogin _socialLogin;
  bool isLogined = false;
  User? user;

  MainViewModel(this._socialLogin);

  Future<void> checkLoginStatus() async {
    isLogined = await (_socialLogin as KakaoLogin).isTokenValid();
    if (isLogined) {
      user = await UserApi.instance.me();
    }
  }

  Future<void> login() async {
    isLogined = await _socialLogin.login();
    if (isLogined) {
      user = await UserApi.instance.me(); // 현재 로그인된 유저 정보 가지고 옴.
    }
  }

  Future<void> logout() async {
    await _socialLogin.logout();
    isLogined = false;
    user = null;
  }

  Future<bool> verifyTokenWithServer() async {
    String? token = woodeco_token_manager.TokenManager.instance.accessToken;
    if (token != null && _socialLogin is KakaoLogin) {
      return await (_socialLogin as KakaoLogin).verifyTokenWithServer(token);
    }
    return false;
  }
}
