import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/reservation_controller.dart';
import '../../models/reservation_model.dart';
import 'rate_garage_dialog.dart';
import 'report_garage_screen.dart';

class MyReservationsScreen extends StatelessWidget {
  MyReservationsScreen({super.key});

  final ReservationController controller = Get.put(ReservationController());

  final Color accentColor = const Color(0xFF2EC4B6);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.redAccent;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return const Color(0xFF2EC4B6);
      default:
        return const Color(0xFF5C6B82);
    }
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.tr,
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5C6B82)),
          ),
        ),
      ],
    );
  }

  Widget _reservationCard(
      BuildContext context,
      ReservationModel item, {
        bool showCancel = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E7F0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1F45).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.garageName,
                  style: const TextStyle(
              color: Color(0xFF0B1F45),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _statusBadge(item.status),
            ],
          ),

          const SizedBox(height: 12),

          if (item.garageLocation != null &&
              item.garageLocation!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _infoRow(
                Icons.location_on_outlined,
                item.garageLocation!,
              ),
            ),

          _infoRow(
            Icons.calendar_month_outlined,
            item.reservationDate,
          ),
          const SizedBox(height: 8),

          _infoRow(
            Icons.access_time,
            "${item.startTime} - ${item.endTime}",
          ),
          const SizedBox(height: 8),

          _infoRow(
            Icons.local_parking_outlined,
            "${'number_of_spots'.tr}: ${item.numberOfSpots}",
          ),
          const SizedBox(height: 8),

          _infoRow(
            Icons.monetization_on_outlined,
            "${'total_cost'.tr}: ${item.totalCost ?? 0} JOD",
          ),
          if (item.garageOwnerPhone != null &&
              item.garageOwnerPhone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.phone_outlined,
                "${'garage_owner_phone'.tr}: ${item.garageOwnerPhone!}"),
          ],

          /// 🔸 Cancel Reason
          if (item.cancelReason != null &&
              item.cancelReason!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "${'cancel_reason'.tr}: ${item.cancelReason}",
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],

          /// 🔸 Owner Note
          if (item.ownerResponseNote != null &&
              item.ownerResponseNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "${'owner_note'.tr}: ${item.ownerResponseNote}",
              style: const TextStyle(
              color: Color(0xFF5C6B82)),
            ),
          ],

          /// 🔻 Action buttons row (Check-in / Cancel / Rate / Report)
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (showCancel && item.canCheckIn)
                _actionChip(
                  icon: Icons.login_rounded,
                  label: 'check_in'.tr,
                  color: const Color(0xFF2EC4B6),
                  onTap: () => controller.checkInReservation(item.id),
                ),
              if (showCancel && item.canCheckOut)
                _actionChip(
                  icon: Icons.logout_rounded,
                  label: 'check_out'.tr,
                  color: const Color(0xFF2EC4B6),
                  onTap: () => controller.checkOutReservation(item.id),
                ),
              if (showCancel && item.canCancel)
                _actionChip(
                  icon: Icons.cancel_outlined,
                  label: 'cancel_reservation'.tr,
                  color: Colors.redAccent,
                  onTap: () => _showCancelDialog(item),
                ),
              if (showCancel &&
                  !item.canCancel &&
                  (item.status == 'pending' ||
                      item.status == 'accepted')) ...[
                _hintChip(
                  icon: Icons.info_outline,
                  label: 'cancel_window_closed'.tr,
                ),
              ],
              if (item.canRate)
                _actionChip(
                  icon: Icons.star_rounded,
                  label: 'rate_garage'.tr,
                  color: const Color(0xFFFFC107),
                  onTap: () => Get.dialog(
                    RateGarageDialog(
                      garageId: item.garageId,
                      reservationId: item.id,
                      garageName: item.garageName,
                      onSubmitted: () {
                        controller.fetchPreviousReservations();
                      },
                    ),
                  ),
                ),
              if (item.status != 'rejected' && item.status != 'cancelled')
                _actionChip(
                  icon: Icons.flag_outlined,
                  label: 'report_garage'.tr,
                  color: const Color(0xFF5C6B82),
                  onTap: () => Get.to(() => ReportGarageScreen(
                        garageId: item.garageId,
                        garageName: item.garageName,
                      )),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hintChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E7F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF5C6B82), size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
              color: Color(0xFF5C6B82), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showCancelDialog(ReservationModel item) {
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: 'cancel_reservation'.tr,
      titleStyle: const TextStyle(
              color: Color(0xFF0B1F45)),
      content: Column(
        children: [
          TextField(
            controller: controller.cancelReasonController,
            style: const TextStyle(
              color: Color(0xFF0B1F45)),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'enter_cancel_reason_optional'.tr,
              hintStyle: const TextStyle(
              color: Color(0xFF5C6B82)),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
              ),
            ),
          ),
        ],
      ),
      textCancel: 'close'.tr,
      textConfirm: 'confirm'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await controller.cancelReservation(item.id);
      },
    );
  }

  Widget _emptyState(String text) {
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
              Icons.event_note_outlined,
              color: Color(0xFF2EC4B6),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF0B1F45),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: const Color(0xFF0B1F45)),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            'my_reservations'.tr,
            style: const TextStyle(
              color: Color(0xFF0B1F45)),
          ),
        ),

        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF5F7FB),
                Colors.white,
                Color(0xFFEFF3F8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                TabBar(
                  indicatorColor: accentColor,
                  labelColor: const Color(0xFF0B1F45),
                  unselectedLabelColor: const Color(0xFF5C6B82),
                  tabs: [
                    Tab(text: 'upcoming'.tr),
                    Tab(text: 'previous'.tr),
                  ],
                ),

                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                          child: CircularProgressIndicator(color: accentColor));
                    }

                    return TabBarView(
                      children: [
                        RefreshIndicator(
                          color: accentColor,
                          onRefresh: () async {
                            await controller.fetchUpcomingReservations();
                          },
                          child: controller.upcomingReservations.isEmpty
                              ? LayoutBuilder(
                                  builder: (ctx, constraints) =>
                                      SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                      height: constraints.maxHeight,
                                      child: _emptyState(
                                          'no_upcoming_reservations'.tr),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount:
                                      controller.upcomingReservations.length,
                                  itemBuilder: (context, index) {
                                    final item = controller
                                        .upcomingReservations[index];
                                    return _reservationCard(
                                      context,
                                      item,
                                      showCancel: true,
                                    );
                                  },
                                ),
                        ),

                        RefreshIndicator(
                          color: accentColor,
                          onRefresh: () async {
                            await controller.fetchPreviousReservations();
                          },
                          child: controller.previousReservations.isEmpty
                              ? LayoutBuilder(
                                  builder: (ctx, constraints) =>
                                      SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                      height: constraints.maxHeight,
                                      child: _emptyState(
                                          'no_previous_reservations'.tr),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount:
                                      controller.previousReservations.length,
                                  itemBuilder: (context, index) {
                                    final item = controller
                                        .previousReservations[index];
                                    return _reservationCard(context, item);
                                  },
                                ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}