import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/find_garages_controller.dart';
import 'make_reservation_screen.dart';

class FavoriteGaragesScreen extends StatefulWidget {
  const FavoriteGaragesScreen({super.key});

  @override
  State<FavoriteGaragesScreen> createState() => _FavoriteGaragesScreenState();
}

class _FavoriteGaragesScreenState extends State<FavoriteGaragesScreen> {
  static const Color _teal   = Color(0xFF2EC4B6);
  static const Color _navy   = Color(0xFF0B1F45);
  static const Color _muted  = Color(0xFF5C6B82);
  static const Color _border = Color(0xFFE2E7F0);

  late final FindGaragesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<FindGaragesController>();
    controller.fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        title: Text(
          'favorite_garages'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: _navy),
            onPressed: controller.fetchFavorites,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _teal),
          );
        }

        if (controller.favoriteGarages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border_rounded,
                      color: _teal, size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'no_favorites_found'.tr,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'explore_garages_hint'.tr,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: _teal,
          onRefresh: controller.fetchFavorites,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.favoriteGarages.length,
            itemBuilder: (context, index) {
              final garage        = controller.favoriteGarages[index];
              final availableSpots = garage['available_spots'] ?? 0;
              final pricePerHour  = garage['price_per_hour'] ?? 0;
              final garageName    = garage['name'] ?? 'garage'.tr;
              final location      = garage['location'] ?? '';
              final city          = garage['city'] ?? '';
              final isAvailable   = availableSpots > 0 && (garage['is_active'] != false);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(w * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _teal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.local_parking_rounded,
                              color: _teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              garageName,
                              style: const TextStyle(
                                color: _navy,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          // Availability badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? Colors.green.withOpacity(0.12)
                                  : Colors.grey.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isAvailable ? 'Open'.tr : 'not_available'.tr,
                              style: TextStyle(
                                color: isAvailable
                                    ? Colors.green.shade700
                                    : _muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Favourite toggle
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              await controller.toggleFavorite(garage['id']);
                              controller.fetchFavorites();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFEEF2F8)),
                      const SizedBox(height: 12),
                      if (location.isNotEmpty)
                        _infoRow(Icons.location_on_outlined, location),
                      if (city.isNotEmpty)
                        _infoRow(Icons.location_city_outlined,
                            '${'city'.tr}: $city'),
                      _infoRow(Icons.local_parking_outlined,
                          '${'available_spots'.tr}: $availableSpots'),
                      _infoRow(Icons.monetization_on_outlined,
                          '${'price_per_hour'.tr}: ${double.tryParse(pricePerHour.toString())?.toStringAsFixed(2) ?? pricePerHour} JOD/${'per_hour'.tr}'),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isAvailable
                              ? () async {
                                  await Get.to(() => MakeReservationScreen(
                                        garageId: garage['id'],
                                        garageName: garageName,
                                        pricePerHour: double.tryParse(
                                                pricePerHour.toString()) ??
                                            0,
                                      ));
                                  controller.fetchFavorites();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: const Color(0xFFE2E7F0),
                            disabledForegroundColor: _muted,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isAvailable
                                ? 'make_reservation'.tr
                                : 'not_available'.tr,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _teal, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _muted, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
