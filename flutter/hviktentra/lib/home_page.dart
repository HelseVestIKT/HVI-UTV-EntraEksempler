import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hviktentra/login_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final LoginController _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Logget inn'),
            const SizedBox(height: 20),
            Obx(() => Text('Brukernavn: ${_loginController.userName}')),
            Obx(() => Text('Navn: ${_loginController.name}')),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'PublicSans',
                              fontWeight: FontWeight.w500),
                          minimumSize: const Size.fromHeight(45),
                          backgroundColor: Color.fromRGBO(230, 233, 244, 1.0),
                          foregroundColor: Color.fromRGBO(0, 0, 0, 1),
                        ),
              onPressed: () async {
                await _loginController.logoutAction();
              },
              child: const Text('Logg ut'),
            ),
          ],
        ),
      ),
    );
  }
}