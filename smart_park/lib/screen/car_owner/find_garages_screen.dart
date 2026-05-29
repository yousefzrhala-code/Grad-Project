import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_park/controller/find_garages_controller.dart';

import '../../widgets/star_rating.dart';
import 'garage_details_screen.dart';
import 'make_reservation_screen.dart';

class FindGaragesScreen extends StatefulWidget {
  const FindGaragesScreen({super.key});

  @override
  State<FindGaragesScreen> createState() => _FindGaragesScreenState();
}

class _FindGaragesScreenState extends State<FindGaragesScreen> {
  late final FindGaragesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(FindGaragesController());
    controller.fetchGarages();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B1F45),
        elevation: 0,
        title: Text(
          'find_garages'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: controller.searchController,
                  style: const TextStyle(
              color: Color(0xFF0B1F45)),
                  decoration: InputDecoration(
                    hintText: 'search_garages'.tr,
                    hintStyle: TextStyle(
              color: Color(0xFF5C6B82),
                    ),
                    prefixIcon: const Icon(Icons.search, color: const Color(0xFF0B1F45)),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FB),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E7F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedCity.value,
                        dropdownColor: Colors.white,
                        iconEnabledColor: const Color(0xFF0B1F45),
                        isExpanded: true,
                        style: const TextStyle(
              color: Color(0xFF0B1F45)),
                        items: controller.cities.map((city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(
                              city == 'all' ? 'all_cities'.tr : city,
                              style: const TextStyle(
              color: Color(0xFF0B1F45)),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedCity.value = value;
                            controller.fetchGarages();
                          }
                        },
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF2EC4B6)));
              }

              if (controller.filteredGarages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2EC4B6).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_parking_outlined,
                          color: Color(0xFF2EC4B6),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_garages_found'.tr,
                        style: const TextStyle(
                          color: Color(0xFF0B1F45),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'try_different_search'.tr,
                        style: const TextStyle(
                          color: Color(0xFF5C6B82),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF2EC4B6),
                onRefresh: controller.fetchGarages,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredGarages.length,
                  itemBuilder: (context, index) {
                    final garage = controller.filteredGarages[index];
                    final availableSpots = garage['available_spots'] ?? 0;
                    final pricePerHour = garage['price_per_hour'] ?? 0;
                    final garageName =
                        garage['name']?.toString() ?? 'garage'.tr;
                    final location = garage['location']?.toString() ?? '';
                    final city = garage['city']?.toString() ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFE2E7F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B1F45).withOpacity(0.05),
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
                                    color: const Color(0xFF2EC4B6).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.local_parking_rounded,
                                    color: Color(0xFF2EC4B6),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    garageName,
                                    style: const TextStyle(
              color: Color(0xFF0B1F45),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                // ❤️ Favorite Icon
                                Obx(() {
                                  final isFav = controller.isFavorite(garage['id']);
                                  return IconButton(
                                    onPressed: () {
                                      controller.toggleFavorite(garage['id']);
                                    },
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.redAccent : const Color(0xFFBCC5D3),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (location.isNotEmpty)
                              _infoRow(Icons.location_on_outlined, location),
                            if (city.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _infoRow(
                                  Icons.location_city_outlined,
                                  "${'city'.tr}: $city",
                                ),
                              ),
                            const SizedBox(height: 10),
                            _infoRow(
                              Icons.local_parking_outlined,
                              "${'available_spots'.tr}: $availableSpots",
                            ),
                            const SizedBox(height: 8),
                            _infoRow(
                              Icons.attach_money_outlined,
                              "${'price_per_hour'.tr}: $pricePerHour",
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                StarRatingDisplay(
                                  value: double.tryParse(
                                          garage['average_rating']?.toString() ??
                                              '0') ??
                                      0,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "(${garage['ratings_count'] ?? 0})",
                                  style: const TextStyle(
              color: Color(0xFF5C6B82)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 46,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.info_outline,
                                          color: const Color(0xFF0B1F45)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFFE2E7F0)),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                      ),
                                      onPressed: () => Get.to(
                                          () => GarageDetailsScreen(
                                                garageId: garage['id'],
                                                garageName: garageName,
                                              )),
                                      label: Text(
                                        'details'.tr,
                                        style: const TextStyle(
              color: Color(0xFF0B1F45),
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 46,
                                    child: ElevatedButton(
                                      onPressed: availableSpots > 0
                                          ? () async {
                                              await Get.to(
                                                  () => MakeReservationScreen(
                                                        garageId: garage['id'],
                                                        garageName: garageName,
                                                        pricePerHour: double.tryParse(
                                                                garage['price_per_hour']
                                                                        ?.toString() ??
                                                                    '0') ??
                                                            0,
                                                      ));
                                              await controller
                                                  .refreshAfterReservation();
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFC107),
                                        foregroundColor: Colors.black,
                                        disabledBackgroundColor:
                                            Colors.grey.shade500,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        availableSpots > 0
                                            ? 'make_reservation'.tr
                                            : 'not_available'.tr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2EC4B6), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5C6B82),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}