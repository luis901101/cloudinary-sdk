import 'package:cloudinary_sdk/src/models/cloudinary_delivery_type.dart';
import 'package:cloudinary_sdk/src/models/cloudinary_image.dart';
import 'package:cloudinary_sdk/src/models/cloudinary_resource_type.dart';
import 'package:cloudinary_sdk/src/data/cloudinary_client.dart';
import 'package:cloudinary_sdk/src/models/cloudinary_response.dart';

class Cloudinary {
  String _apiKey;
  String _apiSecret;
  String _cloudName;
  CloudinaryClient _client;

  Cloudinary(String apiKey, String apiSecret, String cloudName) {
    this._apiKey = apiKey;
    this._apiSecret = apiSecret;
    this._cloudName = cloudName;
    _client = CloudinaryClient(_apiKey, _apiSecret, _cloudName);
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
  /// Check all the atributes in the CloudinaryResponse to get the information you need... including secureUrl, publicId, etc.
  Future<CloudinaryResponse> uploadFile({
    String filePath,
    List<int> fileBytes,
    String fileName,
    String folder,
    CloudinaryResourceType resourceType,
    Map<String, dynamic> optParams
  }) =>
    _client.upload(
      filePath: filePath,
      fileBytes: fileBytes,
      fileName: fileName,
      folder: folder,
      resourceType: resourceType,
      optParams: optParams
    );


  /// This function uploads multiples files by calling uploadFile repeatedly
  ///
  /// [filePaths] the list of paths to the files to upload
  /// [filesBytes] the list of byte array of the files to uploaded
  Future<List<CloudinaryResponse>> uploadFiles({
    List<String> filePaths,
    List<List<int>> filesBytes,
    String folder,
    CloudinaryResourceType resourceType,
    Map<String, dynamic> optParams,
  }) async {

    if((filePaths?.isEmpty ?? true) && (filesBytes?.isEmpty ?? true))
      throw Exception("One of filePaths or filesBytes must not be empty");

    if((filePaths?.isNotEmpty ?? false) && (filesBytes?.isNotEmpty ?? false))
      throw Exception("Only one of filePaths or filesBytes must not be empty");

    List<CloudinaryResponse> responses;
    if(filePaths?.isNotEmpty ?? false)
      responses = await Future.wait(
        filePaths.map(
          (filePath) async => await _client.upload(
            filePath: filePath,
            folder: folder,
            resourceType: resourceType,
            optParams: optParams
          )
        )
      ).catchError((err) => throw (err));

    if(filesBytes?.isNotEmpty ?? false)
      responses = await Future.wait(
          filesBytes.map(
                  (fileBytes) async => await _client.upload(
                  fileBytes: fileBytes,
                  folder: folder,
                  resourceType: resourceType,
                  optParams: optParams
              )
          )
      ).catchError((err) => throw (err));
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
  Future<CloudinaryResponse> deleteFile(
      {String publicId,
      String url,
      CloudinaryImage cloudinaryImage,
      CloudinaryResourceType resourceType,
      bool invalidate,
      Map<String, dynamic> optParams}) {
    if (publicId == null)
      publicId = (cloudinaryImage ?? CloudinaryImage(url)).publicId;
    return _client.destroy(publicId,
        resourceType: resourceType,
        invalidate: invalidate,
        optParams: optParams);
  }

  /// Deletes a list of files of [resourceType] represented by
  /// it's [publicIds] from your specified [cloudName].
  /// Alternatively you can set a [prefix] to delete all files where the
  /// public_id starts with the prefix or you can also set [all] to delete all
  /// files of [resourceType]
  /// By using the Delete Resources method from cloudinary Admin API.  Check here https://cloudinary.com/documentation/admin_api#delete_resources
  ///
  /// [publicIds] Delete all assets with the given public IDs (array of up to 100 public_ids).
  /// [urls] the urls list to the assets in your [cloudName] the publicIds will be taken from here
  /// [cloudinaryImage] a Cloudinary Images list to be deleted,  the publicIds will be taken from here
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
  Future<CloudinaryResponse> deleteFiles(
      {List<String> publicIds,
      List<String> urls,
      List<CloudinaryImage> cloudinaryImages,
      String prefix,
      bool all,
      CloudinaryResourceType resourceType,
      CloudinaryDeliveryType deliveryType,
      bool invalidate,
      Map<String, dynamic> optParams}) {
    if (all == null && prefix == null) {
      if (publicIds == null) {
        publicIds = [];
        if (urls != null)
          urls.forEach((url) => publicIds.add(CloudinaryImage(url).publicId));
        else if (cloudinaryImages != null)
          cloudinaryImages.forEach(
              (cloudinaryImage) => publicIds.add(cloudinaryImage.publicId));
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
}
