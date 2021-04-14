import 'package:cloudinary_sdk/cloudinary_sdk.dart';

/// An abstraction object to upload a [resourceType] with [fileName] to a
/// [folder] in your specified [cloudName]
///
/// [filePath] path to the file to upload
/// [fileBytes] byte array of the file to uploaded
/// [resourceType] defaults to [CloudinaryResourceType.auto]
/// [fileName] is not mandatory, if not specified then a random name will be used
/// [optParams] a Map of optional parameters as defined in https://cloudinary.com/documentation/image_upload_api_reference
///
/// Note: one of [filePath] or [fileBytes] must be set
class CloudinaryUploadResource {
  final String? filePath;
  final List<int>? fileBytes;
  final String? fileName;
  final String? folder;
  final CloudinaryResourceType? resourceType;
  final Map<String, dynamic>? optParams;

  CloudinaryUploadResource(
      {this.filePath,
      this.fileBytes,
      this.fileName,
      this.folder,
      this.resourceType,
      this.optParams})
      : assert(filePath != null || fileBytes != null,
            "One of filePath or fileBytes must not be null");
}
