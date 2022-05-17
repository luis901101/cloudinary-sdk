import 'dart:io';

import 'package:cloudinary_sdk/cloudinary_sdk.dart';

///
/// Make sure to set these environment variables before running tests.
/// Take into account not all envs are necessary, it depends on what kind of
/// authentication you want to use.
///
/// export CLOUDINARY_API_URL=https://api.cloudinary.com/v1_1
/// export CLOUDINARY_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxx
/// export CLOUDINARY_API_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxx
/// export CLOUDINARY_CLOUD_NAME=xxxxxxxxxxxxxxxxxxxxxxxxxxx
/// export CLOUDINARY_FOLDER=xxxxxxxxxxxxxxxxxxxxxxxxxxx
///
/// export CLOUDINARY_IMAGE_FILE=/Users/user/Desktop/image-test.jpg
/// export CLOUDINARY_IMAGE_FILE_1=/Users/user/Desktop/image-test-1.jpg
/// export CLOUDINARY_IMAGE_FILE_2=/Users/user/Desktop/image-test-2.jpg
/// export CLOUDINARY_IMAGE_URL=https://picsum.photos/id/237/536/354
/// export CLOUDINARY_VIDEO_FILE=/Users/user/Desktop/video-test.mp4
/// export CLOUDINARY_VIDEO_FILE_1=/Users/user/Desktop/video-test-1.mp4
/// export CLOUDINARY_VIDEO_FILE_2=/Users/user/Desktop/video-test-2.mp4
///

final String? apiKey = Platform.environment['CLOUDINARY_API_KEY'];
final String? apiSecret = Platform.environment['CLOUDINARY_API_SECRET'];
final String? cloudName = Platform.environment['CLOUDINARY_CLOUD_NAME'];
final String? folder = Platform.environment['CLOUDINARY_FOLDER'] ?? 'test/my-folder';

final File imageFile = File(Platform.environment['CLOUDINARY_IMAGE_FILE'] ?? ''),
    imageFile1 = File(Platform.environment['CLOUDINARY_IMAGE_FILE_1'] ?? ''),
    imageFile2 = File(Platform.environment['CLOUDINARY_IMAGE_FILE_2'] ?? '');
final String imageUrl = Platform.environment['CLOUDINARY_IMAGE_URL'] ?? '';
Set<String> cacheUrls = {};

void addSecureUrl(String? id) {
  if(id != null) cacheUrls.add(id);
}

Cloudinary cloudinary = Cloudinary.basic(cloudName: 'none');

Future<void> init() async {
  if (apiKey == null) throw Exception("apiKey can't be null");
  if (apiSecret == null) throw Exception("apiSecret can't be null");
  if (cloudName == null) throw Exception("cloudName can't be null");

  cloudinary = Cloudinary.full(
    apiKey: apiKey!,
    apiSecret: apiSecret!,
    cloudName: cloudName!,
  );
}
