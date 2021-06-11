import 'cloudinary_transformation.dart';

class CloudinaryImage {
  static const String _baseUrl =
      'https://res.cloudinary.com/:cloud/image/upload/';

  late String _pathStart;
  late String _pathEnd;
  late String _publicId;
  late String _originalUrl;

  String get url => _originalUrl;

  String get publicId => _publicId;

  CloudinaryImage(String url) {
    // remove version
    _originalUrl = url.replaceFirst(RegExp(r"v\d+/"), '');

    final resource = url.split('/upload/');
    // assert(resource.length == 2, 'Invalid cloudinary url');
    if(resource.length != 2) throw Exception('Invalid cloudinary url');
    _pathStart = resource[0] + '/upload/';
    _pathEnd = resource[1];
    _publicId = Uri.decodeFull(_originalUrl.split('/upload/')[1]);
    int lastDotIndex = _publicId.lastIndexOf('.');
    if (lastDotIndex != -1) _publicId = _publicId.substring(0, lastDotIndex);
  }

  factory CloudinaryImage.fromPublicId(String cloudName, String publicId) {
    return CloudinaryImage(
      _baseUrl.replaceFirst(':cloud', cloudName) + publicId,
    );
  }

  CloudinaryTransformation transform() {
    return CloudinaryTransformation(_pathStart, _pathEnd);
  }

  @override
  String toString() => _originalUrl;
}
