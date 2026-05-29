import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/constant_api.dart';
import 'auth_controller.dart';

class ServiceOption {
  final String name;
  final IconData icon;
  final String iconName;
  const ServiceOption({
    required this.name,
    required this.icon,
    required this.iconName,
  });
}

const List<ServiceOption> kPresetServices = [
  ServiceOption(name: 'Car Wash',       icon: Icons.local_car_wash,       iconName: 'local_car_wash'),
  ServiceOption(name: 'EV Charging',    icon: Icons.ev_station,            iconName: 'ev_station'),
  ServiceOption(name: 'Oil Change',     icon: Icons.oil_barrel_outlined,   iconName: 'oil_barrel'),
  ServiceOption(name: 'Tyre Inflation', icon: Icons.tire_repair_outlined,  iconName: 'tire_repair'),
  ServiceOption(name: 'Covered Parking',icon: Icons.garage_outlined,       iconName: 'garage'),
  ServiceOption(name: 'Security Camera',icon: Icons.videocam_outlined,     iconName: 'videocam'),
  ServiceOption(name: 'Valet',          icon: Icons.drive_eta_outlined,    iconName: 'drive_eta'),
  ServiceOption(name: '24/7 Access',    icon: Icons.access_time_filled,    iconName: 'access_time_filled'),
  ServiceOption(name: 'WiFi',           icon: Icons.wifi_outlined,         iconName: 'wifi'),
  ServiceOption(name: 'Disabled Access',icon: Icons.accessible_outlined,   iconName: 'accessible'),
];

IconData iconFromName(String name) {
  switch (name) {
    case 'local_car_wash':      return Icons.local_car_wash;
    case 'ev_station':          return Icons.ev_station;
    case 'oil_barrel':          return Icons.oil_barrel_outlined;
    case 'tire_repair':         return Icons.tire_repair_outlined;
    case 'garage':              return Icons.garage_outlined;
    case 'videocam':            return Icons.videocam_outlined;
    case 'drive_eta':           return Icons.drive_eta_outlined;
    case 'access_time_filled':  return Icons.access_time_filled;
    case 'wifi':                return Icons.wifi_outlined;
    case 'accessible':          return Icons.accessible_outlined;
    default:                    return Icons.miscellaneous_services_outlined;
  }
}

class GarageServicesController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();

  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  @override
  void onInit() {
    fetchServices();
    super.onInit();
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/garage/services'),
        headers: await _headers(),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        services.value =
            List<Map<String, dynamic>>.from(data['services'] ?? []);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool hasService(String name) =>
      services.any((s) => s['name'] == name);

  Future<void> addService(String name, String iconName) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/garage/services'),
        headers: await _headers(),
        body: jsonEncode({'name': name, 'icon': iconName}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 201) {
        services.add(Map<String, dynamic>.from(data['service']));
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  Future<void> removeService(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/garage/services/$id'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        services.removeWhere((s) => s['id'] == id);
      } else {
        final data = jsonDecode(res.body);
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  Future<void> addCustomService(String name) async {
    if (name.trim().isEmpty) return;
    await addService(name.trim(), 'miscellaneous_services');
  }
}
