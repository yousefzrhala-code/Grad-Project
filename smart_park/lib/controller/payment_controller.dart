import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/constant_api.dart';
import 'auth_controller.dart';

class PaymentService {
  static const String demoCardNumber = '4242 4242 4242 4242';
  static const String demoCardExpiry = '12/30';
  static const String demoCardCvv = '123';
  static const String demoCardHolder = 'SMART PARK';
}

class PaymentController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxString paymentMethod = 'card'.obs;

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCvvController = TextEditingController();

  RxBool isProcessing = false.obs;
  Rxn<Map<String, dynamic>> lastPayment = Rxn<Map<String, dynamic>>();

  Future<Map<String, String>> _headers() async {
    final token = await authController.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  void useDemoCard() {
    paymentMethod.value = 'card';
    cardNumberController.text = PaymentService.demoCardNumber;
    cardHolderController.text = PaymentService.demoCardHolder;
    cardExpiryController.text = PaymentService.demoCardExpiry;
    cardCvvController.text = PaymentService.demoCardCvv;
  }

  /// Returns true on a successful payment (or successful cash reservation).
  Future<bool> pay({
    required double amount,
    int? reservationId,
  }) async {
    final method = paymentMethod.value;

    if (method == 'card' &&
        (cardNumberController.text.trim().isEmpty ||
            cardHolderController.text.trim().isEmpty ||
            cardExpiryController.text.trim().isEmpty ||
            cardCvvController.text.trim().isEmpty)) {
      Get.snackbar('error'.tr, 'Required'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    isProcessing.value = true;
    try {
      final body = <String, dynamic>{
        'reservation_id': reservationId,
        'amount': amount,
        'payment_method': method,
      };
      if (method == 'card') {
        body.addAll({
          'card_number': cardNumberController.text.trim(),
          'card_holder': cardHolderController.text.trim(),
          'card_expiry': cardExpiryController.text.trim(),
          'card_cvv': cardCvvController.text.trim(),
        });
      }

      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      lastPayment.value = data['payment'];

      if (response.statusCode == 201) {
        Get.snackbar(
          'success'.tr,
          data['message'] ??
              (method == 'cash'
                  ? 'cash_payment_reserved'.tr
                  : 'payment_successful'.tr),
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }

      Get.snackbar(
        'error'.tr,
        data['message'] ?? 'payment_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    cardNumberController.dispose();
    cardHolderController.dispose();
    cardExpiryController.dispose();
    cardCvvController.dispose();
    super.onClose();
  }
}
