import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_park/controller/auth_controller.dart';
import 'package:smart_park/screen/sharing/login_screen.dart';

class SignupScreen extends StatefulWidget {
  final String role;

  const SignupScreen({super.key, required this.role});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _mobilenum = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMsg;

  late String _selectedRole;
  String? _selectedCarType;
  @override
  void initState() {
    super.initState();
    _selectedRole = widget.role;
  }

  final List<String> _carTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Coupe',
    'Convertible',
    'Pickup',
    'Van',
    'Wagon',
    'Jeep',
    'Motorcycle',
  ];

  final AuthController _authController = Get.put(AuthController());

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    final res = await _authController.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      confirmPassword: _confirmCtrl.text.trim(),
      role: _selectedRole,
      carType: _selectedRole == 'car_owner' ? _selectedCarType : null,
      mobile: _mobilenum.text.trim()
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    if (res['status'] == true &&
        (res['statusCode'] == 201 || res['statusCode'] == 200)) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMsg =
            res['message']?.toString() ??
            'Registration failed. Please try again.'.tr;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final w = size.width;
    final h = size.height;
    final theme = Theme.of(context);

    final horizontalPadding = w * 0.06;
    final topSpace = h * 0.035;
    final headerSpace = h * 0.025;
    final cardRadius = w * 0.05;
    final fieldGap = h * 0.016;
    final sectionGap = h * 0.022;
    final buttonHeight = h * 0.065;
    final logoSize = w * 0.2 > 82 ? 82.0 : w * 0.2;

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
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h - mq.padding.top),
                child: Column(
                  children: [
                    SizedBox(height: topSpace),
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
        color: Colors.white,
                        borderRadius: BorderRadius.circular(w * 0.06),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2EC4B6), Color(0xFF4DA3FF)],
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
                        size: logoSize * 0.52,
                      ),
                    ),
                    SizedBox(height: headerSpace),
                    Text(
                      'Create your account'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF0B1F45),
                        fontWeight: FontWeight.w800,
                        fontSize: w * 0.075 > 32 ? 32 : w * 0.075,
                      ),
                    ),
                    SizedBox(height: h * 0.008),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                      child: Text(
                        'Join Smart Park and reserve your parking spot faster, easier, and smarter.'
                            .tr,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5C6B82),
                          height: 1.5,
                          fontSize: w * 0.038 > 16 ? 16 : w * 0.038,
                        ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign up'.tr,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF0B1F45),
                              fontWeight: FontWeight.w800,
                              fontSize: w * 0.06 > 26 ? 26 : w * 0.06,
                            ),
                          ),
                          SizedBox(height: h * 0.007),
                          Text(
                            'Fill in your details to start exploring garages and booking your next parking spot.'
                                .tr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF5C6B82),
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _PremiumTextField(
                                  controller: _nameCtrl,
                                  label: 'Full Name'.tr,
                                  hint: 'Enter your full name'.tr,
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Name is required'.tr;
                                    }
                                    if (v.trim().length < 3) {
                                      return 'Name must be at least 3 characters'
                                          .tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: fieldGap),
                                _PremiumTextField(
                                  controller: _emailCtrl,
                                  label: 'Email'.tr,
                                  hint: 'Enter your email'.tr,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Email is required'.tr;
                                    }
                                    if (!RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    ).hasMatch(v.trim())) {
                                      return 'Enter a valid email'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: fieldGap),
                                _PremiumTextField(
                                  controller: _mobilenum,
                                  label: 'Mobile',
                                  hint: '',
                                  prefixIcon: Icons.mobile_friendly,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Mobile is required'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: fieldGap),
                                if (_selectedRole == 'car_owner') ...[
                                  SizedBox(height: fieldGap),
                                  _PremiumDropdownField<String>(
                                    label: 'Car Type'.tr,
                                    hint: 'Choose your car type'.tr,
                                    value: _selectedCarType,
                                    items: _carTypes
                                        .map(
                                          (type) => DropdownMenuItem<String>(
                                            value: type,
                                            child: Text(type.tr),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCarType = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (_selectedRole == 'car_owner' &&
                                          (value == null || value.isEmpty)) {
                                        return 'Car type is required'.tr;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                SizedBox(height: fieldGap),
                                _PremiumTextField(
                                  controller: _passwordCtrl,
                                  label: 'Password'.tr,
                                  hint: 'Enter your password'.tr,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF5C6B82),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Password is required'.tr;
                                    }
                                    if (v.length < 6) {
                                      return 'Password must be at least 6 characters'
                                          .tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: fieldGap),
                                _PremiumTextField(
                                  controller: _confirmCtrl,
                                  label: 'Confirm Password'.tr,
                                  hint: 'Re-enter your password'.tr,
                                  prefixIcon: Icons.lock_reset_outlined,
                                  obscureText: _obscureConfirmPassword,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF5C6B82),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Confirm password is required'.tr;
                                    }
                                    if (v != _passwordCtrl.text) {
                                      return 'Passwords do not match'.tr;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (_errorMsg != null) ...[
                            SizedBox(height: h * 0.018),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.035,
                                vertical: h * 0.014,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFEF4444,
                                ).withOpacity(0.14),
                                borderRadius: BorderRadius.circular(w * 0.04),
                                border: Border.all(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.35),
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
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
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
                                    color: const Color(
                                      0xFF00A6FF,
                                    ).withOpacity(0.22),
                                    blurRadius: 22,
                                    offset: Offset(0, h * 0.012),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _loading ? null : _signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      w * 0.045,
                                    ),
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
                                        'Create Account'.tr,
                                        style: TextStyle(
              color: Color(0xFF0B1F45),
                                          fontWeight: FontWeight.w800,
                                          fontSize: w * 0.043 > 18
                                              ? 18
                                              : w * 0.043,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: h * 0.018),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.035,
                              vertical: h * 0.016,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E7F0),
                              borderRadius: BorderRadius.circular(w * 0.04),
                              border: Border.all(
                                color: const Color(0xFFE2E7F0),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.directions_car_outlined,
                                  color: const Color(0xFF5C6B82),
                                  size: w * 0.055,
                                ),
                                SizedBox(width: w * 0.028),
                                Expanded(
                                  child: Text(
                                    'After signup, you can explore garages by city, view prices and availability, and reserve your parking spot in seconds.'
                                        .tr,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF5C6B82),
                                      height: 1.5,
                                      fontSize: w * 0.033 > 14 ? 14 : w * 0.033,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.012),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0B1F45),
                              padding: EdgeInsets.symmetric(vertical: h * 0.01),
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? '.tr,
                                    style: TextStyle(
              color: Color(0xFF5C6B82),
                                      fontSize: w * 0.037 > 15 ? 15 : w * 0.037,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Login'.tr,
                                    style: TextStyle(
              color: Color(0xFF2EC4B6),
                                      fontSize: w * 0.037 > 15 ? 15 : w * 0.037,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.025),
                    Text(
                      '© ${DateTime.now().year} Smart Park'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5C6B82),
                        fontSize: w * 0.032 > 13 ? 13 : w * 0.032,
                      ),
                    ),
                    SizedBox(height: h * 0.02),
                  ],
                ),
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
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
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
        hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF5C6B82),
          size: w * 0.055,
        ),
        suffixIcon: suffixIcon,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.045),
          borderSide: BorderSide(color: Colors.red.withOpacity(0.65)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.045),
          borderSide: BorderSide(color: Colors.red.withOpacity(0.85)),
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF0B1F45),
          fontSize: w * 0.031 > 13 ? 13 : w * 0.031,
        ),
      ),
    );
  }
}

class _PremiumDropdownField<T> extends FormField<T> {
  _PremiumDropdownField({
    super.key,
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required FormFieldValidator<T> validator,
  }) : super(
         initialValue: value,
         validator: validator,
         builder: (FormFieldState<T> state) {
           final w = MediaQuery.of(state.context).size.width;
           final h = MediaQuery.of(state.context).size.height;
           final theme = Theme.of(state.context);

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               DropdownButtonFormField<T>(
                 value: state.value,
                 items: items,
                 onChanged: (val) {
                   state.didChange(val);
                   onChanged(val);
                 },
                 dropdownColor: Colors.white,
                 iconEnabledColor: const Color(0xFF5C6B82),
                 style: TextStyle(
              color: Color(0xFF0B1F45),
                   fontSize: w * 0.038 > 16 ? 16 : w * 0.038,
                   fontWeight: FontWeight.w500,
                 ),
                 decoration: InputDecoration(
                   labelText: label,
                   hintText: hint,
                   labelStyle: TextStyle(
              color: Color(0xFF5C6B82),
                     fontWeight: FontWeight.w600,
                   ),
                   hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
                   prefixIcon: Icon(
                     Icons.directions_car_filled_outlined,
                     color: const Color(0xFF5C6B82),
                     size: w * 0.055,
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
               ),
             ],
           );
         },
       );
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
