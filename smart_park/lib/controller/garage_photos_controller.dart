import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../constant/constant_api.dart';
import 'auth_controller.dart';

class GaragePhotosController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();

  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  RxList<Map<String, dynamic>> photos = <Map<String, dynamic>>[].obs;

  final ImagePicker _picker = ImagePicker();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  void onInit() {
    fetchPhotos();
    super.onInit();
  }

  Future<void> fetchPhotos() async {
    isLoading.value = true;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/garage/photos'),
        headers: await _headers(),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        photos.value =
            List<Map<String, dynamic>>.from(data['photos'] ?? []);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUpload() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    isUploading.value = true;
    try {
      final token = await _auth.getToken();
      final uri = Uri.parse('$baseUrl/garage/photos');
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json';

      for (final xFile in picked) {
        req.files.add(await http.MultipartFile.fromPath(
          'photos[]',
          xFile.path,
          filename: xFile.name,
        ));
      }

      final streamed = await req.send();
      final body = await streamed.stream.bytesToString();
      final data = jsonDecode(body);

      if (streamed.statusCode == 201) {
        Get.snackbar('success'.tr, 'photos_uploaded_successfully'.tr);
        await fetchPhotos();
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deletePhoto(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/garage/photos/$id'),
        headers: await _headers(),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        photos.removeWhere((p) => p['id'] == id);
        Get.snackbar('success'.tr, data['message'] ?? 'photo_deleted'.tr);
      } else {
        Get.snackbar('error'.tr, data['message'] ?? 'something_went_wrong'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  String photoUrl(String path) =>
      path.startsWith('http') ? path : '$storageUrl/$path';
}
