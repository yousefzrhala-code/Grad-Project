import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/OwnerReservationsController.dart';


class MyReservationScreen extends StatelessWidget {
  MyReservationScreen({super.key});

  final controller = Get.put(OwnerReservationsController());

  Color _paymentStatusColor(String status) {
    switch (status) {
      case 'succeeded':
        return Colors.green;
      case 'pending_cash':
        return Colors.orange;
      default:
        return const Color(0xFF5C6B82);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return const Color(0xFF2EC4B6);
      case 'cancelled':
        return Colors.grey;
      default:
        return const Color(0xFF5C6B82);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_top_outlined;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.task_alt_outlined;
      case 'cancelled':
        return Icons.block_outlined;
      default:
        return Icons.info_outline;
    }
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
          'my_reservations'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Color(0xFF0B1F45)),
            onPressed: controller.fetchReservations,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2EC4B6)));
        }

        if (controller.reservations.isEmpty) {
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
                  child: const Icon(Icons.event_busy_outlined,
                      color: Color(0xFF2EC4B6), size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'no_reservations'.tr,
                  style: const TextStyle(
                    color: Color(0xFF0B1F45),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'no_pending_or_accepted'.tr,
                  style: const TextStyle(
                    color: Color(0xFF5C6B82),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.reservations.length,
          itemBuilder: (context, index) {
            final item = controller.reservations[index];
            final status = item['status']?.toString() ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E7F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B1F45).withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(w * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: name + status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2EC4B6).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.person_outline,
                                  color: Color(0xFF2EC4B6), size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item['car_owner']?['name'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFF0B1F45),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _statusColor(status).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _statusIcon(status),
                                color: _statusColor(status),
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                status.tr,
                                style: TextStyle(
                                  color: _statusColor(status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFE2E7F0), height: 1),
                    const SizedBox(height: 12),

                    _infoRow(Icons.calendar_today, item['reservation_date']?.toString() ?? ''),
                    _infoRow(Icons.access_time,
                        "${item['start_time']} - ${item['end_time']}"),
                    _infoRow(Icons.local_parking,
                        "${'spots'.tr}: ${item['number_of_spots']}"),
                    if (item['total_cost'] != null)
                      _infoRow(
                        Icons.monetization_on_outlined,
                        "${'total_cost'.tr}: ${item['total_cost']} JOD",
                      ),
                    if (item['car_owner']?['phone'] != null &&
                        item['car_owner']['phone'].toString().isNotEmpty)
                      _infoRow(
                        Icons.phone_outlined,
                        "${'car_owner_phone'.tr}: ${item['car_owner']['phone']}",
                      ),
                    if (item['payment'] != null)
                      _paymentInfoRow(item['payment'] as Map<String, dynamic>),
                    if (item['owner_response_note'] != null &&
                        item['owner_response_note'].toString().isNotEmpty)
                      _infoRow(
                        Icons.notes_outlined,
                        "${'owner_note'.tr}: ${item['owner_response_note']}",
                      ),

                    const SizedBox(height: 12),

                    // ✅ Accept / Reject buttons (for pending)
                    if (status == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline,
                                  size: 18),
                              onPressed: () => _showDialog(
                                context,
                                item['id'],
                                'accepted',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade50,
                                foregroundColor: Colors.green.shade700,
                                elevation: 0,
                                side: BorderSide(color: Colors.green.shade200),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              label: Text('accept'.tr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              onPressed: () => _showDialog(
                                context,
                                item['id'],
                                'rejected',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red.shade700,
                                elevation: 0,
                                side: BorderSide(color: Colors.red.shade200),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              label: Text('reject'.tr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),

                    // ✅ Action buttons for accepted reservations
                    if (status == 'accepted')
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Check-in: only when not yet checked-in
                          if (item['checked_in_at'] == null)
                            _ownerActionChip(
                              icon: Icons.login_rounded,
                              label: 'check_in'.tr,
                              color: const Color(0xFF2EC4B6),
                              onTap: () => controller.checkIn(item['id']),
                            ),
                          // Check-out: only after check-in and before check-out
                          if (item['checked_in_at'] != null &&
                              item['checked_out_at'] == null)
                            _ownerActionChip(
                              icon: Icons.logout_rounded,
                              label: 'check_out'.tr,
                              color: const Color(0xFF2EC4B6),
                              onTap: () => controller.checkOut(item['id']),
                            ),
                          // Mark as completed (manual)
                          _ownerActionChip(
                            icon: Icons.task_alt_outlined,
                            label: 'mark_as_completed'.tr,
                            color: const Color(0xFF2EC4B6),
                            onTap: () =>
                                _showCompleteDialog(context, item['id']),
                          ),
                          // Cancel (garage owner can cancel)
                          _ownerActionChip(
                            icon: Icons.cancel_outlined,
                            label: 'cancel_reservation'.tr,
                            color: const Color(0xFFD64545),
                            onTap: () =>
                                _showCancelDialog(context, item['id']),
                          ),
                        ],
                      ),

                    // Pending reservations can also be cancelled by owner
                    if (status == 'pending')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton.icon(
                          onPressed: () =>
                              _showCancelDialog(context, item['id']),
                          icon: const Icon(Icons.cancel_outlined,
                              size: 16, color: Color(0xFFD64545)),
                          label: Text(
                            'cancel_reservation'.tr,
                            style: const TextStyle(
                                color: Color(0xFFD64545),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showDialog(BuildContext context, int id, String status) {
    final noteController = TextEditingController();

    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: status == 'accepted' ? 'accept'.tr : 'reject'.tr,
      titleStyle: const TextStyle(
        color: Color(0xFF0B1F45),
        fontWeight: FontWeight.w800,
      ),
      content: Column(
        children: [
          TextField(
            controller: noteController,
            style: const TextStyle(color: Color(0xFF0B1F45)),
            decoration: InputDecoration(
              hintText: 'optional_note'.tr,
              hintStyle: const TextStyle(color: Color(0xFF5C6B82)),
              filled: true,
              fillColor: const Color(0xFFF5F7FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2EC4B6), width: 1.2),
              ),
            ),
          ),
        ],
      ),
      textConfirm: 'confirm'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: status == 'accepted' ? Colors.green : Colors.red,
      cancelTextColor: const Color(0xFF5C6B82),
      onConfirm: () {
        Get.back();
        controller.respond(id, status, noteController.text);
      },
    );
  }

  Widget _ownerActionChip({
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
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, int id) {
    final reasonController = TextEditingController();

    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: 'cancel_reservation'.tr,
      titleStyle: const TextStyle(
        color: Color(0xFF0B1F45),
        fontWeight: FontWeight.w800,
      ),
      content: Column(
        children: [
          TextField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(color: Color(0xFF0B1F45)),
            decoration: InputDecoration(
              hintText: 'enter_cancel_reason_optional'.tr,
              hintStyle: const TextStyle(color: Color(0xFF5C6B82)),
              filled: true,
              fillColor: const Color(0xFFF5F7FB),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD64545)),
              ),
            ),
          ),
        ],
      ),
      textConfirm: 'confirm'.tr,
      textCancel: 'close'.tr,
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFD64545),
      cancelTextColor: const Color(0xFF5C6B82),
      onConfirm: () {
        Get.back();
        controller.cancelByOwner(id, reason: reasonController.text);
      },
    );
  }

  void _showCompleteDialog(BuildContext context, int id) {
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: 'mark_as_completed'.tr,
      titleStyle: const TextStyle(
        color: Color(0xFF0B1F45),
        fontWeight: FontWeight.w800,
      ),
      middleText: 'complete_reservation_confirm'.tr,
      middleTextStyle: const TextStyle(
        color: Color(0xFF5C6B82),
        fontSize: 14,
        height: 1.5,
      ),
      textConfirm: 'confirm'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF2EC4B6),
      cancelTextColor: const Color(0xFF5C6B82),
      onConfirm: () {
        Get.back();
        controller.complete(id);
      },
    );
  }

  Widget _paymentInfoRow(Map<String, dynamic> payment) {
    final method = payment['payment_method']?.toString() ?? '';
    final isCard = method == 'card';
    final last4 = payment['card_last4']?.toString() ?? '';
    final status = payment['status']?.toString() ?? '';

    String methodLabel;
    if (isCard) {
      methodLabel = last4.isNotEmpty
          ? '${'pay_with_card'.tr} •••• $last4'
          : 'pay_with_card'.tr;
    } else {
      methodLabel = 'pay_with_cash'.tr;
    }

    String statusLabel;
    Color statusColor;
    if (status == 'succeeded') {
      statusLabel = 'paid'.tr;
      statusColor = Colors.green;
    } else if (status == 'pending_cash') {
      statusLabel = 'cash_pending'.tr;
      statusColor = Colors.orange;
    } else {
      statusLabel = status;
      statusColor = const Color(0xFF5C6B82);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isCard ? Icons.credit_card_outlined : Icons.payments_outlined,
            color: const Color(0xFF2EC4B6),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${'payment_method'.tr}: $methodLabel',
              style: const TextStyle(color: Color(0xFF5C6B82)),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2EC4B6), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF5C6B82)),
            ),
          ),
        ],
      ),
    );
  }
}
