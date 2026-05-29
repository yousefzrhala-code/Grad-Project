import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_park/controller/auth_controller.dart';
import 'package:smart_park/controller/notifications_controller.dart';
import 'package:smart_park/screen/car_owner/settings_screen.dart';
import 'package:smart_park/screen/sharing/contact_us_screen.dart';
import 'package:smart_park/screen/sharing/login_screen.dart';
import 'package:smart_park/screen/sharing/notifications_screen.dart';
import 'FavoriteGaragesScreen.dart';
import 'find_garages_screen.dart';
import 'my_reservations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthController authController;
  late final NotificationsController _notifCtrl;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Smart Park'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B1F45),
          ),
        ),
        actions: [
          // ── Notification bell with live unread badge ──────────────────
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
                    // refresh badge when returning from notifications
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
                      constraints:
                          const BoxConstraints(minWidth: 17, minHeight: 17),
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
            icon: const Icon(Icons.settings_outlined,
                color: Color(0xFF0B1F45)),
            onPressed: () => Get.to(() => SettingsScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: Color(0xFF0B1F45)),
            onPressed: () async {
              await authController.logout();
              Get.offAll(() => const LoginScreen());
            },
          ),
        ],
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.05,
              vertical: h * 0.015,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(
                  w: w,
                  h: h,
                  theme: theme,
                  authController: authController,
                ),
                SizedBox(height: h * 0.025),

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
                  childAspectRatio: 0.88,
                  children: [
                    _ActionButton(
                      icon: Icons.local_parking_outlined,
                      title: 'Make Reservation'.tr,
                      subtitle: 'Find a garage and reserve a parking spot'.tr,
                      onTap: () {
                        Get.to(() => FindGaragesScreen());
                      },
                    ),
                    _ActionButton(
                      icon: Icons.history_rounded,
                      title: 'Previous Reservations'.tr,
                      subtitle: 'View your old and current reservations'.tr,
                      onTap: () {
                        Get.to(() => MyReservationsScreen());
                      },
                    ),
                    _ActionButton(
                      icon: Icons.favorite_border_rounded,
                      title: 'Favorite Garages'.tr,
                      subtitle: 'See your saved favorite garages'.tr,
                      onTap: () {
                        Get.to(() => FavoriteGaragesScreen());
                      },
                    ),
                    _ActionButton(
                      icon: Icons.support_agent_outlined,
                      title: 'Contact Us'.tr,
                      subtitle: 'Send a message to support'.tr,
                      onTap: () {
                        Get.to(() => ContactUsScreen());
                      },
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

  Widget _buildWelcomeCard({
    required double w,
    required double h,
    required ThemeData theme,
    required AuthController authController,
  }) {
    final userName = authController.currentUser.value?.name ?? 'User'.tr;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.055),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2EC4B6).withOpacity(0.24),
            const Color(0xFFE2E7F0),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFE2E7F0),
        ),
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
            width: w * 0.15,
            height: w * 0.15,
            decoration: BoxDecoration(
              color: const Color(0xFF2EC4B6).withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: Color(0xFF2EC4B6),
              size: 32,
            ),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'Welcome'.tr}, $userName',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF0B1F45),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: h * 0.008),
                Text(
                  'Reserve your parking spot quickly and manage your activities easily.'.tr,
                  style: TextStyle(
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
            padding: EdgeInsets.all(w * 0.035),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(w * 0.022),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2EC4B6).withOpacity(0.16),
                    borderRadius: BorderRadius.circular(w * 0.03),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2EC4B6),
                    size: w * 0.065,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
              color: Color(0xFF0B1F45),
                        fontWeight: FontWeight.w800,
                        fontSize: w * 0.038 > 16 ? 16 : w * 0.038,
                      ),
                    ),
                    SizedBox(height: w * 0.012),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
              color: Color(0xFF5C6B82),
                        fontSize: w * 0.029 > 12 ? 12 : w * 0.029,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Open'.tr,
                      style: TextStyle(
              color: Color(0xFF2EC4B6),
                        fontWeight: FontWeight.w700,
                        fontSize: w * 0.03 > 12 ? 12 : w * 0.03,
                      ),
                    ),
                    SizedBox(width: w * 0.012),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF2EC4B6),
                      size: 12,
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