import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  //
  static const String baseUrl = "https://your-api-url.com";
  static const String loginEndpoint = "/api/login";

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    Get.offAllNamed(Routes.PIN);

    // try {
    //   final response = await http.post(
    //     Uri.parse("$baseUrl$loginEndpoint"),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode({
    //       "username": usernameController.text.trim(),
    //       "password": passwordController.text.trim(),
    //     }),
    //   );

    //   if (response.statusCode == 200) {
    //     //
    //     Get.offAllNamed(Routes.PIN);

    //     Get.snackbar(
    //       "Success",
    //       "Login successful!",
    //       snackPosition: SnackPosition.BOTTOM,
    //       backgroundColor: Colors.green,
    //       colorText: Colors.white,
    //       margin: const EdgeInsets.all(12),
    //       borderRadius: 8,
    //     );
    //   } else {
    //     _showError("Invalid username or password");
    //   }
    // } catch (e) {
    //   _showError("Connection failed. Please check your internet.");
    // } finally {
    //   isLoading.value = false;
    // }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
