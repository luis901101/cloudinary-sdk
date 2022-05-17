import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:dio/dio.dart';

/// An abstraction object to upload a [resourceType] with [fileName] to a
/// [folder] in your specified [cloudName]
///
/// [filePath] path to the file to upload
/// [fileBytes] byte array of the file to uploaded
/// [uploadPreset] it's required only if you will make an unsigned upload
/// [resourceType] defaults to [CloudinaryResourceType.auto]
/// [fileName] is not mandatory, if not specified then a random name will be used
/// [publicId] is not mandatory, if not specified then a random publicId will be used
/// [optParams] a Map of optional parameters as defined in https://cloudinary.com/documentation/image_upload_api_reference
/// [progressCallback] a callback to get the progress of the uploading data
///
/// Note: one of [filePath] or [fileBytes] must be set
class CloudinaryUploadResource {
  final String? filePath;
  final List<int>? fileBytes;
  final String? uploadPreset;
  final String? fileName;
  final String? publicId;
  final String? folder;
  final CloudinaryResourceType? resourceType;
  final Map<String, dynamic>? optParams;
  final ProgressCallback? progressCallback;

  const CloudinaryUploadResource({
    this.filePath,
    this.fileBytes,
    this.uploadPreset,
    this.fileName,
    this.publicId,
    this.folder,
    this.resourceType,
    this.optParams,
    this.progressCallback,
  }) : assert(filePath != null || fileBytes != null,
            'One of filePath or fileBytes must not be null');
}
