import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constant/constant_api.dart';
import '../models/reservation_model.dart';
import 'auth_controller.dart';

class ReservationController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxBool isLoading    = false.obs;
  RxBool isSubmitting = false.obs;
  RxBool isCancelling = false.obs;

  RxList<ReservationModel> allReservations      = <ReservationModel>[].obs;
  RxList<ReservationModel> upcomingReservations = <ReservationModel>[].obs;
  RxList<ReservationModel> previousReservations = <ReservationModel>[].obs;

  final TextEditingController reservationDateController =
      TextEditingController();
  final TextEditingController startTimeController     = TextEditingController();
  final TextEditingController endTimeController       = TextEditingController();
  final TextEditingController numberOfSpotsController =
      TextEditingController(text: '1');
  final TextEditingController cancelReasonController  = TextEditingController();

  Future<Map<String, String>> _headers() async {
    final token = await authController.getToken();
    return {
      'Accept'       : 'application/json',
      'Content-Type' : 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<bool> createReservation({
    required int    garageId,
    required String paymentMethod,
    String? cardNumber,
    String? cardHolder,
    String? cardExpiry,
    String? cardCvv,
  }) async {
    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'garage_id'       : garageId,
        'reservation_date': reservationDateController.text.trim(),
        'start_time'      : startTimeController.text.trim(),
        'end_time'        : endTimeController.text.trim(),
        'number_of_spots' :
            int.tryParse(numberOfSpotsController.text.trim()) ?? 1,
        'payment_method'  : paymentMethod,
      };

      if (paymentMethod == 'card') {
        body['card_number'] = cardNumber?.trim() ?? '';
        body['card_holder'] = cardHolder?.trim() ?? '';
        body['card_expiry'] = cardExpiry?.trim() ?? '';
        body['card_cvv']    = cardCvv?.trim()    ?? '';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        reservationDateController.clear();
        startTimeController.clear();
        endTimeController.clear();
        numberOfSpotsController.text = '1';

        Get.snackbar(
          'success'.tr,
          data['message'] ?? 'reservation_created_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );

        fetchUpcomingReservations();
        fetchPreviousReservations();
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

  Future<void> fetchMyReservations() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/my'),
        headers: await _headers(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        allReservations.value = (data['reservations'] as List)
            .map((e) => ReservationModel.fromJson(e))
            .toList();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUpcomingReservations() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/upcoming'),
        headers: await _headers(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        upcomingReservations.value = (data['reservations'] as List)
            .map((e) => ReservationModel.fromJson(e))
            .toList();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPreviousReservations() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/previous'),
        headers: await _headers(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        previousReservations.value = (data['reservations'] as List)
            .map((e) => ReservationModel.fromJson(e))
            .toList();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> cancelReservation(int reservationId) async {
    isCancelling.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations/$reservationId/cancel'),
        headers: await _headers(),
        body: jsonEncode({'cancel_reason': cancelReasonController.text.trim()}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.snackbar(
          'success'.tr,
          data['message'] ?? 'reservation_cancelled_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        cancelReasonController.clear();
        await fetchUpcomingReservations();
        await fetchPreviousReservations();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCancelling.value = false;
    }
  }

  Future<void> checkInReservation(int reservationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations/$reservationId/check-in'),
        headers: await _headers(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.snackbar('success'.tr,
            data['message'] ?? 'checked_in_successfully'.tr,
            snackPosition: SnackPosition.BOTTOM);
        await fetchUpcomingReservations();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> checkOutReservation(int reservationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations/$reservationId/check-out'),
        headers: await _headers(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.snackbar('success'.tr,
            data['message'] ?? 'checked_out_successfully'.tr,
            snackPosition: SnackPosition.BOTTOM);
        await fetchUpcomingReservations();
        await fetchPreviousReservations();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickReservationDate(BuildContext context) async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context    : context,
      initialDate: now,
      firstDate  : now,
      lastDate   : DateTime(now.year + 2),
    );
    if (picked != null) {
      reservationDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> pickTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final picked = await showTimePicker(
      context    : context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
    }
  }


  @override
  void onInit() {
    fetchUpcomingReservations();
    fetchPreviousReservations();
    super.onInit();
  }

  @override
  void onClose() {
    reservationDateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    numberOfSpotsController.dispose();
    cancelReasonController.dispose();
    super.onClose();
  }
}
