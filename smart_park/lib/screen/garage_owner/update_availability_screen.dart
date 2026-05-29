import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/garage_availability_controller.dart';

class UpdateAvailabilityScreen extends StatelessWidget {
  UpdateAvailabilityScreen({super.key});

  final GarageAvailabilityController controller =
  Get.put(GarageAvailabilityController());

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Update Availability'.tr,
          style: const TextStyle(
              color: Color(0xFF0B1F45),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: const Color(0xFF0B1F45)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2EC4B6),
              ),
            );
          }

          if (controller.accessDenied.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.08),
                child: Container(
                  padding: EdgeInsets.all(w * 0.06),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E7F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B1F45).withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: const Color(0xFF0B1F45),
                        size: 50,
                      ),
                      SizedBox(height: h * 0.02),
                      Text(
                        'Access Denied'.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF0B1F45),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
              color: Color(0xFF5C6B82),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (!controller.hasGarage.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.08),
                child: Container(
                  padding: EdgeInsets.all(w * 0.06),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E7F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B1F45).withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.garage_outlined,
                        color: const Color(0xFF0B1F45),
                        size: 50,
                      ),
                      SizedBox(height: h * 0.02),
                      Text(
                        'No Garage Found'.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF0B1F45),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Text(
                        controller.errorMessage.value.isEmpty
                            ? 'Garage information not found'.tr
                            : controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
              color: Color(0xFF5C6B82),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(w * 0.05),
              child: Form(
                key: controller.formKey,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(w * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Garage Availability'.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF0B1F45),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Text(
                        'Update your current available parking spots and garage status'.tr,
                        style: TextStyle(
              color: Color(0xFF5C6B82),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: h * 0.03),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(w * 0.04),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2EC4B6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2EC4B6).withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_parking_outlined,
                              color: Color(0xFF2EC4B6),
                              size: 28,
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Garage Capacity'.tr,
                                    style: TextStyle(
              color: Color(0xFF5C6B82),
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: h * 0.004),
                                  Obx(
                                        () => Text(
                                      '${controller.capacity.value}',
                                      style: const TextStyle(
              color: Color(0xFF0B1F45),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.025),

                      TextFormField(
                        controller: controller.availableSpotsController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Available spots is required'.tr;
                          }

                          final number = int.tryParse(value.trim());
                          if (number == null) {
                            return 'Enter a valid number'.tr;
                          }

                          if (number < 0) {
                            return 'Available spots cannot be negative'.tr;
                          }

                          if (number > controller.capacity.value) {
                            return 'Available spots cannot be greater than capacity'.tr;
                          }

                          return null;
                        },
                        style: const TextStyle(
              color: Color(0xFF0B1F45)),
                        decoration: InputDecoration(
                          labelText: 'Available Spots'.tr,
                          labelStyle: TextStyle(
              color: Color(0xFF5C6B82),
                          ),
                          prefixIcon: const Icon(
                            Icons.event_available_outlined,
                            color: Color(0xFF2EC4B6),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: const Color(0xFFE2E7F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFF2EC4B6),
                              width: 1.2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.025),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.04,
                          vertical: h * 0.012,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE2E7F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.toggle_on_outlined,
                              color: Color(0xFF2EC4B6),
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: Text(
                                'Garage Active'.tr,
                                style: const TextStyle(
              color: Color(0xFF0B1F45),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Obx(
                                  () => Switch(
                                value: controller.isActive.value,
                                onChanged: (value) {
                                  controller.isActive.value = value;
                                },
                                activeColor: const Color(0xFF2EC4B6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.035),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Obx(
                              () => ElevatedButton.icon(
                            onPressed: controller.isSaving.value
                                ? null
                                : controller.updateAvailability,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2EC4B6),
                              foregroundColor: const Color(0xFF0B1F45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: controller.isSaving.value
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: const Color(0xFF0B1F45),
                              ),
                            )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              controller.isSaving.value
                                  ? 'Saving...'.tr
                                  : 'Update Availability'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}