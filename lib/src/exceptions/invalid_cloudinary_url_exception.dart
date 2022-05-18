/// Exception to be thrown when a CloudinaryImage fails to build from url
class InvalidCloudinaryUrlException implements Exception {
  const InvalidCloudinaryUrlException();

  String get message => 'Invalid cloudinary url';

  @override
  String toString() => message;
}
