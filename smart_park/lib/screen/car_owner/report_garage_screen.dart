import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/report_controller.dart';


class ReportGarageScreen extends StatelessWidget {
  final int garageId;
  final String garageName;

  ReportGarageScreen({
    super.key,
    required this.garageId,
    required this.garageName,
  });

  static const Color _bg = Color(0xFFF5F7FB);
  static const Color _card = Colors.white;
  static const Color _heading = Color(0xFF0B1F45);
  static const Color _muted = Color(0xFF5C6B82);
  static const Color _border = Color(0xFFE2E7F0);
  static const Color _amber = Color(0xFFFFC107);

  final ReportController controller =
      Get.put(ReportController(), tag: 'report');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        foregroundColor: _heading,
        elevation: 0.5,
        title: Text('report_garage'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: _heading.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.flag_outlined,
                            color: Color(0xFFD64545)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              garageName,
                              style: const TextStyle(
                                color: _heading,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'report_garage_subtitle'.tr,
                              style: const TextStyle(color: _muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller.subjectController,
              style: const TextStyle(color: _heading),
              decoration: InputDecoration(
                labelText: 'Subject'.tr,
                labelStyle: const TextStyle(color: _muted),
                prefixIcon: const Icon(Icons.subject_outlined, color: _muted),
                filled: true,
                fillColor: _card,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2EC4B6)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller.messageController,
              maxLines: 6,
              style: const TextStyle(color: _heading),
              decoration: InputDecoration(
                labelText: 'Message'.tr,
                alignLabelWithHint: true,
                labelStyle: const TextStyle(color: _muted),
                filled: true,
                fillColor: _card,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2EC4B6)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            final ok =
                                await controller.submitReport(garageId);
                            if (ok) Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _amber,
                      foregroundColor: _heading,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    label: Text(
                      controller.isSubmitting.value
                          ? 'Sending...'.tr
                          : 'submit_report'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
