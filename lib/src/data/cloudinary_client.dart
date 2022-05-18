import 'package:cloudinary_sdk/src/models/cloudinary_delivery_type.dart';
import 'package:cloudinary_sdk/src/models/cloudinary_resource_type.dart';
import 'package:cloudinary_sdk/src/models/cloudinary_response.dart';
import 'package:dio/dio.dart';
import 'cloudinary_api.dart';

/// Cloudinary client abstraction
class CloudinaryClient extends CloudinaryApi {
  static const _signedRequestAssertMessage = 'This endpoint requires an '
      'authorized request, check the Cloudinary constructor you are using and '
      'make sure you are using a valid `apiKey`, `apiSecret` and `cloudName`.';

  final String apiKey;
  final String apiSecret;
  final String cloudName;

  CloudinaryClient({
    String? apiUrl,
    required this.apiKey,
    required this.apiSecret,
    required this.cloudName,
  }) : super(url: apiUrl, apiKey: apiKey, apiSecret: apiSecret);

  bool get isBasic => apiKey.isEmpty || apiSecret.isEmpty || cloudName.isEmpty;

  /// Uploads a file of [resourceType] with [fileName] to a [folder]
  /// in your specified [cloudName]
  /// The file to be uploaded can be from a path or a byte array
  ///
  /// [filePath] path to the file to upload
  /// [fileBytes] byte array of the file to uploaded
  /// [resourceType] defaults to [CloudinaryResourceType.auto]
  /// [fileName] is not mandatory, if not specified then a random name will be used
  /// [optParams] a Map of optional parameters as defined in https://cloudinary.com/documentation/image_upload_api_reference
  ///
  /// Response:
  /// Check all the attributes in the CloudinaryResponse to get the information you need... including secureUrl, publicId, etc.
  ///
  /// Official documentation: https://cloudinary.com/documentation/upload_images
  Future<CloudinaryResponse> upload({
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    String? folder,
    CloudinaryResourceType? resourceType,
    Map<String, dynamic>? optParams,
    ProgressCallback? progressCallback,
  }) async {
    assert(!isBasic, _signedRequestAssertMessage);

    if (filePath == null && fileBytes == null) {
      throw Exception('One of filePath or fileBytes must not be null');
    }

    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    resourceType ??= CloudinaryResourceType.auto;

    Map<String, dynamic> params = {};

    if (fileName != null) params['public_id'] = fileName;
    if (folder != null) params['folder'] = folder;

    /// Setting the optParams... this would override the public_id and folder if specified by user.
    if (optParams != null) params.addAll(optParams);
    params['api_key'] = apiKey;
    params['file'] = fileBytes != null
        ? MultipartFile.fromBytes(fileBytes,
            filename:
                fileName ?? DateTime.now().millisecondsSinceEpoch.toString())
        : await MultipartFile.fromFile(filePath!, filename: fileName);
    params['timestamp'] = timeStamp;
    params['signature'] =
        getSignature(secret: apiSecret, timeStamp: timeStamp, params: params);

    FormData formData = FormData.fromMap(params);

    Response response;
    int? statusCode;
    CloudinaryResponse cloudinaryResponse;
    try {
      response = await post(
        cloudName + '/${resourceType.name}/upload',
        data: formData,
        onSendProgress: progressCallback,
      );
      statusCode = response.statusCode;
      cloudinaryResponse = CloudinaryResponse.fromJsonMap(response.data);
    } catch (error, stacktrace) {
      print('Exception occurred: $error stackTrace: $stacktrace');
      if (error is DioError) statusCode = error.response?.statusCode;
      cloudinaryResponse = CloudinaryResponse.fromError('$error');
    }
    cloudinaryResponse.statusCode = statusCode;
    return cloudinaryResponse;
  }

  /// Uploads a file of [resourceType] with [fileName] to a [folder] in your
  /// specified [cloudName] using a [uploadPreset] with no need to specify an
  /// [apiKey] nor [apiSecret].
  /// The file to be uploaded can be from a path or a byte array
  ///
  /// [filePath] path to the file to upload
  /// [fileBytes] byte array of the file to uploaded
  /// [resourceType] defaults to [CloudinaryResourceType.auto]
  /// [fileName] is not mandatory, if not specified then a random name will be used
  /// [optParams] a Map of optional parameters as defined in https://cloudinary.com/documentation/image_upload_api_reference
  ///
  /// Response:
  /// Check all the attributes in the CloudinaryResponse to get the information you need... including secureUrl, publicId, etc.
  ///
  /// Official documentation: https://cloudinary.com/documentation/upload_images#unsigned_upload
  Future<CloudinaryResponse> unsignedUpload({
    required String uploadPreset,
    String? filePath,
    List<int>? fileBytes,
    String? publicId,
    String? fileName,
    String? folder,
    CloudinaryResourceType? resourceType,
    Map<String, dynamic>? optParams,
    ProgressCallback? progressCallback,
  }) async {
    assert(uploadPreset.isNotEmpty, 'Upload preset must not be empty.');

    if (filePath == null && fileBytes == null) {
      throw Exception('One of filePath or fileBytes must not be null');
    }

    resourceType ??= CloudinaryResourceType.auto;

    final params = <String, dynamic>{
      'upload_preset': uploadPreset,
      if (publicId != null || fileName != null)
        'public_id': publicId ?? fileName,
      if (folder != null) 'folder': folder,

      /// Setting the optParams... this would override the public_id and folder if specified by user.
      if (optParams?.isNotEmpty ?? false) ...optParams!,
    };

    params['file'] = fileBytes != null
        ? MultipartFile.fromBytes(fileBytes,
            filename:
                fileName ?? DateTime.now().millisecondsSinceEpoch.toString())
        : await MultipartFile.fromFile(filePath!, filename: fileName);

    FormData formData = FormData.fromMap(params);

    Response response;
    int? statusCode;
    CloudinaryResponse cloudinaryResponse;
    try {
      response = await post(
        cloudName + '/${resourceType.name}/upload',
        data: formData,
        onSendProgress: progressCallback,
      );
      statusCode = response.statusCode;
      cloudinaryResponse = CloudinaryResponse.fromJsonMap(response.data);
    } catch (error, stacktrace) {
      print('Exception occurred: $error stackTrace: $stacktrace');
      if (error is DioError) statusCode = error.response?.statusCode;
      cloudinaryResponse = CloudinaryResponse.fromError('$error');
    }
    cloudinaryResponse.statusCode = statusCode;
    return cloudinaryResponse;
  }

  /// Deletes a file of [resourceType] with [publicId]
  /// from your specified [cloudName]
  ///
  /// [publicId] The identifier of the uploaded asset. Note: The public ID value for images and videos should not include a file extension. Include the file extension for raw files only.
  /// [resourceType] defaults to [CloudinaryResourceType.image]
  /// [invalidate] If true, invalidates CDN cached copies of the asset (and all its transformed versions). Default: false.
  /// [optParams] a Map of optional parameters as defined in https://cloudinary.com/documentation/image_upload_api_reference#destroy_method
  ///
  /// Response:
  /// Check response.isResultOk to know if the file was successfully deleted.
  Future<CloudinaryResponse> destroy(String publicId,
      {CloudinaryResourceType? resourceType,
      bool? invalidate,
      Map<String, dynamic>? optParams}) async {
    assert(!isBasic, _signedRequestAssertMessage);

    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    resourceType ??= CloudinaryResourceType.image;

    final params = <String, dynamic>{};

    if (optParams != null) params.addAll(optParams);
    if (invalidate != null) params['invalidate'] = invalidate;
    params['public_id'] = publicId;
    params['api_key'] = apiKey;
    params['timestamp'] = timeStamp;
    params['signature'] =
        getSignature(secret: apiSecret, timeStamp: timeStamp, params: params);

    FormData formData = FormData.fromMap(params);

    Response response;
    CloudinaryResponse cloudinaryResponse;
    int? statusCode;
    try {
      response = await post(cloudName + '/${resourceType.name}/destroy',
          data: formData);
      statusCode = response.statusCode;
      cloudinaryResponse = CloudinaryResponse.fromJsonMap(response.data);
    } catch (error, stacktrace) {
      print('Exception occured: $error stackTrace: $stacktrace');
      if (error is DioError) statusCode = error.response?.statusCode;
      cloudinaryResponse = CloudinaryResponse.fromError('$error');
    }
    cloudinaryResponse.statusCode = statusCode;
    return cloudinaryResponse;
  }

  /// Deletes a list of files of [resourceType] represented by
  /// it's [publicIds] from your specified [cloudName].
  /// Alternatively you can set a [prefix] to delete all files where the
  /// public_id starts with the prefix or you can also set [all] to delete all
  /// files of [resourceType]
  ///
  /// [publicIds] Delete all assets with the given public IDs (array of up to 100 public_ids).
  /// [prefix] Delete all assets, including derived assets, where the public ID starts with the given prefix (up to a maximum of 1000 original resources).
  /// [all] Delete all assets (of the relevant resource_type and type), including derived assets (up to a maximum of 1000 original resources).
  /// [resourceType] defaults to [CloudinaryResourceType.image]
  /// [deliveryType] defaults to [CloudinaryDeliveryType.upload]
  /// [invalidate] If true, invalidates CDN cached copies of the asset (and all its transformed versions). Default: false.
  /// [optParams] a Map of optional parameters as defined in https://cloudinary.com/documentation/admin_api#delete_resources
  ///
  /// Response:
  /// Check 'deleted' map inside CloudinaryResponse to know which files were deleted
  Future<CloudinaryResponse> deleteResources(
      {List<String>? publicIds,
      String? prefix,
      bool? all,
      CloudinaryResourceType? resourceType,
      CloudinaryDeliveryType? deliveryType,
      bool? invalidate,
      Map<String, dynamic>? optParams}) async {
    assert(!isBasic, _signedRequestAssertMessage);

    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    resourceType ??= CloudinaryResourceType.image;
    deliveryType ??= CloudinaryDeliveryType.upload;

    final params = <String, dynamic>{};

    if (optParams != null) params.addAll(optParams);
    if (invalidate != null) params['invalidate'] = invalidate;
    if (publicIds != null) {
      params['public_ids'] = publicIds;
    } else if (prefix != null) {
      params['prefix'] = prefix;
    } else if (all != null) {
      params['all'] = all;
    }

    params['api_key'] = apiKey;
    params['timestamp'] = timeStamp;
    params['signature'] =
        getSignature(secret: apiSecret, timeStamp: timeStamp, params: params);

    FormData formData = FormData.fromMap(params, ListFormat.multiCompatible);

    Response response;
    CloudinaryResponse cloudinaryResponse;
    int? statusCode;
    try {
      response = await delete(
        cloudName + '/resources/${resourceType.name}/${deliveryType.name}',
        data: formData,
      );
      statusCode = response.statusCode;
      cloudinaryResponse = CloudinaryResponse.fromJsonMap(response.data);
    } catch (error, stacktrace) {
      print('Exception occured: $error stackTrace: $stacktrace');
      if (error is DioError) statusCode = error.response?.statusCode;
      cloudinaryResponse = CloudinaryResponse.fromError('$error');
    }
    cloudinaryResponse.statusCode = statusCode;
    return cloudinaryResponse;
  }
}
