import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/constant_api.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  Rxn<UserModel> currentUser = Rxn<UserModel>();
  RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> saveToken(String tokenValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', tokenValue);
    token.value = tokenValue;
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    currentUser.value = user;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');

    if (userData == null || userData.isEmpty) return null;

    return UserModel.fromJson(jsonDecode(userData));
  }

  Future<void> loadUserData() async {
    final savedToken = await getToken();
    final savedUser = await getSavedUser();

    token.value = savedToken ?? '';
    currentUser.value = savedUser;
  }

  Future<bool> isLoggedIn() async {
    final savedToken = await getToken();
    return savedToken != null && savedToken.isNotEmpty;
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    token.value = '';
    currentUser.value = null;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final url = Uri.parse('$baseUrl/auth/login');

      final res = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email,
          'password': password,
        },
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final user = UserModel.fromJson(data['user']);
        final userToken = data['token']?.toString() ?? '';
        final hasGarage = data['has_garage'] == true;

        await saveToken(userToken);
        await saveUser(user);

        return {
          'status': true,
          'statusCode': res.statusCode,
          'message': data['message']?.toString() ?? 'Login successful',
          'user': user,
          'token': userToken,
          'has_garage': hasGarage,
        };
      } else {
        errorMessage.value =
            data['message']?.toString() ??
                data['error']?.toString() ??
                'Login failed';

        return {
          'status': false,
          'statusCode': res.statusCode,
          'message': errorMessage.value,
        };
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong';

      return {
        'status': false,
        'statusCode': 500,
        'message': errorMessage.value,
      };
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? carType,
    required String mobile
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final url = Uri.parse('$baseUrl/auth/register');

      final Map<String, String> body = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
        'role': role,
        'mobile' : mobile

      };

      if (role == 'car_owner' && carType != null && carType.isNotEmpty) {
        body['car_type'] = carType;
      }

      final res = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
        body: body,
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 201 || res.statusCode == 200) {
        final user = UserModel.fromJson(data['user']);
        final userToken = data['token']?.toString() ?? '';

        await saveToken(userToken);
        await saveUser(user);

        return {
          'status': true,
          'statusCode': res.statusCode,
          'message': data['message']?.toString() ?? 'Registration successful',
          'user': user,
          'token': userToken,
        };
      } else {
        errorMessage.value =
            data['message']?.toString() ??
                data['error']?.toString() ??
                'Registration failed';

        return {
          'status': false,
          'statusCode': res.statusCode,
          'message': errorMessage.value,
        };
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong';

      return {
        'status': false,
        'statusCode': 500,
        'message': errorMessage.value,
      };
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await clearAuthData();
    Get.offAllNamed('/login');
  }
}