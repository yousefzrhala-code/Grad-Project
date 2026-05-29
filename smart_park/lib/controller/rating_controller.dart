import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/constant_api.dart';
import 'auth_controller.dart';

class RatingController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxInt stars = 5.obs;
  final TextEditingController commentController = TextEditingController();
  RxBool isSubmitting = false.obs;

  Future<Map<String, String>> _headers() async {
    final token = await authController.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<bool> submitRating({
    required int garageId,
    required int reservationId,
  }) async {
    isSubmitting.value = true;
    try {
      final url = Uri.parse('$baseUrl/ratings');
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          'garage_id': garageId,
          'reservation_id': reservationId,
          'stars': stars.value,
          'comment': commentController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        Get.snackbar(
          'success'.tr,
          data['message'] ?? 'rating_submitted_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        commentController.clear();
        stars.value = 5;
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
    commentController.dispose();
    super.onClose();
  }
}
