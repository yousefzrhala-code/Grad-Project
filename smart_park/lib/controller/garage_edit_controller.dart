import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constant/constant_api.dart';
import 'auth_controller.dart';

class GarageEditController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxBool accessDenied = false.obs;
  RxString errorMessage = ''.obs;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final pricePerHourController = TextEditingController();
  final capacityController = TextEditingController();
  final availableSpotsController = TextEditingController();
  final openTimeController = TextEditingController();
  final closeTimeController = TextEditingController();
  final descriptionController = TextEditingController();

  RxBool isActive = true.obs;
  RxBool hasGarage = false.obs;

  @override
  void onInit() {
    super.onInit();
    getGarageData();
  }

  Future<void> getGarageData() async {
    isLoading.value = true;
    accessDenied.value = false;
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

          nameController.text = garage['name']?.toString() ?? '';
          cityController.text = garage['city']?.toString() ?? '';
          addressController.text = garage['address']?.toString() ?? '';
          pricePerHourController.text =
              garage['price_per_hour']?.toString() ?? '';
          capacityController.text = garage['capacity']?.toString() ?? '';
          availableSpotsController.text =
              garage['available_spots']?.toString() ?? '';
          openTimeController.text = garage['open_time']?.toString() ?? '';
          closeTimeController.text = garage['close_time']?.toString() ?? '';
          descriptionController.text =
              garage['description']?.toString() ?? '';
          isActive.value = garage['is_active'] == true || garage['is_active'] == 1;
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

  Future<void> updateGarage() async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;

    try {
      final token = await authController.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/garage/update'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'name': nameController.text.trim(),
          'city': cityController.text.trim(),
          'address': addressController.text.trim(),
          'price_per_hour': pricePerHourController.text.trim(),
          'capacity': capacityController.text.trim(),
          'open_time': openTimeController.text.trim(),
          'close_time': closeTimeController.text.trim(),
          'description': descriptionController.text.trim(),
          'is_active': isActive.value ? '1' : '0',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final updatedGarage = data['garage'];

        availableSpotsController.text =
            updatedGarage['available_spots']?.toString() ?? '';

        Get.snackbar(
          'Success'.tr,
          data['message'] ?? 'Garage information updated successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      } else {
        Get.snackbar(
          'Error'.tr,
          data['message'] ?? 'Failed to update garage information'.tr,
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
    nameController.dispose();
    cityController.dispose();
    addressController.dispose();
    pricePerHourController.dispose();
    capacityController.dispose();
    availableSpotsController.dispose();
    openTimeController.dispose();
    closeTimeController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}