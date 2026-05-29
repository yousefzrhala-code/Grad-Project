import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/garage_photos_controller.dart';

class GaragePhotosScreen extends StatelessWidget {
  GaragePhotosScreen({super.key});

  final GaragePhotosController controller = Get.put(GaragePhotosController());

  static const Color _accent = Color(0xFF2EC4B6);
  static const Color _navy  = Color(0xFF0B1F45);
  static const Color _muted = Color(0xFF5C6B82);
  static const Color _bg    = Color(0xFFF5F7FB);
  static const Color _border = Color(0xFFE2E7F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        title: Text('garage_photos'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Obx(() => controller.isUploading.value
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _accent),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  tooltip: 'add_photos'.tr,
                  onPressed: controller.pickAndUpload,
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: _accent));
        }

        if (controller.photos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: _accent, size: 48),
                ),
                const SizedBox(height: 16),
                Text('no_photos_yet'.tr,
                    style: const TextStyle(
                        color: _navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('tap_to_add_photos'.tr,
                    style: const TextStyle(color: _muted, fontSize: 13)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.pickAndUpload,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text('add_photos'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${'photos_count'.tr}: ${controller.photos.length}',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: controller.photos.length,
                itemBuilder: (context, index) {
                  final photo = controller.photos[index];
                  final url = controller.photoUrl(
                      photo['image_path']?.toString() ?? '');
                  return _photoTile(url, photo['id'] as int);
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() => controller.photos.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: controller.isUploading.value
                  ? null
                  : controller.pickAndUpload,
              backgroundColor: _accent,
              icon: const Icon(Icons.add_photo_alternate_outlined,
                  color: Colors.white),
              label: Text('add_photos'.tr,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _photoTile(String url, int id) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                  child: Icon(Icons.broken_image_outlined,
                      color: _muted, size: 36)),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => _confirmDelete(id),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(int id) {
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: 'delete_photo'.tr,
      titleStyle: const TextStyle(
          color: _navy, fontWeight: FontWeight.w700),
      middleText: 'delete_photo_confirm'.tr,
      middleTextStyle: const TextStyle(color: _muted),
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: _muted,
      onConfirm: () {
        Get.back();
        controller.deletePhoto(id);
      },
    );
  }
}
