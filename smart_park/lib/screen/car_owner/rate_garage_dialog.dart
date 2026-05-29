import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/rating_controller.dart';
import '../../widgets/star_rating.dart';

class RateGarageDialog extends StatelessWidget {
  final int garageId;
  final int reservationId;
  final String garageName;
  final VoidCallback onSubmitted;

  RateGarageDialog({
    super.key,
    required this.garageId,
    required this.reservationId,
    required this.garageName,
    required this.onSubmitted,
  });

  static const Color _card = Colors.white;
  static const Color _heading = Color(0xFF0B1F45);
  static const Color _muted = Color(0xFF5C6B82);
  static const Color _border = Color(0xFFE2E7F0);
  static const Color _amber = Color(0xFFFFC107);

  late final RatingController controller =
      Get.put(RatingController(), tag: 'rate-$reservationId');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'rate_garage'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _heading,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              garageName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted),
            ),
            const SizedBox(height: 14),
            Obx(() => StarRatingPicker(
                  value: controller.stars.value,
                  onChanged: (v) => controller.stars.value = v,
                )),
            const SizedBox(height: 10),
            TextField(
              controller: controller.commentController,
              maxLines: 3,
              style: const TextStyle(color: _heading),
              decoration: InputDecoration(
                hintText: 'leave_a_comment_optional'.tr,
                hintStyle: const TextStyle(color: _muted),
                filled: true,
                fillColor: const Color(0xFFF5F7FB),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2EC4B6)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _heading,
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('close'.tr),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () async {
                                if (controller.stars.value == 0) {
                                  Get.snackbar(
                                    'error'.tr,
                                    'please_select_rating'.tr,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 12,
                                  );
                                  return;
                                }
                                final ok = await controller.submitRating(
                                  garageId: garageId,
                                  reservationId: reservationId,
                                );
                                if (ok) {
                                  Get.back();
                                  onSubmitted();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _amber,
                          foregroundColor: _heading,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          controller.isSubmitting.value
                              ? 'submitting'.tr
                              : 'submit'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
