import 'package:cloudinary_sdk/src/models/cloudinary_delivery_type.dart';
import 'package:cloudinary_sdk/src/models/cloudinary_image.dart';
import 'package:cloudinary_sdk/src/models/cloudinary_resource_type.dart';
import 'package:cloudinary_sdk/src/data/cloudinary_client.dart';
import 'package:cloudinary_sdk/src/models/cloudinary_response.dart';
import 'package:cloudinary_sdk/src/models/cloudinary_upload_resource.dart';
import 'package:dio/dio.dart';

class Cloudinary {
  late final CloudinaryClient _client;

  Cloudinary._({
    String? apiUrl,
    String? apiKey,
    String? apiSecret,
    required String cloudName,
  })  : assert(cloudName.isNotEmpty, '`cloudName` must not be empty.'),
        _client = CloudinaryClient(
            apiUrl: apiUrl,
            apiKey: apiKey ?? '',
            apiSecret: apiSecret ?? '',
            cloudName: cloudName);

  /// Usu this constructor when you need full control over Cloudinary api
  /// like when you need to do authorized/signed api requests.
  factory Cloudinary.full(
      {String? apiUrl,
      required String apiKey,
      required String apiSecret,
      required String cloudName}) {
    assert(
        apiKey.isNotEmpty && apiSecret.isNotEmpty && cloudName.isNotEmpty,
        'None of `apiKey`, `apiSecret`, or `cloudName` '
        'must be empty.');
    return Cloudinary._(
        apiUrl: apiUrl,
        apiKey: apiKey,
        apiSecret: apiSecret,
        cloudName: cloudName);
  }

  /// Usu this constructor when you don't need to make authorized requests
  /// to Cloudinary api, like when you just need to do unsigned image upload.
  factory Cloudinary.basic({
    String? apiUrl,
    required String cloudName,
  }) =>
      Cloudinary._(apiUrl: apiUrl, cloudName: cloudName);

  String get apiKey => _client.apiKey;
  String get apiSecret => _client.apiSecret;
  String get cloudName => _client.cloudName;

  /// Uploads a file of [resourceType] with [fileName] to a [folder]
  /// in your specified [cloudName]
  ///
  /// [resource] A [CloudinaryUploadResource] object with all necessary data
  ///
  /// Response:
  /// Check all the attributes in the CloudinaryResponse to get the information you need... including secureUrl, publicId, etc.

  /// See also:
  ///
  ///  * [CloudinaryUploadResource], to know which data to set
  Future<CloudinaryResponse> uploadResource(
          CloudinaryUploadResource resource) =>
      _client.upload(
        filePath: resource.filePath,
        fileBytes: resource.fileBytes,
        fileName: resource.fileName,
        folder: resource.folder,
        resourceType: resource.resourceType,
        optParams: resource.optParams,
        progressCallback: resource.progressCallback,
      );

  /// This function uploads multiples files by calling uploadFile repeatedly
  ///
  /// [filePaths] the list of paths to the files to upload
  /// [filesBytes] the list of byte array of the files to uploaded
  Future<List<CloudinaryResponse>> uploadResources(
      List<CloudinaryUploadResource> resources) async {
    List<CloudinaryResponse> responses = [];
    if (resources.isNotEmpty) {
      responses = await Future.wait(
              resources.map((resource) async => await uploadResource(resource)))
          .catchError((err) => throw (err));
    }
    return responses;
  }

  /// Uploads a file of [resourceType] with [fileName] to a [folder]
  /// in your specified [cloudName] using a [uploadPreset] with no need to
  /// specify an [apiKey] nor [apiSecret].
  ///
  /// Make sure you set a [uploadPreset] in your resource.
  ///
  /// [resource] A [CloudinaryUploadResource] object with all necessary data
  ///
  /// Response:
  /// Check all the attributes in the CloudinaryResponse to get the information you need... including secureUrl, publicId, etc.

  /// See also:
  ///
  ///  * [CloudinaryUploadResource], to know which data to set
  Future<CloudinaryResponse> unsignedUploadResource(
      CloudinaryUploadResource resource) {
    assert(resource.uploadPreset?.isNotEmpty ?? false,
        'Resource\'s uploadPreset must not be empty');
    return _client.unsignedUpload(
      uploadPreset: resource.uploadPreset!,
      filePath: resource.filePath,
      fileBytes: resource.fileBytes,
      fileName: resource.fileName,
      folder: resource.folder,
      resourceType: resource.resourceType,
      optParams: resource.optParams,
      progressCallback: resource.progressCallback,
    );
  }

  /// This function uploads multiples files by calling uploadFile repeatedly
  ///
  /// [filePaths] the list of paths to the files to upload
  /// [filesBytes] the list of byte array of the files to uploaded
  Future<List<CloudinaryResponse>> unsignedUploadResources(
      List<CloudinaryUploadResource> resources) async {
    List<CloudinaryResponse> responses = [];
    if (resources.isNotEmpty) {
      responses = await Future.wait(resources
              .map((resource) async => await unsignedUploadResource(resource)))
          .catchError((err) => throw (err));
    }
    return responses;
  }

  /// Uploads a file of [resourceType] with [fileName] to a [folder]
  /// in your specified [cloudName]
  ///
  /// [filePath] path to the file to upload
  /// [fileBytes] byte array of the file to uploaded
  /// [resourceType] defaults to [CloudinaryResourceType.auto]
  /// [fileName] is not mandatory, if not specified then a random name will be used
  /// [optParams] a Map of optional parameters as defined in https://cloudinary.com/documentation/image_upload_api_reference
  ///
  /// Response:
  /// Check all the attributes in the CloudinaryResponse to get the information you need... including secureUrl, publicId, etc.
  @Deprecated('Use [uploadResource] instead')
  Future<CloudinaryResponse> uploadFile({
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    String? folder,
    CloudinaryResourceType? resourceType,
    Map<String, dynamic>? optParams,
    ProgressCallback? progressCallback,
  }) =>
      uploadResource(CloudinaryUploadResource(
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        folder: folder,
        resourceType: resourceType,
        optParams: optParams,
        progressCallback: progressCallback,
      ));

  /// This function uploads multiples files by calling uploadFile repeatedly
  ///
  /// [filePaths] the list of paths to the files to upload
  /// [filesBytes] the list of byte array of the files to uploaded
  @Deprecated('Use [uploadResources] instead')
  Future<List<CloudinaryResponse>> uploadFiles({
    List<String>? filePaths,
    List<List<int>>? filesBytes,
    String? folder,
    CloudinaryResourceType? resourceType,
    Map<String, dynamic>? optParams,
  }) async {
    if ((filePaths?.isEmpty ?? true) && (filesBytes?.isEmpty ?? true)) {
      throw Exception('One of filePaths or filesBytes must not be empty');
    }

    List<CloudinaryResponse> responses = [];

    if (filesBytes?.isNotEmpty ?? false) {
      responses = await Future.wait(filesBytes!.map((fileBytes) async =>
          await uploadFile(
              fileBytes: fileBytes,
              folder: folder,
              resourceType: resourceType,
              optParams: optParams))).catchError((err) => throw (err));
    }

    if (filePaths?.isNotEmpty ?? false) {
      responses = await Future.wait(filePaths!.map((filePath) async =>
          await uploadFile(
              filePath: filePath,
              folder: folder,
              resourceType: resourceType,
              optParams: optParams))).catchError((err) => throw (err));
    }

    return responses;
  }

  /// Deletes a file of [resourceType] with [publicId]
  /// from your specified [cloudName]
  /// By using the Destroy method of cloudinary api. Check here https://cloudinary.com/documentation/image_upload_api_reference#destroy_method
  ///
  /// [publicId] the asset id in your [cloudName], if not provided then [url] would be used. Note: The public ID value for images and videos should not include a file extension. Include the file extension for raw files only.
  /// [url] the url to the asset in your [cloudName], the publicId will be taken from here
  /// [cloudinaryImage] a Cloudinary Image to be deleted,  the publicId will be taken from here
  /// [resourceType] defaults to [CloudinaryResourceType.image]
  /// [invalidate] If true, invalidates CDN cached copies of the asset (and all its transformed versions). Default: false.
  /// [optParams] a Map of optional parameters as defined in https://cloudinary.com/documentation/image_upload_api_reference#destroy_method
  ///
  /// Response:
  /// Check response.isResultOk to know if the file was successfully deleted.
  Future<CloudinaryResponse> deleteResource(
      {String? publicId,
      String? url,
      CloudinaryImage? cloudinaryImage,
      CloudinaryResourceType? resourceType,
      bool? invalidate,
      Map<String, dynamic>? optParams}) {
    publicId ??= (cloudinaryImage ?? CloudinaryImage(url ?? '')).publicId;
    return _client.destroy(publicId,
        resourceType: resourceType,
        invalidate: invalidate,
        optParams: optParams);
  }

  @Deprecated('Use [deleteResource] instead')
  Future<CloudinaryResponse> deleteFile(
          {String? publicId,
          String? url,
          CloudinaryImage? cloudinaryImage,
          CloudinaryResourceType? resourceType,
          bool? invalidate,
          Map<String, dynamic>? optParams}) =>
      deleteResource(
          publicId: publicId,
          url: url,
          cloudinaryImage: cloudinaryImage,
          resourceType: resourceType,
          invalidate: invalidate,
          optParams: optParams);

  /// Deletes a list of files of [resourceType] represented by
  /// it's [publicIds] from your specified [cloudName].
  /// Alternatively you can set a [prefix] to delete all files where the
  /// public_id starts with the prefix or you can also set [all] to delete all
  /// files of [resourceType]
  /// By using the Delete Resources method from cloudinary Admin API.  Check here https://cloudinary.com/documentation/admin_api#delete_resources
  ///
  /// [publicIds] Delete all assets with the given public IDs (array of up to 100 public_ids).
  /// [urls] the urls list to the assets in your [cloudName] the publicIds will be taken from here
  /// [cloudinaryImages] a Cloudinary Images list to be deleted,  the publicIds will be taken from here
  /// [prefix] Delete all assets, including derived assets, where the public ID starts with the given prefix (up to a maximum of 1000 original resources).
  /// [all] Delete all assets (of the relevant resource_type and type), including derived assets (up to a maximum of 1000 original resources).
  /// [resourceType] defaults to [CloudinaryResourceType.image]
  /// [deliveryType] defaults to [CloudinaryDeliveryType.upload]
  /// [invalidate] If true, invalidates CDN cached copies of the asset (and all its transformed versions). Default: false.
  ///
  /// [resourceType] defaults to [CloudinaryResourceType.image]
  /// [invalidate] If true, invalidates CDN cached copies of the asset (and all its transformed versions). Default: false.
  /// [optParams] a Map of optional parameters as defined in a Map of optional parameters as defined in https://cloudinary.com/documentation/admin_api#delete_resources
  ///
  /// Response:
  /// Check 'deleted' map inside CloudinaryResponse to know which files were deleted
  Future<CloudinaryResponse> deleteResources(
      {List<String>? publicIds,
      List<String>? urls,
      List<CloudinaryImage>? cloudinaryImages,
      String? prefix,
      bool? all,
      CloudinaryResourceType? resourceType,
      CloudinaryDeliveryType? deliveryType,
      bool? invalidate,
      Map<String, dynamic>? optParams}) {
    if (all == null && prefix == null) {
      if (publicIds == null) {
        publicIds = [];
        if (urls != null) {
          for (var url in urls) {
            publicIds.add(CloudinaryImage(url).publicId);
          }
        } else if (cloudinaryImages != null) {
          for (var cloudinaryImage in cloudinaryImages) {
            publicIds.add(cloudinaryImage.publicId);
          }
        }
      }
    }

    return _client.deleteResources(
        publicIds: publicIds,
        prefix: prefix,
        all: all,
        resourceType: resourceType,
        deliveryType: deliveryType,
        invalidate: invalidate,
        optParams: optParams);
  }

  @Deprecated('Use [deleteResources] instead')
  Future<CloudinaryResponse> deleteFiles(
          {List<String>? publicIds,
          List<String>? urls,
          List<CloudinaryImage>? cloudinaryImages,
          String? prefix,
          bool? all,
          CloudinaryResourceType? resourceType,
          CloudinaryDeliveryType? deliveryType,
          bool? invalidate,
          Map<String, dynamic>? optParams}) =>
      deleteResources(
        publicIds: publicIds,
        urls: urls,
        cloudinaryImages: cloudinaryImages,
        prefix: prefix,
        all: all,
        resourceType: resourceType,
        deliveryType: deliveryType,
        invalidate: invalidate,
      );
}
