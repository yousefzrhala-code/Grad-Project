import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/constant_api.dart';
import 'auth_controller.dart';

class ReportController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  RxBool isSubmitting = false.obs;

  Future<Map<String, String>> _headers() async {
    final token = await authController.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<bool> submitReport(int garageId) async {
    if (subjectController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      Get.snackbar('error'.tr, 'Required'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    isSubmitting.value = true;
    try {
      final url = Uri.parse('$baseUrl/reports');
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          'garage_id': garageId,
          'subject': subjectController.text.trim(),
          'message': messageController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        Get.snackbar(
          'success'.tr,
          data['message'] ?? 'report_submitted_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        subjectController.clear();
        messageController.clear();
        return true;
      }

      Get.snackbar(
        'error'.tr,
        data['message'] ?? 'something_went_wrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
