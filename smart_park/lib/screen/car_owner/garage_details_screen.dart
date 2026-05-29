import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/garage_details_controller.dart';
import '../../controller/garage_services_controller.dart'
    show iconFromName;
import '../../widgets/star_rating.dart';
import 'make_reservation_screen.dart';
import 'report_garage_screen.dart';

class GarageDetailsScreen extends StatefulWidget {
  final int garageId;
  final String garageName;

  const GarageDetailsScreen({
    super.key,
    required this.garageId,
    required this.garageName,
  });

  @override
  State<GarageDetailsScreen> createState() => _GarageDetailsScreenState();
}

class _GarageDetailsScreenState extends State<GarageDetailsScreen> {
  static const Color _bg = Color(0xFFF5F7FB);
  static const Color _card = Colors.white;
  static const Color _heading = Color(0xFF0B1F45);
  static const Color _muted = Color(0xFF5C6B82);
  static const Color _border = Color(0xFFE2E7F0);
  static const Color _teal = Color(0xFF2EC4B6);
  static const Color _amber = Color(0xFFFFC107);

  late final GarageDetailsController controller;
  final RxInt _photoPage = 0.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(GarageDetailsController(), tag: 'details-${widget.garageId}');
    controller.fetchDetails(widget.garageId);
    controller.startAvailabilityPolling(widget.garageId);
  }

  @override
  void dispose() {
    Get.delete<GarageDetailsController>(tag: 'details-${widget.garageId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        foregroundColor: _heading,
        elevation: 0.5,
        title: Text(
          widget.garageName,
          style: const TextStyle(fontWeight: FontWeight.w700, color: _heading),
        ),
        actions: [
          IconButton(
            tooltip: 'report_garage'.tr,
            icon: const Icon(Icons.flag_outlined, color: _heading),
            onPressed: () => Get.to(() => ReportGarageScreen(
                  garageId: widget.garageId,
                  garageName: widget.garageName,
                )),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.garage.value == null) {
          return const Center(child: CircularProgressIndicator(color: _teal));
        }

        final g = controller.garage.value;
        if (g == null) {
          return Center(
            child: Text(
              'no_garage_data'.tr,
              style: const TextStyle(color: _muted),
            ),
          );
        }

        return RefreshIndicator(
          color: _teal,
          onRefresh: () => controller.fetchDetails(widget.garageId),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _imagesGallery(controller.images),
              const SizedBox(height: 16),
              _headerCard(g),
              const SizedBox(height: 12),
              _availabilityCard(),
              const SizedBox(height: 12),
              _servicesCard(),
              const SizedBox(height: 12),
              _descriptionCard(g),
              const SizedBox(height: 12),
              _ratingsCard(),
              const SizedBox(height: 24),
              _reserveButton(g),
            ],
          ),
        );
      }),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1F45).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _imagesGallery(List<Map<String, dynamic>> images) {
    if (images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFEFF3F8),
          border: Border.all(color: _border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_parking_rounded, color: _muted, size: 52),
            const SizedBox(height: 8),
            Text('no_photos_yet'.tr,
                style: const TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => _photoPage.value = i,
            itemBuilder: (context, index) {
              final path = images[index]['image_path']?.toString() ?? '';
              final url = path.startsWith('http')
                  ? path
                  : 'http://127.0.0.1:8000/storage/$path';
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFEFF3F8),
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: _muted, size: 48),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10,
            child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(images.length, (i) {
                    final active = i == _photoPage.value;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? _teal
                            : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                )),
          ),
        // Photo count badge
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_outlined,
                    color: Colors.white, size: 13),
                const SizedBox(width: 4),
                Text('${images.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _servicesCard() {
    return Obx(() {
      final services = controller.services;
      if (services.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.miscellaneous_services_outlined,
                    color: _teal, size: 18),
                const SizedBox(width: 8),
                Text(
                  'garage_services'.tr,
                  style: const TextStyle(
                      color: _heading,
                      fontWeight: FontWeight.w800,
                      fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services.map((s) {
                final iconName = s['icon']?.toString() ?? '';
                final icon = iconFromName(iconName);
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _teal.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 15, color: _teal),
                      const SizedBox(width: 6),
                      Text(
                        s['name']?.toString() ?? '',
                        style: const TextStyle(
                            color: _heading,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _headerCard(Map<String, dynamic> g) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            g['name']?.toString() ?? '',
            style: const TextStyle(
                color: _heading, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_city_outlined,
                  color: _teal, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${g['city'] ?? ''}, ${g['address'] ?? ''}",
                  style: const TextStyle(color: _muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Obx(() => StarRatingDisplay(value: controller.averageRating.value)),
              const SizedBox(width: 8),
              Obx(() => Text(
                    "${controller.averageRating.value.toStringAsFixed(1)} (${controller.ratingsCount.value})",
                    style: const TextStyle(color: _muted),
                  )),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${'price_per_hour'.tr}: ${g['price_per_hour'] ?? 0}",
                  style: const TextStyle(
                      color: Color(0xFFB77C00),
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _availabilityCard() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: _teal.withOpacity(0.08),
            border: Border.all(color: _teal.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_parking_rounded, color: _teal),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${'available_spots'.tr}: ${controller.availableSpots.value}",
                  style: const TextStyle(
                      color: _heading,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'refresh'.tr,
                onPressed: () => controller.refreshAvailability(widget.garageId),
                icon: const Icon(Icons.refresh, color: _teal),
              ),
            ],
          ),
        ));
  }

  Widget _descriptionCard(Map<String, dynamic> g) {
    final desc = g['description']?.toString() ?? '';
    if (desc.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description'.tr,
            style: const TextStyle(
                color: _heading,
                fontWeight: FontWeight.w800,
                fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: _muted, height: 1.5)),
        ],
      ),
    );
  }

  Widget _ratingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ratings'.tr,
            style: const TextStyle(
                color: _heading,
                fontWeight: FontWeight.w800,
                fontSize: 15),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.ratings.isEmpty) {
              return Text(
                'no_ratings_yet'.tr,
                style: const TextStyle(color: _muted),
              );
            }
            return Column(
              children: controller.ratings.map((r) {
                final stars =
                    int.tryParse(r['stars']?.toString() ?? '0') ?? 0;
                final comment = r['comment']?.toString() ?? '';
                final userName =
                    r['user']?['name']?.toString() ?? 'User'.tr;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(userName,
                              style: const TextStyle(
                                  color: _heading,
                                  fontWeight: FontWeight.w700)),
                          const Spacer(),
                          StarRatingDisplay(value: stars.toDouble()),
                        ],
                      ),
                      if (comment.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(comment,
                            style: const TextStyle(color: _muted)),
                      ],
                      const Divider(color: _border),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _reserveButton(Map<String, dynamic> g) {
    return Obx(() {
      final spots = controller.availableSpots.value;
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.event_available_outlined),
          onPressed: spots > 0
              ? () async {
                  await Get.to(() => MakeReservationScreen(
                        garageId: widget.garageId,
                        garageName: g['name']?.toString() ?? widget.garageName,
                        pricePerHour: double.tryParse(
                                g['price_per_hour']?.toString() ?? '0') ??
                            0,
                      ));
                  await controller.fetchDetails(widget.garageId);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _amber,
            foregroundColor: _heading,
            disabledBackgroundColor: const Color(0xFFE2E7F0),
            disabledForegroundColor: _muted,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          label: Text(
            spots > 0 ? 'make_reservation'.tr : 'not_available'.tr,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    });
  }
}
