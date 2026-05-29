import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_park/screen/sharing/contact_us_screen.dart';
import 'package:smart_park/screen/sharing/terms_and_conditions_screen.dart';
import '../../controller/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Settings'.tr,
          style: const TextStyle(
            color: Color(0xFF0B1F45),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B1F45)),
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
              child: CircularProgressIndicator(color: Color(0xFF2EC4B6)),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(w * 0.05),
              child: Column(
                children: [
                  // Profile card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(w * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: const Color(0xFFE2E7F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B1F45).withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: w * 0.17,
                          height: w * 0.17,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2EC4B6).withOpacity(0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF2EC4B6),
                            size: 36,
                          ),
                        ),
                        SizedBox(width: w * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Text(
                                    controller.name.value.isEmpty
                                        ? 'User'.tr
                                        : controller.name.value,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF0B1F45),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )),
                              const SizedBox(height: 4),
                              Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2EC4B6)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      controller.role.value,
                                      style: const TextStyle(
                                        color: Color(0xFF2EC4B6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.025),

                  _settingTile(
                    icon: Icons.person_outline,
                    title: 'My Information'.tr,
                    subtitle: 'View your account details'.tr,
                    onTap: () => _showUserInfo(context),
                  ),

                  _settingTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password'.tr,
                    subtitle: 'Update your account password'.tr,
                    onTap: () => _showChangePasswordDialog(context),
                  ),

                  _settingTile(
                    icon: Icons.language_outlined,
                    title: 'Language'.tr,
                    subtitle: 'Change app language'.tr,
                    onTap: () => _showLanguageBottomSheet(context),
                  ),

                  _settingTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions'.tr,
                    subtitle: 'Read app terms and conditions'.tr,
                    onTap: () => Get.to(() => const TermsAndConditionsScreen()),
                  ),

                  _settingTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Contact Support'.tr,
                    subtitle: 'Get help from support team'.tr,
                    onTap: () => Get.to(() => ContactUsScreen()),
                  ),

                  _settingTile(
                    icon: Icons.logout,
                    title: 'Logout'.tr,
                    subtitle: 'Sign out from your account'.tr,
                    iconColor: Colors.redAccent,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF2EC4B6),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E7F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B1F45).withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0B1F45),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF5C6B82),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFBCC5D3),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── MY INFORMATION bottom sheet ───────────────────────────────────────────
  void _showUserInfo(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E7F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2EC4B6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF2EC4B6),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'My Information'.tr,
                        style: const TextStyle(
                          color: Color(0xFF0B1F45),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: Color(0xFFE2E7F0)),
                ),

                // Info rows
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      _infoCard(
                        icon: Icons.person_rounded,
                        label: 'Name'.tr,
                        value: controller.name.value,
                      ),
                      _infoCard(
                        icon: Icons.email_outlined,
                        label: 'Email'.tr,
                        value: controller.email.value,
                      ),
                      _infoCard(
                        icon: Icons.phone_outlined,
                        label: 'Phone'.tr,
                        value: controller.phone.value,
                      ),
                      _infoCard(
                        icon: Icons.work_outline_rounded,
                        label: 'Role'.tr,
                        value: controller.role.value,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                // Close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F7FB),
                        foregroundColor: const Color(0xFF5C6B82),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE2E7F0)),
                        ),
                      ),
                      child: Text(
                        'close'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
      isScrollControlled: true,
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E7F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2EC4B6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2EC4B6), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF5C6B82),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    color: Color(0xFF0B1F45),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CHANGE PASSWORD dialog ─────────────────────────────────────────────────
  void _showChangePasswordDialog(BuildContext context) {
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          bool hideOld  = true;
          bool hideNew  = true;
          bool hideConf = true;
          return StatefulBuilder(
            builder: (context, setSt) {
              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF2EC4B6).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.lock_outline,
                                color: Color(0xFF2EC4B6), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Change Password'.tr,
                            style: const TextStyle(
                              color: Color(0xFF0B1F45),
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _dialogField(
                        ctrl: controller.currentPasswordController,
                        label: 'Current Password'.tr,
                        obscure: hideOld,
                        onToggle: () => setSt(() => hideOld = !hideOld),
                      ),
                      const SizedBox(height: 12),
                      _dialogField(
                        ctrl: controller.newPasswordController,
                        label: 'New Password'.tr,
                        obscure: hideNew,
                        onToggle: () => setSt(() => hideNew = !hideNew),
                      ),
                      const SizedBox(height: 12),
                      _dialogField(
                        ctrl: controller.confirmPasswordController,
                        label: 'Confirm Password'.tr,
                        obscure: hideConf,
                        onToggle: () => setSt(() => hideConf = !hideConf),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2EC4B6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            'Save'.tr,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController ctrl,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFF0B1F45)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF5C6B82)),
        filled: true,
        fillColor: const Color(0xFFF5F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2EC4B6), width: 1.2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF5C6B82),
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  // ─── LOGOUT confirmation ────────────────────────────────────────────────────
  void _confirmLogout(BuildContext context) {
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: 'logout_confirm_title'.tr,
      titleStyle: const TextStyle(
          color: Color(0xFF0B1F45), fontWeight: FontWeight.w800),
      middleText: 'logout_confirm_message'.tr,
      middleTextStyle:
          const TextStyle(color: Color(0xFF5C6B82), height: 1.5),
      textConfirm: 'Logout'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      cancelTextColor: const Color(0xFF5C6B82),
      onConfirm: () {
        Get.back();
        controller.logout();
      },
    );
  }

  // ─── LANGUAGE bottom sheet ──────────────────────────────────────────────────
  void _showLanguageBottomSheet(BuildContext context) {
    final currentLang = Get.locale?.languageCode ?? 'en';

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E7F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2EC4B6).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.language_outlined,
                      color: Color(0xFF2EC4B6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Language'.tr,
                    style: const TextStyle(
                      color: Color(0xFF0B1F45),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: Color(0xFFE2E7F0)),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                children: [
                  _languageTile(
                    langCode: 'en',
                    flag: '🇬🇧',
                    name: 'English',
                    nativeName: 'English',
                    badge: 'EN',
                    isSelected: currentLang == 'en',
                    onTap: () {
                      Get.back();
                      controller.changeLanguage('en');
                    },
                  ),
                  const SizedBox(height: 12),
                  _languageTile(
                    langCode: 'ar',
                    flag: '🇯🇴',
                    name: 'Arabic'.tr,
                    nativeName: 'العربية',
                    badge: 'ع',
                    isSelected: currentLang == 'ar',
                    onTap: () {
                      Get.back();
                      controller.changeLanguage('ar');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _languageTile({
    required String langCode,
    required String flag,
    required String name,
    required String nativeName,
    required String badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2EC4B6).withOpacity(0.08)
              : const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2EC4B6)
                : const Color(0xFFE2E7F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag + badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E7F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B1F45).withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(flag, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  right: -6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2EC4B6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2EC4B6)
                          : const Color(0xFF0B1F45),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nativeName,
                    style: const TextStyle(
                      color: Color(0xFF5C6B82),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2EC4B6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E7F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.circle_outlined,
                  color: Color(0xFFBCC5D3),
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
