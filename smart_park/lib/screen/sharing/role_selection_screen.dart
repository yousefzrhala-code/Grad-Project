import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06),
              child: Column(
                children: [
                  SizedBox(height: h * 0.05),
                  Container(
                    width: w * 0.2 > 82 ? 82 : w * 0.2,
                    height: w * 0.2 > 82 ? 82 : w * 0.2,
                    decoration: BoxDecoration(
        color: Colors.white,
                      borderRadius: BorderRadius.circular(w * 0.06),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2EC4B6),
                          Color(0xFF4DA3FF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B1F45).withOpacity(0.05),
                          blurRadius: 26,
                          offset: Offset(0, h * 0.014),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_parking_rounded,
                      color: const Color(0xFF0B1F45),
                      size: w * 0.1,
                    ),
                  ),
                  SizedBox(height: h * 0.03),
                  Text(
                    'Choose Your Role'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF0B1F45),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Text(
                    'Select how you want to use Smart Park.'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5C6B82),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: h * 0.05),
                  _RoleCard(
                    title: 'Car Owner'.tr,
                    subtitle: 'Find garages, check availability, and reserve your parking spot.'.tr,
                    icon: Icons.directions_car_filled_rounded,
                    onTap: () {
                      Get.to(() => const SignupScreen(role: 'car_owner'));
                    },
                  ),
                  SizedBox(height: h * 0.02),
                  _RoleCard(
                    title: 'Garage Owner'.tr,
                    subtitle: 'Manage your garage, parking spaces, and reservations.'.tr,
                    icon: Icons.garage_rounded,
                    onTap: () {
                      Get.to(() => const SignupScreen(role: 'garage_owner'));
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const LoginScreen());
                    },
                    child: Text(
                      'Already have an account? Login'.tr,
                      style: TextStyle(
              color: Color(0xFF5C6B82),
                        fontWeight: FontWeight.w700,
                        fontSize: w * 0.038 > 16 ? 16 : w * 0.038,
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                ],
              ),
            ),
          ),
        ),
      )
    ;
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(w * 0.05),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: h * 0.025,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(w * 0.05),
          border: Border.all(
            color: const Color(0xFFE2E7F0),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B1F45).withOpacity(0.06),
              blurRadius: 18,
              offset: Offset(0, h * 0.008),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: w * 0.16,
              height: w * 0.16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(w * 0.04),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2EC4B6),
                    Color(0xFF00A6FF),
                  ],
                ),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0B1F45),
                size: w * 0.08,
              ),
            ),
            SizedBox(width: w * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0B1F45),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: h * 0.006),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5C6B82),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: w * 0.02),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF5C6B82),
              size: w * 0.045,
            ),
          ],
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