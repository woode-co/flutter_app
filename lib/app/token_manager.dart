class TokenManager {
  TokenManager._privateConstructor();

  static final TokenManager _instance = TokenManager._privateConstructor();
  static TokenManager get instance => _instance;

  String? _accessToken;
  String? _refreshToken;

  Future<void> saveToken(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Future<void> clearToken() async {
    _accessToken = null;
    _refreshToken = null;
  }
}
