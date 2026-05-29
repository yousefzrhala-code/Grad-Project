import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/garage_services_controller.dart';

class GarageServicesScreen extends StatelessWidget {
  GarageServicesScreen({super.key});

  final GarageServicesController controller =
      Get.put(GarageServicesController());
  final TextEditingController _customCtrl = TextEditingController();

  static const Color _accent  = Color(0xFF2EC4B6);
  static const Color _navy   = Color(0xFF0B1F45);
  static const Color _muted  = Color(0xFF5C6B82);
  static const Color _bg     = Color(0xFFF5F7FB);
  static const Color _border = Color(0xFFE2E7F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        title: Text('garage_services'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: _accent));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.services.isNotEmpty) ...[
              _sectionHeader('active_services'.tr),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.services
                    .map((s) => _activeChip(s))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // ── Preset services ─────────────────────────────────────────
            _sectionHeader('add_service'.tr),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kPresetServices
                  .map((opt) => _presetChip(opt))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // ── Custom service ─────────────────────────────────────────
            _sectionHeader('custom_service'.tr),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customCtrl,
                    style: const TextStyle(color: _navy),
                    decoration: InputDecoration(
                      hintText: 'custom_service_hint'.tr,
                      hintStyle: const TextStyle(color: _muted),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: _accent, width: 1.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final text = _customCtrl.text.trim();
                    if (text.isEmpty) return;
                    await controller.addCustomService(text);
                    _customCtrl.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('add'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: _navy, fontWeight: FontWeight.w800, fontSize: 15),
    );
  }

  Widget _activeChip(Map<String, dynamic> service) {
    final iconName = service['icon']?.toString() ?? '';
    final icon = iconFromName(iconName);
    return Chip(
      avatar: Icon(icon, size: 16, color: _accent),
      label: Text(service['name']?.toString() ?? '',
          style: const TextStyle(
              color: _navy, fontWeight: FontWeight.w600)),
      backgroundColor: _accent.withOpacity(0.1),
      side: BorderSide(color: _accent.withOpacity(0.3)),
      deleteIcon:
          const Icon(Icons.close, size: 16, color: Colors.redAccent),
      onDeleted: () => controller.removeService(service['id'] as int),
    );
  }

  Widget _presetChip(ServiceOption opt) {
    return Obx(() {
      final added = controller.hasService(opt.name);
      return GestureDetector(
        onTap: added
            ? null
            : () => controller.addService(opt.name, opt.iconName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: added
                ? _accent.withOpacity(0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: added ? _accent.withOpacity(0.4) : _border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(opt.icon,
                  size: 16,
                  color: added ? _accent : _muted),
              const SizedBox(width: 6),
              Text(
                opt.name,
                style: TextStyle(
                  color: added ? _accent : _navy,
                  fontWeight:
                      added ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (added) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle,
                    size: 14, color: _accent),
              ],
            ],
          ),
        ),
      );
    });
  }
}
