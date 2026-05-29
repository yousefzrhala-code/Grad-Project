import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/constant_api.dart';
import 'auth_controller.dart';

class NotificationsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxBool isLoading = false.obs;
  RxInt unreadCount = 0.obs;
  RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;

  Future<Map<String, String>> _headers() async {
    final token = await authController.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final url = Uri.parse('$baseUrl/notifications');
      final response = await http.get(url, headers: await _headers());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        notifications.value =
            List<Map<String, dynamic>>.from(data['notifications'] ?? []);
        unreadCount.value =
            int.tryParse((data['unread_count'] ?? 0).toString()) ?? 0;
      } else {
        Get.snackbar(
          'error'.tr,
          data['message'] ?? 'something_went_wrong'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final url = Uri.parse('$baseUrl/notifications/$id/read');
      final response = await http.post(url, headers: await _headers());
      if (response.statusCode == 200) {
        await fetchNotifications();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final url = Uri.parse('$baseUrl/notifications/read-all');
      final response = await http.post(url, headers: await _headers());
      if (response.statusCode == 200) {
        await fetchNotifications();
      }
    } catch (_) {}
  }

  Future<void> saveDeviceToken(String fcmToken) async {
    try {
      final url = Uri.parse('$baseUrl/user/device-token');
      await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({'fcm_token': fcmToken}),
      );
    } catch (_) {}
  }
}
