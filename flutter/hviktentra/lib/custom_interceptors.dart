import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hviktentra/login_controller.dart';

class CustomInterceptors extends Interceptor {
  LoginController _loginController = Get.put(LoginController());

  final nonAuthorizedPaths = <String>['/language/text'];

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {

    if (!nonAuthorizedPaths.contains(options.path)) {
      String? jwtToken = await _loginController.getJwtToken();
      options.headers['Authorization'] = 'Bearer $jwtToken';
    }

    return super.onRequest(options, handler);
  }
}