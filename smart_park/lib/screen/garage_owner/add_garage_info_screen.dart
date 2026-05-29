import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_park/controller/garage_controller.dart';
import 'package:smart_park/screen/garage_owner/garage_owner_home_screen.dart';

class AddGarageInfoScreen extends StatefulWidget {
  const AddGarageInfoScreen({super.key});

  @override
  State<AddGarageInfoScreen> createState() => _AddGarageInfoScreenState();
}

class _AddGarageInfoScreenState extends State<AddGarageInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _openTimeCtrl = TextEditingController();
  final _closeTimeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final List<String> _cities = [
    'Amman',
    'Zarqa',
    'Irbid',
    'Aqaba',
    'Madaba',
    'Mafraq',
    'Jerash',
    'Karak',
    'Ajloun',
    'Salt',
    'Tafilah',
    "Ma'an",
  ];
  String? _selectedCity;
  final GarageController garageController = Get.put(GarageController());

  bool _loading = false;
  String? _errorMsg;

  Future<void> _saveGarage() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    final res = await garageController.addGarage(
      name: _nameCtrl.text.trim(),
      city: _selectedCity ?? '',
      address: _addressCtrl.text.trim(),
      pricePerHour: _priceCtrl.text.trim(),
      capacity: _capacityCtrl.text.trim(),
      openTime: _openTimeCtrl.text.trim(),
      closeTime: _closeTimeCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    if (res['status'] == true) {
      Get.offAll(() => const GarageOwnerHomeScreen());
    } else {
      setState(() {
        _errorMsg =
            res['message']?.toString() ?? 'Failed to add garage information'.tr;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
    _capacityCtrl.dispose();
    _openTimeCtrl.dispose();
    _closeTimeCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final theme = Theme.of(context);

    final horizontalPadding = w * 0.06;
    final cardRadius = w * 0.05;
    final fieldGap = h * 0.016;
    final sectionGap = h * 0.024;
    final buttonHeight = h * 0.065;

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  SizedBox(height: h * 0.03),
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
                      Icons.garage_rounded,
                      color: const Color(0xFF0B1F45),
                      size: w * 0.1,
                    ),
                  ),
                  SizedBox(height: h * 0.025),
                  Text(
                    'Add Garage Information'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF0B1F45),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Text(
                    'Complete your garage profile to make it visible for car owners.'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5C6B82),
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: h * 0.03),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.05,
                      vertical: h * 0.025,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(
                        color: const Color(0xFFE2E7F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B1F45).withOpacity(0.06),
                          blurRadius: 24,
                          offset: Offset(0, h * 0.012),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _PremiumTextField(
                            controller: _nameCtrl,
                            label: 'Garage Name'.tr,
                            hint: 'Enter garage name'.tr,
                            prefixIcon: Icons.home_work_outlined,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Garage name is required'.tr
                                : null,
                          ),
                          SizedBox(height: fieldGap),
                        DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: InputDecoration(
                            labelText: 'City'.tr,
                            labelStyle: TextStyle(
              color: Color(0xFF5C6B82),
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                              color: const Color(0xFF5C6B82),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F7FB),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: w * 0.035,
                              vertical: h * 0.018,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(w * 0.045),
                              borderSide: BorderSide(color: const Color(0xFFE2E7F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(w * 0.045),
                              borderSide: const BorderSide(color: Color(0xFF2EC4B6), width: 1.2),
                            ),
                          ),
                          dropdownColor: Colors.white,
                          items: _cities.map((city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city, style: const TextStyle(
              color: Color(0xFF0B1F45))),
                            );
                          }).toList(),
                          validator: (v) => v == null || v.isEmpty ? 'City is required'.tr : null,
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                            });
                          },
                        ),

                          SizedBox(height: fieldGap),
                          _PremiumTextField(
                            controller: _addressCtrl,
                            label: 'Address'.tr,
                            hint: 'Enter address'.tr,
                            prefixIcon: Icons.place_outlined,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Address is required'.tr
                                : null,
                          ),
                          SizedBox(height: fieldGap),
                          Row(
                            children: [
                              Expanded(
                                child: _PremiumTextField(
                                  controller: _priceCtrl,
                                  label: 'Price Per Hour'.tr,
                                  hint: '0.00'.tr,
                                  prefixIcon: Icons.attach_money_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Price is required'.tr
                                      : null,
                                ),
                              ),
                              SizedBox(width: w * 0.03),
                              Expanded(
                                child: _PremiumTextField(
                                  controller: _capacityCtrl,
                                  label: 'Capacity'.tr,
                                  hint: '0'.tr,
                                  prefixIcon: Icons.local_parking_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Capacity is required'.tr
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: fieldGap),
                          Row(
                            children: [
                              Expanded(
                                child: _PremiumTextField(
                                  controller: _openTimeCtrl,
                                  label: 'Open Time'.tr,
                                  hint: '08:00'.tr,
                                  prefixIcon: Icons.schedule_outlined,
                                ),
                              ),
                              SizedBox(width: w * 0.03),
                              Expanded(
                                child: _PremiumTextField(
                                  controller: _closeTimeCtrl,
                                  label: 'Close Time'.tr,
                                  hint: '22:00'.tr,
                                  prefixIcon: Icons.access_time_outlined,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: fieldGap),
                          _PremiumTextField(
                            controller: _descriptionCtrl,
                            label: 'Description'.tr,
                            hint: 'Write a short description'.tr,
                            prefixIcon: Icons.notes_outlined,
                            maxLines: 4,
                          ),
                          if (_errorMsg != null) ...[
                            SizedBox(height: sectionGap),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.035,
                                vertical: h * 0.014,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.14),
                                borderRadius: BorderRadius.circular(w * 0.04),
                                border: Border.all(
                                  color: const Color(0xFFEF4444).withOpacity(0.35),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFFFF6B6B),
                                  ),
                                  SizedBox(width: w * 0.025),
                                  Expanded(
                                    child: Text(
                                      _errorMsg!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF0B1F45),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: sectionGap),
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
        color: Colors.white,
                                borderRadius: BorderRadius.circular(w * 0.045),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF2EC4B6),
                                    Color(0xFF00A6FF),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00A6FF).withOpacity(0.22),
                                    blurRadius: 22,
                                    offset: Offset(0, h * 0.012),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _loading ? null : _saveGarage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(w * 0.045),
                                  ),
                                ),
                                child: _loading
                                    ? SizedBox(
                                  width: w * 0.06,
                                  height: w * 0.06,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: const Color(0xFF0B1F45),
                                  ),
                                )
                                    : Text(
                                  'Save Garage Information'.tr,
                                  style: TextStyle(
              color: Color(0xFF0B1F45),
                                    fontWeight: FontWeight.w800,
                                    fontSize: w * 0.043 > 18 ? 18 : w * 0.043,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
              color: Color(0xFF0B1F45),
        fontSize: w * 0.038 > 16 ? 16 : w * 0.038,
        fontWeight: FontWeight.w500,
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
              color: Color(0xFF5C6B82),
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFADB5BD),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? h * 0.06 : 0),
          child: Icon(
            prefixIcon,
            color: const Color(0xFF5C6B82),
            size: w * 0.055,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F7FB),
        contentPadding: EdgeInsets.symmetric(
          horizontal: w * 0.035,
          vertical: h * 0.018,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.045),
          borderSide: BorderSide(
            color: const Color(0xFFE2E7F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.045),
          borderSide: const BorderSide(
            color: Color(0xFF2EC4B6),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.045),
          borderSide: BorderSide(
            color: Colors.red.withOpacity(0.65),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.045),
          borderSide: BorderSide(
            color: Colors.red.withOpacity(0.85),
          ),
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF0B1F45),
          fontSize: w * 0.031 > 13 ? 13 : w * 0.031,
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