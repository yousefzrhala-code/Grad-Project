import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_park/controller/auth_controller.dart';
import 'package:smart_park/controller/garage_controller.dart';
import 'package:smart_park/controller/notifications_controller.dart';
import 'package:smart_park/screen/garage_owner/add_garage_info_screen.dart';
import 'package:smart_park/screen/garage_owner/my_reservation.dart';
import 'package:smart_park/screen/garage_owner/statistics_screen.dart';
import 'package:smart_park/screen/sharing/login_screen.dart';
import 'package:smart_park/screen/sharing/notifications_screen.dart';
import 'package:smart_park/screen/garage_owner/settings_screen.dart';
import 'package:smart_park/screen/garage_owner/update_availability_screen.dart';

import 'edit_garage_screen.dart';
import 'garage_photos_screen.dart';
import 'garage_services_screen.dart';

class GarageOwnerHomeScreen extends StatefulWidget {
  const GarageOwnerHomeScreen({super.key});
  @override
  State<GarageOwnerHomeScreen> createState() => _GarageOwnerHomeScreenState();
}

class _GarageOwnerHomeScreenState extends State<GarageOwnerHomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final GarageController garageController = Get.put(GarageController());
  late final NotificationsController _notifCtrl;

  @override
  void initState() {
    super.initState();
    garageController.getMyGarage();
    _notifCtrl = Get.put(NotificationsController(), tag: 'notif');
    _notifCtrl.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: const Color(0xFF0B1F45)),
          title: Text(
            'Garage Owner Home'.tr,
            style: const TextStyle(
              color: Color(0xFF0B1F45),
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            // ── Notification bell with live unread badge ──────────────
            Obx(() {
              final count = _notifCtrl.unreadCount.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Color(0xFF0B1F45)),
                    onPressed: () async {
                      await Get.to(() => const NotificationsScreen());
                      _notifCtrl.fetchNotifications();
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                            minWidth: 17, minHeight: 17),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }),
            IconButton(
              onPressed: () => Get.to(() => SettingsScreen()),
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF0B1F45),
              ),
            ),
            IconButton(
              onPressed: () async {
                await authController.logout();
                Get.offAll(() => const LoginScreen());
              },
              icon: const Icon(
                Icons.logout,
                color: Color(0xFF0B1F45),
              ),
            ),
          ],
        ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FB),
              Colors.white,
              Color(0xFFEFF3F8),
            ],
          ),
        ),
        child: SafeArea(
            child: Obx(() {
              if (garageController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2EC4B6)),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(w * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(w * 0.055),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2EC4B6).withOpacity(0.18),
                            const Color(0xFFE2E7F0),
                          ],
                        ),
                        border: Border.all(color: const Color(0xFFE2E7F0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B1F45).withOpacity(0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: w * 0.14,
                            height: w * 0.14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2EC4B6).withOpacity(0.16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.garage_outlined,
                                color: Color(0xFF2EC4B6), size: 30),
                          ),
                          SizedBox(width: w * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${'Welcome'.tr}, ${authController.currentUser.value?.name ?? ''}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF0B1F45),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: h * 0.008),
                                Text(
                                  'Manage your garage and reservations from here.'.tr,
                                  style: const TextStyle(
                                    color: Color(0xFF5C6B82),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.025),
                    if (!garageController.hasGarage.value)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(w * 0.045),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(w * 0.05),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.38),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.orange.shade300,
                                  size: w * 0.07,
                                ),
                                SizedBox(width: w * 0.025),
                                Expanded(
                                  child: Text(
                                    'You have not added your garage information yet.'.tr,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF0B1F45),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: h * 0.012),
                            Text(
                              'Please add your garage information to make it visible for car owners.'.tr,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF5C6B82),
                                height: 1.45,
                              ),
                            ),
                            SizedBox(height: h * 0.02),
                            SizedBox(
                              width: double.infinity,
                              height: h * 0.06,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.to(() => const AddGarageInfoScreen());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(w * 0.04),
                                  ),
                                ),
                                child: Text(
                                  'Add Garage Information'.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0B1F45),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (garageController.hasGarage.value) ...[
                      Text(
                        'Quick Actions'.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF0B1F45),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: h * 0.015),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: w * 0.04,
                        mainAxisSpacing: h * 0.02,
                        childAspectRatio: 0.85,
                        children: [
                          _ActionButton(
                            icon: Icons.edit_outlined,
                            title: 'Edit Garage'.tr,
                            subtitle: 'Update your garage details'.tr,
                            onTap: () {
                              Get.to(() => EditGarageScreen());

                            },
                          ),
                          _ActionButton(
                            icon: Icons.event_note_outlined,
                            title: 'Reservations'.tr,
                            subtitle: 'View booking requests'.tr,
                            onTap: () {
                              Get.to(() =>  MyReservationScreen());
                            },
                          ),
                          _ActionButton(
                            icon: Icons.update_outlined,
                            title: 'Update Availability'.tr,
                            subtitle: 'Manage available spaces'.tr,
                            onTap: () {
                              Get.to(() => UpdateAvailabilityScreen());
                            },
                          ),
                          _ActionButton(
                            icon: Icons.bar_chart_outlined,
                            title: 'Statistics'.tr,
                            subtitle: 'Check garage performance'.tr,
                            onTap: () {
                              Get.to(() => StatisticsScreen());
                            },
                          ),
                          _ActionButton(
                            icon: Icons.photo_library_outlined,
                            title: 'garage_photos'.tr,
                            subtitle: 'manage_photos_subtitle'.tr,
                            onTap: () {
                              Get.to(() => GaragePhotosScreen());
                            },
                          ),
                          _ActionButton(
                            icon: Icons.miscellaneous_services_outlined,
                            title: 'garage_services'.tr,
                            subtitle: 'manage_services_subtitle'.tr,
                            onTap: () {
                              Get.to(() => GarageServicesScreen());
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ),
      );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(bottom: w * 0.03),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFF5C6B82),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
              color: Color(0xFF0B1F45),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(w * 0.05),
        child: Ink(
          decoration: BoxDecoration(
        color: Colors.white,
            borderRadius: BorderRadius.circular(w * 0.05),
            border: Border.all(
              color: const Color(0xFFE2E7F0),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B1F45).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(w * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(w * 0.025),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2EC4B6).withOpacity(0.16),
                    borderRadius: BorderRadius.circular(w * 0.03),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2EC4B6),
                    size: w * 0.07,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
              color: Color(0xFF0B1F45),
                    fontWeight: FontWeight.w800,
                    fontSize: w * 0.04 > 17 ? 17 : w * 0.04,
                  ),
                ),
                SizedBox(height: w * 0.015),
                Text(
                  subtitle,
                  style: TextStyle(
              color: Color(0xFF5C6B82),
                    fontSize: w * 0.031 > 13 ? 13 : w * 0.031,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: w * 0.03),
                Row(
                  children: [
                    Text(
                      'Open'.tr,
                      style: TextStyle(
              color: Color(0xFF2EC4B6),
                        fontWeight: FontWeight.w700,
                        fontSize: w * 0.032 > 13 ? 13 : w * 0.032,
                      ),
                    ),
                    SizedBox(width: w * 0.015),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF2EC4B6),
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}