import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_park/controller/auth_controller.dart';
import 'package:smart_park/core/localization/translation.dart';
import 'package:smart_park/models/user_model.dart';
import 'package:smart_park/screen/car_owner/home_screen.dart';
import 'package:smart_park/screen/garage_owner/garage_owner_home_screen.dart';
import 'package:smart_park/screen/sharing/login_screen.dart';

import 'controller/find_garages_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('token');
  final savedUserJson = prefs.getString('user');
  final savedLang = prefs.getString('lang') ?? 'en';

  UserModel? savedUser;

  if (savedUserJson != null && savedUserJson.isNotEmpty) {
    savedUser = UserModel.fromJson(jsonDecode(savedUserJson));
  }

  final authController = Get.put(AuthController());
  authController.token.value = savedToken ?? '';
  authController.currentUser.value = savedUser;
  Get.put(FindGaragesController());
  runApp(MyApp(
    token: savedToken,
    savedUser: savedUser,
    savedLang: savedLang,
  ));
}

class MyApp extends StatelessWidget {
  final String? token;
  final UserModel? savedUser;
  final String savedLang;

  const MyApp({
    super.key,
    required this.token,
    required this.savedUser,
    required this.savedLang,
  });

  String getInitialRoute() {
    if (token == null || token!.isEmpty) {
      return '/login';
    }

    if (savedUser == null) {
      return '/login';
    }

    if (savedUser!.role == 'garage_owner') {
      return '/garageHome';
    }

    return '/carHome';
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslation(),
      locale: Locale(savedLang),
      fallbackLocale: const Locale('en'),
      initialRoute: getInitialRoute(),
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/carHome', page: () => HomeScreen()),
        GetPage(
          name: '/garageHome',
          page: () => GarageOwnerHomeScreen(),
        ),
      ],
    );
  }
}