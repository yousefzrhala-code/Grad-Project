import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/constant_api.dart';
import 'auth_controller.dart';

class OwnerReservationsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> reservations = <Map<String, dynamic>>[].obs;

  Future<Map<String, String>> _headers() async {
    final token = await authController.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> fetchReservations() async {
    isLoading.value = true;

    try {
      final url = Uri.parse('$baseUrl/garage-owner/reservations');
      final response = await http.get(url, headers: await _headers());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        reservations.value = List<Map<String, dynamic>>.from(data['reservations']);
      } else {
        Get.snackbar('error'.tr, data['message']);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> respond(int id, String status, String? note) async {
    try {
      final url = Uri.parse('$baseUrl/reservations/$id/respond');

      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          'status': status,
          'owner_response_note': note,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar('success'.tr, data['message']);
        fetchReservations();
      } else {
        Get.snackbar('error'.tr, data['message']);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  Future<void> complete(int id) async {
    try {
      final url = Uri.parse('$baseUrl/reservations/$id/check-out');

      final response = await http.post(url, headers: await _headers());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar('success'.tr,
            data['message'] ?? 'reservation_completed_successfully'.tr);
        fetchReservations();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  Future<void> checkIn(int id) async {
    try {
      final url = Uri.parse('$baseUrl/reservations/$id/check-in');
      final response = await http.post(url, headers: await _headers());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar('success'.tr,
            data['message'] ?? 'checked_in_successfully'.tr);
        fetchReservations();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  Future<void> checkOut(int id) async {
    try {
      final url = Uri.parse('$baseUrl/reservations/$id/check-out');
      final response = await http.post(url, headers: await _headers());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar('success'.tr,
            data['message'] ?? 'checked_out_successfully'.tr);
        fetchReservations();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  Future<void> cancelByOwner(int id, {String? reason}) async {
    try {
      final url = Uri.parse('$baseUrl/reservations/$id/cancel-by-owner');
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({'cancel_reason': reason ?? ''}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar('success'.tr,
            data['message'] ?? 'reservation_cancelled_successfully'.tr);
        fetchReservations();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  @override
  void onInit() {
    fetchReservations();
    super.onInit();
  }
}