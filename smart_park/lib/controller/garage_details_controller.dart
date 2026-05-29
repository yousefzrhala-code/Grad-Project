import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/constant_api.dart';
import 'auth_controller.dart';

class GarageDetailsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxBool isLoading = false.obs;
  RxBool isLoadingRatings = false.obs;

  Rxn<Map<String, dynamic>> garage = Rxn<Map<String, dynamic>>();
  RxList<Map<String, dynamic>> images   = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> ratings  = <Map<String, dynamic>>[].obs;
  RxDouble averageRating = 0.0.obs;
  RxInt ratingsCount = 0.obs;
  RxInt availableSpots = 0.obs;

  Timer? _availabilityPoll;

  Future<Map<String, String>> _headers() async {
    final token = await authController.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> fetchDetails(int garageId) async {
    isLoading.value = true;
    try {
      final url = Uri.parse('$baseUrl/garages/$garageId');
      final response = await http.get(url, headers: await _headers());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final g = Map<String, dynamic>.from(data['garage']);
        garage.value = g;
        images.value   = List<Map<String, dynamic>>.from(g['images']   ?? []);
        services.value = List<Map<String, dynamic>>.from(g['services'] ?? []);
        ratings.value  = List<Map<String, dynamic>>.from(g['ratings']  ?? []);
        averageRating.value =
            double.tryParse((data['average_rating'] ?? 0).toString()) ?? 0.0;
        ratingsCount.value =
            int.tryParse((data['ratings_count'] ?? 0).toString()) ?? 0;
        availableSpots.value =
            int.tryParse((g['available_spots'] ?? 0).toString()) ?? 0;
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
    await refreshAvailability(garageId);
  }

  void startAvailabilityPolling(int garageId) {
    _availabilityPoll?.cancel();
    _availabilityPoll = Timer.periodic(const Duration(seconds: 15), (_) {
      refreshAvailability(garageId);
    });
  }

  Future<void> refreshAvailability(int garageId) async {
    try {
      final url = Uri.parse('$baseUrl/garages/$garageId/availability');
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        availableSpots.value =
            int.tryParse((data['available_spots'] ?? 0).toString()) ?? 0;
      }
    } catch (_) {
    }
  }

  Future<void> fetchRatings(int garageId) async {
    isLoadingRatings.value = true;
    try {
      final url = Uri.parse('$baseUrl/garages/$garageId/ratings');
      final response = await http.get(url, headers: await _headers());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ratings.value =
            List<Map<String, dynamic>>.from(data['ratings'] ?? []);
        averageRating.value =
            double.tryParse((data['average_rating'] ?? 0).toString()) ?? 0.0;
        ratingsCount.value =
            int.tryParse((data['ratings_count'] ?? 0).toString()) ?? 0;
      }
    } catch (_) {
    } finally {
      isLoadingRatings.value = false;
    }
  }

  @override
  void onClose() {
    _availabilityPoll?.cancel();
    super.onClose();
  }
}
