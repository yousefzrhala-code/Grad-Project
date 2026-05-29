import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/contact_us_controller.dart';

class ContactUsScreen extends StatelessWidget {
  ContactUsScreen({super.key});

  final ContactUsController controller = Get.put(ContactUsController());

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Contact Us'.tr,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(w * 0.05),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
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
                          const Color(0xFF2EC4B6).withOpacity(0.22),
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
                            Icons.support_agent_outlined,
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
                                'We are here to help'.tr,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF0B1F45),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: h * 0.008),
                              Text(
                                'Send us your question, issue, or suggestion and we will get back to you.'.tr,
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
                  ),
                  SizedBox(height: h * 0.025),
                  Container(
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
                      children: [
                        _buildField(
                          controller: controller.nameController,
                          label: 'Name'.tr,
                          icon: Icons.person_outline,
                        ),
                        _buildField(
                          controller: controller.emailController,
                          label: 'Email'.tr,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildField(
                          controller: controller.phoneController,
                          label: 'Phone'.tr,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildField(
                          controller: controller.subjectController,
                          label: 'Subject'.tr,
                          icon: Icons.title_outlined,
                        ),
                        _buildField(
                          controller: controller.messageController,
                          label: 'Message'.tr,
                          icon: Icons.message_outlined,
                          maxLines: 5,
                        ),
                        SizedBox(height: h * 0.01),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: Obx(
                                () => ElevatedButton.icon(
                              onPressed: controller.isSending.value
                                  ? null
                                  : controller.sendMessage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2EC4B6),
                                foregroundColor: const Color(0xFF0B1F45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: controller.isSending.value
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: const Color(0xFF0B1F45),
                                ),
                              )
                                  : const Icon(Icons.send_rounded),
                              label: Text(
                                controller.isSending.value
                                    ? 'Sending...'.tr
                                    : 'Send Message'.tr,
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
                  SizedBox(height: h * 0.025),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(w * 0.045),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFE2E7F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF2EC4B6),
                        ),
                        SizedBox(width: w * 0.03),
                        Expanded(
                          child: Text(
                            'Our support team reviews messages as soon as possible.'.tr,
                            style: TextStyle(
              color: Color(0xFF5C6B82),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Required'.tr;
          }
          return null;
        },
        style: const TextStyle(
              color: Color(0xFF0B1F45)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Color(0xFF5C6B82)),
          prefixIcon: Icon(icon, color: const Color(0xFF2EC4B6)),
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
    );
  }
}