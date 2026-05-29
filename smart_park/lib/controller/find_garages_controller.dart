import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/constant_api.dart';
import '../constant/jordan_cities.dart';
import 'auth_controller.dart';

class FindGaragesController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxBool isLoading = false.obs;

  RxList<Map<String, dynamic>> garages = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredGarages = <Map<String, dynamic>>[].obs;
  RxList<String> cities = jordanCities.obs;
  RxString selectedCity = 'all'.obs;

  RxList<int> favoriteGarageIds = <int>[].obs;
  RxList<Map<String, dynamic>> favoriteGarages = <Map<String, dynamic>>[].obs;

  bool isFavorite(int garageId) {
    return favoriteGarageIds.contains(garageId);
  }

  final TextEditingController searchController = TextEditingController();

  Future<Map<String, String>> _headers() async {
    final token = await authController.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> fetchGarages() async {
    isLoading.value = true;

    try {
      final params = <String, String>{};
      if (selectedCity.value.isNotEmpty && selectedCity.value != 'all') {
        params['city'] = selectedCity.value;
      }
      final search = searchController.text.trim();
      if (search.isNotEmpty) {
        params['search'] = search;
      }

      final url = Uri.parse('$baseUrl/garages').replace(queryParameters: params);
      final response = await http.get(url, headers: await _headers());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> loadedGarages = [];

        if (data is List) {
          loadedGarages = List<Map<String, dynamic>>.from(data);
        } else if (data['garages'] != null) {
          loadedGarages = List<Map<String, dynamic>>.from(data['garages']);
        } else if (data['data'] != null) {
          loadedGarages = List<Map<String, dynamic>>.from(data['data']);
        }

        garages.value = loadedGarages;
        applyFilters();
      } else {
        Get.snackbar(
          'error'.tr,
          data['message'] ?? 'something_went_wrong'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    final cityFilter = selectedCity.value.toLowerCase();

    final results = garages.where((garage) {
      final name = garage['name']?.toString().toLowerCase() ?? '';
      final address = garage['address']?.toString().toLowerCase() ?? '';
      final description = garage['description']?.toString().toLowerCase() ?? '';
      final city = garage['city']?.toString().toLowerCase() ?? '';

      final matchesSearch = query.isEmpty ||
          name.contains(query) ||
          address.contains(query) ||
          description.contains(query);

      final matchesCity = cityFilter == 'all' || city == cityFilter;

      return matchesSearch && matchesCity;
    }).toList();

    filteredGarages.value = results;
  }

  Future<void> refreshAfterReservation() async {
    await fetchGarages();
  }

  Future<void> toggleFavorite(int garageId) async {
    final url = Uri.parse('$baseUrl/toggle-favorite');
    try {
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({'garage_id': garageId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == 'added') {
          favoriteGarageIds.add(garageId);
        } else if (data['status'] == 'removed') {
          favoriteGarageIds.remove(garageId);
        }
      } else {
        Get.snackbar(
          'error'.tr,
          data['message'] ?? 'something_went_wrong'.tr,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchFavorites() async {
    isLoading.value = true;
    try {
      final url = Uri.parse('$baseUrl/favorites');
      final response = await http.get(url, headers: await _headers());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        favoriteGarages.value = List<Map<String, dynamic>>.from(data['data']);
      } else {
        Get.snackbar(
          'error'.tr,
          data['message'] ?? 'something_went_wrong'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    fetchGarages();
    searchController.addListener(applyFilters);
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
