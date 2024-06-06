import 'package:woodeco/app/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:woodeco/app/token_manager.dart' as woodeco_token_manager; // 별칭 추가
import 'package:http/http.dart' as http;
import 'dart:convert';

class KakaoLogin implements SocialLogin {
  @override
  Future<bool> login() async {
    try {
      String? accessToken = woodeco_token_manager.TokenManager.instance.accessToken; // 별칭 사용
      if (accessToken != null) {
        bool tokenValid = await _validateToken(accessToken);
        if (tokenValid) {
          print("Token is valid");
          return true;
        }
      }

      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;
      if (isInstalled) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          print("Logged in with KakaoTalk");
        } catch (e) {
          print("Failed to login with KakaoTalk: $e");
          return false;
        }
      } else {
        try {
          token = await UserApi.instance.loginWithKakaoAccount();
          print("Logged in with KakaoAccount");
        } catch (e) {
          print("Failed to login with KakaoAccount: $e");
          return false;
        }
      }
      await _saveToken(token);
      print("Token saved successfully");
      return true;
    } catch (e) {
      print("Login failed: $e");
      return false;
    }
  }

  Future<void> _saveToken(OAuthToken token) async {
    await woodeco_token_manager.TokenManager.instance.saveToken(token.accessToken, token.refreshToken!); // 별칭 사용
    print("AccessToken: ${token.accessToken}, RefreshToken: ${token.refreshToken}");
  }

  Future<bool> _validateToken(String accessToken) async {
    try {
      AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
      print("Token expires in: ${tokenInfo.expiresIn}");
      return tokenInfo.expiresIn > 0;
    } catch (e) {
      print("Token validation failed: $e");
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await UserApi.instance.unlink();
      await woodeco_token_manager.TokenManager.instance.clearToken(); // 별칭 사용
      print("Logged out successfully");
      return true;
    } catch (error) {
      print("Logout failed: $error");
      return false;
    }
  }

  Future<bool> isTokenValid() async {
    String? accessToken = woodeco_token_manager.TokenManager.instance.accessToken; // 별칭 사용
    if (accessToken != null) {
      return await _validateToken(accessToken);
    }
    return false;
  }

  Future<bool> verifyTokenWithServer(String token) async {
    final response = await http.get(Uri.parse('http://49.247.34.221:8000/signin/$token'));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result is Map<String, dynamic>) {
        return result['exists'] as bool;
      } else {
        print("Unexpected response format: $result");
        return false;
      }
    } else {
      print("Failed to verify token with server: ${response.statusCode}");
      return false;
    }
  }
}
