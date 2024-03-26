import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hviktentra/home_page.dart';
import 'package:hviktentra/login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController _loginController =
      Get.put(LoginController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "HELSE VEST IKT",
                  style: TextStyle(
                      color: Color.fromRGBO(0, 48, 135, 1.0),
                      fontWeight: FontWeight.w600,
                      fontSize: 30),
                ),
                const SizedBox(height: 80.0),
                Obx(() => Text(_loginController.errorMessage.value)),
                Column(
                  children: [
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
                        child: _loginController.isBusy.value
                            ? const Column(
                                children: [
                                  Text(
                                    'Logger inn...',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const CircularProgressIndicator(),
                                ],
                              )
                            : const Text("Logg inn",
                                style: TextStyle(fontSize: 16)),
                        onPressed: () async {
                          await _loginController.login();
                          if (_loginController.isLoggedIn.value) {
                            Get.to(() => HomePage());
                          }
                        })
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
