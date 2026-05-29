import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constant/constant_api.dart';
import 'auth_controller.dart';

class GarageController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool hasGarage = false.obs;
  RxMap<String, dynamic> garageData = <String, dynamic>{}.obs;
  RxString errorMessage = ''.obs;

  final AuthController authController = Get.find<AuthController>();

  Future<Map<String, dynamic>> getMyGarage() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await authController.getToken();
      final url = Uri.parse('$baseUrl/garage/my');

      final res = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        hasGarage.value = data['has_garage'] == true;
        garageData.value = data['garage'] ?? {};
        isLoading.value = false;

        return {
          'status': true,
          'statusCode': res.statusCode,
          'has_garage': hasGarage.value,
          'garage': garageData,
        };
      } else {
        errorMessage.value = data['message']?.toString() ?? 'Failed to load garage';
        isLoading.value = false;

        return {
          'status': false,
          'statusCode': res.statusCode,
          'message': errorMessage.value,
        };
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      isLoading.value = false;

      return {
        'status': false,
        'statusCode': 500,
        'message': errorMessage.value,
      };
    }
  }

  Future<Map<String, dynamic>> addGarage({
    required String name,
    required String city,
    required String address,
    required String pricePerHour,
    required String capacity,
    String? openTime,
    String? closeTime,
    String? description,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await authController.getToken();
      final url = Uri.parse('$baseUrl/garage/store');

      final Map<String, String> body = {
        'name': name,
        'city': city,
        'address': address,
        'price_per_hour': pricePerHour,
        'capacity': capacity,
      };

      if (openTime != null && openTime.isNotEmpty) {
        body['open_time'] = openTime;
      }

      if (closeTime != null && closeTime.isNotEmpty) {
        body['close_time'] = closeTime;
      }

      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      final res = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 201 || res.statusCode == 200) {
        hasGarage.value = true;
        garageData.value = data['garage'] ?? {};
        isLoading.value = false;

        return {
          'status': true,
          'statusCode': res.statusCode,
          'message': data['message']?.toString() ?? 'Garage added successfully',
          'garage': garageData,
        };
      } else {
        errorMessage.value = data['message']?.toString() ?? 'Failed to add garage';
        isLoading.value = false;

        return {
          'status': false,
          'statusCode': res.statusCode,
          'message': errorMessage.value,
        };
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong';
      isLoading.value = false;

      return {
        'status': false,
        'statusCode': 500,
        'message': errorMessage.value,
      };
    }
  }
}