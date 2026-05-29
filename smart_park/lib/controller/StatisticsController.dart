import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/constant_api.dart';
import 'auth_controller.dart';

class StatisticsController extends GetxController {
  final AuthController authController = Get.find();

  RxBool isLoading = false.obs;

  RxInt total = 0.obs;
  RxInt pending = 0.obs;
  RxInt accepted = 0.obs;
  RxInt rejected = 0.obs;
  RxInt completed = 0.obs;
  RxDouble revenue = 0.0.obs;
  RxInt cancelled = 0.obs;
  Future<Map<String, String>> _headers() async {
    final token = await authController.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<void> fetchStatistics() async {
    isLoading.value = true;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/garage-owner/statistics'),
        headers: await _headers(),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        total.value = data['total_reservations'];
        pending.value = data['pending_reservations'];
        accepted.value = data['accepted_reservations'];
        rejected.value = data['rejected_reservations'];
        cancelled.value = data['cancelled_reservations'] ?? data['cancelled'] ?? 0;
        completed.value = data['completed_reservations'] ?? 0;

        revenue.value = double.tryParse(data['total_revenue'].toString()) ?? 0.0;
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'something_went_wrong'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    fetchStatistics();
    super.onInit();
  }
}