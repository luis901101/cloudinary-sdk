class InvalidCloudinaryUrlException implements Exception {
  const InvalidCloudinaryUrlException();

  String get message => 'Invalid cloudinary url';

  @override
  String toString() => message;
}
