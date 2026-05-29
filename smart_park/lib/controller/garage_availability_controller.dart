import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constant/constant_api.dart';
import 'auth_controller.dart';

class GarageAvailabilityController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxBool accessDenied = false.obs;
  RxBool hasGarage = false.obs;
  RxBool isActive = true.obs;

  RxString errorMessage = ''.obs;
  RxInt capacity = 0.obs;

  final formKey = GlobalKey<FormState>();
  final availableSpotsController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getGarageAvailability();
  }

  Future<void> getGarageAvailability() async {
    isLoading.value = true;
    accessDenied.value = false;
    hasGarage.value = false;
    errorMessage.value = '';

    try {
      final token = await authController.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/garage/my'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 403) {
        accessDenied.value = true;
        errorMessage.value =
            data['message'] ?? 'Only garage owners can access this page';
      } else if (response.statusCode == 200) {
        final garage = data['garage'];

        if (garage == null) {
          hasGarage.value = false;
          errorMessage.value = 'Garage information not found';
        } else {
          hasGarage.value = true;
          capacity.value = int.tryParse(garage['capacity'].toString()) ?? 0;
          availableSpotsController.text =
              garage['available_spots']?.toString() ?? '0';
          isActive.value =
              garage['is_active'] == true || garage['is_active'] == 1;
        }
      } else {
        errorMessage.value = data['message'] ?? 'Failed to load garage data';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAvailability() async {
    if (!formKey.currentState!.validate()) return;

    final enteredSpots =
        int.tryParse(availableSpotsController.text.trim()) ?? 0;

    if (enteredSpots > capacity.value) {
      Get.snackbar(
        'Error'.tr,
        '${'Available spots cannot be greater than capacity'.tr} (${capacity.value})',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    isSaving.value = true;

    try {
      final token = await authController.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/garage/update-availability'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'available_spots': availableSpotsController.text.trim(),
          'is_active': isActive.value ? '1' : '0',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final garage = data['garage'];
        availableSpotsController.text =
            garage['available_spots']?.toString() ?? '0';
        isActive.value = garage['is_active'] == true || garage['is_active'] == 1;

        Get.snackbar(
          'Success'.tr,
          data['message'] ?? 'Garage availability updated successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      } else {
        Get.snackbar(
          'Error'.tr,
          data['message'] ?? 'Failed to update garage availability'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Something went wrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    availableSpotsController.dispose();
    super.onClose();
  }
}