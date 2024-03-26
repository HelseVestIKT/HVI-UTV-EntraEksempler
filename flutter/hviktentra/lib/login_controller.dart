import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hviktentra/environment.dart';
import 'package:hviktentra/login_page.dart';

class LoginController extends GetxController {

  RxBool isLoggedIn = false.obs;
  RxBool isBusy = false.obs;
  RxString errorMessage = "".obs;

  late String userName;
  late String name;

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

    final String _secureStorageRefreshTokenKey = 'refresh_token';
  final String _accessTokenExpirationTimeUtcStringKey =
      'access_token_expiration';
  final String _jwtTokenStorageKey = 'jwt_token';
  final String _idTokenStorageKey = 'id_token';

  final Duration tokenExpirationCheckTime = const Duration(minutes: 30);

  Future<bool> getRefreshTokenOrLogin() async {

    isBusy(true);

    try {
      final String? storedRefreshToken =
        await _secureStorage.read(key: _secureStorageRefreshTokenKey);
    
      if (!isLoggedIn.value || storedRefreshToken == null) {
        //User is not logged in or refresh token was not found. User will have to log in
        bool loginResult = await _doLogin();
        _setLoggedinStatusAndEndBusy(loginResult);
        return isLoggedIn.value;
      }

      bool accessTokenHasOrWillExpire = await _accessTokenExpiresWithinDefinedTime();

      if (!accessTokenHasOrWillExpire) {
        _setLoggedinStatusAndEndBusy(true);
        return true;
      }

      //Current access token will expire within the next 30 minutes - refresh
      bool refreshed = await _refreshToken(storedRefreshToken);

      _setLoggedinStatusAndEndBusy(refreshed);
      return refreshed;
    } catch (e, s) {
      isBusy(false);
      return false;
    }
  }

  Future<bool> _accessTokenExpiresWithinDefinedTime() async {
    final accessTokenExpirationString =
        await _secureStorage.read(key: _accessTokenExpirationTimeUtcStringKey);
    if (accessTokenExpirationString == null) {
      return false;
    }
    DateTime accessTokenExpirationDateTime =
        DateTime.parse(accessTokenExpirationString);
    DateTime accessTokenMinusDefinedTime =
        accessTokenExpirationDateTime.subtract(tokenExpirationCheckTime);

    DateTime nowUtc = DateTime.now().toUtc();
    //accessTokenMinusDefinedTime.compareTo(nowUtc) < 0 - returns -1 if nowUtc is greater than accessTokenMinusDefinedTime
    //- meaning the current time has passed accessTokenMinusDefinedTime - it will expire within the next x minutes
    return accessTokenMinusDefinedTime.compareTo(nowUtc) < 0;
  }

  Future<bool> _doLogin() async {
    try {
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          Environment.CLIENT_ID, Environment.REDIRECT_URI,
          serviceConfiguration: const AuthorizationServiceConfiguration(
              authorizationEndpoint: Environment.AUTHORIZATION_ENDPOINT,
              tokenEndpoint: Environment.TOKEN_ENDPOINT),
          scopes: Environment.scopes,
          preferEphemeralSession: true,
          promptValues: ['login']
        ),
      );
      return await _handleTokenResponse(result);
    } catch (e, s) {
      
      errorMessage.value = "Det oppstod en feil under innlogging";
      return false;
    }
  }

  Future<bool> _refreshToken(String? storedRefreshToken) async {
    try {
      final response = await _appAuth.token((TokenRequest(
          Environment.CLIENT_ID, Environment.REDIRECT_URI,
          serviceConfiguration: const AuthorizationServiceConfiguration(
              authorizationEndpoint: Environment.AUTHORIZATION_ENDPOINT,
              tokenEndpoint: Environment.TOKEN_ENDPOINT),
          scopes: Environment.scopes,
          refreshToken: storedRefreshToken)));

      if (response?.idToken != null && response?.refreshToken != null) {
        await _handleTokenResponse(response);
      }

      return true;
    } catch (e, s) {
      
      logoutAction();
      return false;
    }
  }

  Map<String, dynamic> _parseIdToken(String? idToken) {
    final parts = idToken?.split(r'.');
    assert(parts?.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts![1]))));
  }

  void _setLoggedinStatusAndEndBusy(bool status) {
    isBusy(false);
    isLoggedIn(status);
  }

  Future<String?> getJwtToken() async {
    return _secureStorage.read(key: _jwtTokenStorageKey);
  }


  Future<void> login() async {

    errorMessage = ''.obs;

    await resetStoredData();

    await getRefreshTokenOrLogin();
  }

  Future<void> logoutAction() async {
    try {
      
      //Note: If Environment.POST_LOGOUT_REDIRECT has not been set, the browser window will remain open after logout and the app has to be reopened.

      EndSessionRequest endSessionRequest = EndSessionRequest(
          idTokenHint: await _secureStorage.read(key: _idTokenStorageKey),
          postLogoutRedirectUrl: Environment.POST_LOGOUT_REDIRECT,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: Environment.AUTHORIZATION_ENDPOINT,
            tokenEndpoint: Environment.TOKEN_ENDPOINT,
            endSessionEndpoint: Environment.END_SESSION_ENDPOINT,
          ));

      await _appAuth.endSession(endSessionRequest);

      resetStoredData();

      Get.off(() => LoginPage());
    } catch (e, s) {
      isBusy(false);
      
      errorMessage.value = 'Det oppstod en feil under utlogging';
    }
  }

  Future<bool> _handleTokenResponse(TokenResponse? result) async {
    if (result?.idToken != null) {
      Map<String, dynamic> idToken = _parseIdToken(result?.idToken);

      final DateTime? accessTokenExpration =
          result?.accessTokenExpirationDateTime!.toUtc();

      await _secureStorage.write(
          key: _secureStorageRefreshTokenKey, value: result!.refreshToken);
      await _secureStorage.write(
          key: _accessTokenExpirationTimeUtcStringKey,
          value: accessTokenExpration!.toIso8601String());
      await _secureStorage.write(
          key: _jwtTokenStorageKey, value: result.accessToken);
      await _secureStorage.write(
          key: _idTokenStorageKey, value: result.idToken);

      userName = idToken['preferred_username'];
      name = idToken['name'];

      idToken = <String, dynamic>{};

      return true;
    } else {
      return false;
    }
  }

  Future<void> resetStoredData() async {
    
    isLoggedIn.value = false;
    await _secureStorage.delete(key: _secureStorageRefreshTokenKey);
    await _secureStorage.delete(key: _accessTokenExpirationTimeUtcStringKey);
    await _secureStorage.delete(key: _jwtTokenStorageKey);
    await _secureStorage.delete(key: _idTokenStorageKey);

    userName = "";
    name = "";

    _setLoggedinStatusAndEndBusy(false);
  }

}