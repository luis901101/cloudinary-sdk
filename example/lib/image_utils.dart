import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static Future<File?> _retrieveLostData() async {
    if (!Platform.isAndroid) return null;
    final LostData response = await ImagePicker().getLostData();
    return response.file?.path != null ? File(response.file!.path) : null;
  }

  static const String cameraAccessDenied = "camera_access_denied";
  static const String galleryAccessDenied = "photo_access_denied";

  static Future<Map<String, dynamic>> _pickImageFrom(
      {ImageSource? source, CameraDevice? cameraDevice}) async {
    Map<String, dynamic> resource;

    PickedFile? pickedFile;
    File? file;
    try {
      pickedFile = await ImagePicker().getImage(
        source: source ?? ImageSource.camera,
        preferredCameraDevice: cameraDevice ?? CameraDevice.rear,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 100,
      );
      if (pickedFile?.path != null) file = File(pickedFile!.path);
      if (file == null) file = await _retrieveLostData();
      resource = {'status': 'SUCCESS', 'data': file};
    } on PlatformException catch (e) {
      resource = {
        'status': 'ERROR',
        'data': file,
        'message': e.message,
        'exception': e,
        'extras': e.details
      };
      switch (e.code) {
        case cameraAccessDenied:
          resource['message'] =
              'Camera permission denied. You have to grant permission from system settings';
          break;
        case galleryAccessDenied:
          resource['message'] =
              'Gellery permission denied. You have to grant permission from system settings';
          break;
      }
    } catch (e) {
      resource = {
        'status': 'ERROR',
        'data': file,
        'message': e.toString(),
        'exception': e,
      };
    }
    return resource;
  }

  static Future<Map<String, dynamic>> pickImageFromGallery() async =>
      await _pickImageFrom(source: ImageSource.gallery);

  static Future<Map<String, dynamic>> takePhoto(
          {CameraDevice? cameraDevice}) async =>
      await _pickImageFrom(
          source: ImageSource.camera, cameraDevice: cameraDevice);

  static showPermissionExplanation({required BuildContext context, String? message}) {
    showDialog(
        context: context,
        builder: (innerContext) => AlertDialog(
              title: Text('Warning'),
              content: Text(message!),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context), child: Text('OK'))
              ],
            ));
  }
}
