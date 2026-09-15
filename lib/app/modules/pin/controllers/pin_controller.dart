import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PinController extends GetxController {
  final centerIdController = TextEditingController();
  final pinController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final generatedPin = "".obs;
  final successMessage = "".obs;

  // TODO: Change these to your actual API values
  static const String baseUrl = "https://your-api-url.com";
  static const String pinGenerateEndpoint = "/api/pin/generate";

  Future<void> generatePin() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    successMessage.value = "";
    generatedPin.value = "";

    try {
      final response = await http.post(
        Uri.parse("$baseUrl$pinGenerateEndpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "center_id": centerIdController.text.trim(),
          "pin": pinController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        generatedPin.value = data["generated_pin"] ?? "N/A";
        successMessage.value = "PIN generated successfully!";

        Get.snackbar(
          "Success",
          "PIN generated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        );
      } else {
        _showError("Failed to generate PIN. Please try again.");
      }
    } catch (e) {
      _showError("Connection failed. Please check your internet.");
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }

  @override
  void onClose() {
    centerIdController.dispose();
    pinController.dispose();
    super.onClose();
  }
}
