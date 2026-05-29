import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final sections = [
      {
        'title': 'Introduction'.tr,
        'content':
        'Welcome to Smart Park. By using this application, you agree to comply with and be bound by these terms and conditions.'.tr,
      },
      {
        'title': 'User Accounts'.tr,
        'content':
        'You must provide accurate information. You are responsible for your account and all activities under it.'.tr,
      },
      {
        'title': 'Service Description'.tr,
        'content':
        'Smart Park allows users to search, reserve parking, and manage garages.'.tr,
      },
      {
        'title': 'Reservations'.tr,
        'content':
        'Reservations depend on availability. Users must respect booking time.'.tr,
      },
      {
        'title': 'Payments'.tr,
        'content':
        'Prices are set by garage owners. Payments must be completed properly.'.tr,
      },
      {
        'title': 'Garage Owner Responsibilities'.tr,
        'content':
        'Garage owners must provide accurate data and update availability.'.tr,
      },
      {
        'title': 'Prohibited Use'.tr,
        'content':
        'Users must not misuse the app or perform illegal activities.'.tr,
      },
      {
        'title': 'Account Suspension'.tr,
        'content':
        'We may suspend accounts that violate the terms.'.tr,
      },
      {
        'title': 'Limitation of Liability'.tr,
        'content':
        'Smart Park is not responsible for damages or losses in parking locations.'.tr,
      },
      {
        'title': 'Privacy'.tr,
        'content':
        'Your data is handled securely and respectfully.'.tr,
      },
      {
        'title': 'Changes to Terms'.tr,
        'content':
        'We may update terms anytime. Continued use means acceptance.'.tr,
      },
      {
        'title': 'Contact'.tr,
        'content': 'Contact support for any questions.'.tr,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Conditions'.tr,
          style: const TextStyle(
            color: Color(0xFF0B1F45),
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.05,
              vertical: h * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopCard(w, h),
                SizedBox(height: h * 0.025),

                ...List.generate(
                  sections.length,
                      (index) => _buildSectionCard(
                    index: index + 1,
                    title: sections[index]['title']!,
                    content: sections[index]['content']!,
                    w: w,
                    h: h,
                  ),
                ),

                SizedBox(height: h * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(double w, double h) {
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
            const Color(0xFF2EC4B6).withOpacity(0.18),
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
            width: w * 0.14,
            height: w * 0.14,
            decoration: BoxDecoration(
              color: const Color(0xFF2EC4B6).withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF2EC4B6),
              size: 30,
            ),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Park Terms'.tr,
                  style: TextStyle(
                    color: const Color(0xFF0B1F45),
                    fontSize: w * 0.05 > 21 ? 21 : w * 0.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: h * 0.008),
                Text(
                  'Please read these terms carefully before using the application.'.tr,
                  style: TextStyle(
                    color: const Color(0xFF5C6B82),
                    fontSize: w * 0.034 > 14 ? 14 : w * 0.034,
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

  Widget _buildSectionCard({
    required int index,
    required String title,
    required String content,
    required double w,
    required double h,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.018),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(w * 0.045),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE2E7F0),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B1F45).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: w * 0.1,
              height: w * 0.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2EC4B6).withOpacity(0.14),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: const Color(0xFF2EC4B6),
                    fontWeight: FontWeight.w800,
                    fontSize: w * 0.038 > 16 ? 16 : w * 0.038,
                  ),
                ),
              ),
            ),
            SizedBox(width: w * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF0B1F45),
                      fontWeight: FontWeight.w800,
                      fontSize: w * 0.041 > 17 ? 17 : w * 0.041,
                    ),
                  ),
                  SizedBox(height: h * 0.008),
                  Text(
                    content,
                    style: TextStyle(
                      color: const Color(0xFF5C6B82),
                      fontSize: w * 0.033 > 14 ? 14 : w * 0.033,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}