import 'package:cloudinary_sdk/cloudinary_sdk.dart';

/// The object image representation of a Cloudinary image which allows you to
/// apply transformations to the image url.
class CloudinaryImage {
  static const String _baseUrl =
      'https://res.cloudinary.com/:cloud/image/upload/';

  late final String pathStart;
  late final String publicId;
  late final String url;

  CloudinaryImage(String url) {
    // remove version
    this.url = url.replaceFirst(RegExp(r'v\d+/'), '');

    final resource = this.url.split('/upload/');
    // assert(resource.length == 2, 'Invalid cloudinary url');
    if (resource.length != 2) throw InvalidCloudinaryUrlException();
    pathStart = resource[0] + '/upload/';
    final String pathEnd = resource[1];
    String tempPublicId = Uri.decodeFull(pathEnd);
    int lastDotIndex = tempPublicId.lastIndexOf('.');
    if (lastDotIndex != -1) {
      tempPublicId = tempPublicId.substring(0, lastDotIndex);
    }
    publicId = tempPublicId;
  }

  factory CloudinaryImage.fromPublicId(String cloudName, String publicId) {
    return CloudinaryImage(
      _baseUrl.replaceFirst(':cloud', cloudName) + publicId,
    );
  }

  CloudinaryTransformation transform() {
    return CloudinaryTransformation(pathStart, publicId);
  }

  @override
  String toString() => url;
}
