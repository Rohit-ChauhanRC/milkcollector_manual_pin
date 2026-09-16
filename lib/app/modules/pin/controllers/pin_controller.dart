import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/api_service.dart';

class PinController extends GetxController {
  final centerIdController = TextEditingController();
  final pinController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final generatedPin = "".obs;
  final successMessage = "".obs;

  final centerName = "".obs;
  final centerNameError = "".obs;
  final centerNameLoading = false.obs;

  Timer? _debounce;
  int _centerLookupRequestId = 0;

  void onCenterIdChanged(String value) {
    _debounce?.cancel();
    successMessage.value = "";
    generatedPin.value = "";

    if (value.trim().isEmpty) {
      centerName.value = "";
      centerNameError.value = "";
      centerNameLoading.value = false;
      return;
    }

    if (int.tryParse(value.trim()) == null) {
      centerName.value = "";
      centerNameError.value = "Center ID must be a number.";
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchCenterName();
    });
  }

  Future<void> fetchCenterName() async {
    final centerId = centerIdController.text.trim();
    if (centerId.isEmpty) return;

    final requestId = ++_centerLookupRequestId;
    centerNameLoading.value = true;
    centerName.value = "";
    centerNameError.value = "";

    try {
      final result = await ApiService.instance.getCenterName(
        centerId: centerId,
      );
      if (requestId != _centerLookupRequestId) return;

      if (result.success) {
        centerName.value = result.data?.trim() ?? "";
        if (centerName.value.isEmpty) {
          centerNameError.value = "Center name not available.";
        }
      } else {
        centerNameError.value = result.message;
      }
    } on ApiException catch (e) {
      if (requestId != _centerLookupRequestId) return;
      centerNameError.value = e.message;
    } catch (e) {
      if (requestId != _centerLookupRequestId) return;
      centerNameError.value = "Unable to fetch center name. Please try again.";
    } finally {
      if (requestId == _centerLookupRequestId) {
        centerNameLoading.value = false;
      }
    }
  }

  Future<void> generatePin() async {
    if (!formKey.currentState!.validate()) return;

    final centerId = centerIdController.text.trim();
    final pin = pinController.text.trim();

    if (int.tryParse(centerId) == null) {
      _showError("Center ID must be a valid number.");
      return;
    }

    isLoading.value = true;
    successMessage.value = "";
    generatedPin.value = "";

    try {
      final result = await ApiService.instance.insertPin(
        centerId: centerId,
        pin: pin,
      );

      if (result.success) {
        generatedPin.value = result.data ?? pin;
        successMessage.value = result.message.trim().isEmpty
            ? "PIN generated successfully!: ${result.data ?? pin}"
            : "${result.message.trim()}: ${result.data ?? pin}";

        Get.snackbar(
          "Success",
          successMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        );
      } else {
        _showError(result.message);
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Something went wrong. Please try again.");
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
    _debounce?.cancel();
    centerIdController.dispose();
    pinController.dispose();
    super.onClose();
  }
}
