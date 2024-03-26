import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:hviktentra/custom_interceptors.dart';
import 'package:hviktentra/environment.dart';

class DataService extends GetConnect implements GetxService {
  late Dio dio;

  @override
  void onInit() async {
    BaseOptions options = BaseOptions(
      //Examples of useful settings:
      //receiveTimeout: const Duration(milliseconds: Environment.RECEIVE_TIMEOUT_MS),
      //connectTimeout: const Duration(milliseconds: Environment.CONNECT_TIMEOUT_MS),
    );

    dio = Dio(options);

    ///May be required, Dart dies not allow self signed certificates
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          return ([
            'localhost',
              ].contains(host));
        };
        return client;
      }
    );

    dio.interceptors.add(CustomInterceptors());

    super.onInit();
  }

  Future<void> exampleApiCall() async {


    try {
      final response = await dio.post(
        '${Environment.API_BASE_URL}/exampleEndpoint',
        data: {
          "id": 123
        },
        
      );
      
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Future.error('Timeout');
      }
      if (e.response?.statusCode == 404) {
        return null;
      } else {
        return Future.error('An error occurred');
      }
    }
  }
}