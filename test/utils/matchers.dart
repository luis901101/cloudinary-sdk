import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class GenericMatcher extends Matcher {
  bool Function(dynamic item, Map matchState)? onMatches;
  Description Function(Description description)? onDescribe;

  GenericMatcher({this.onMatches, this.onDescribe});

  @override
  bool matches(dynamic item, Map matchState) =>
      onMatches?.call(item, matchState) ?? false;

  @override
  Description describe(Description description) =>
      onDescribe?.call(description) ?? description;
}

bool printAndReturnOnFailure(String message) {
  printOnFailure(message);
  return false;
}

class ResponseMatcher extends GenericMatcher {
  ResponseMatcher() : super();

  @override
  bool matches(response, Map matchState) {
    if (response is! CloudinaryResponse) {
      return false;
    }
    if (!response.isSuccessful) {
      // fail('Unsuccessful response: ${response.error?.toString()}');
      return printAndReturnOnFailure(
          'Unsuccessful response: ${response.error?.toString()}');
    }
    return true;
  }
}

class ImageMatcher extends GenericMatcher {
  ImageMatcher() : super();

  @override
  bool matches(item, Map matchState) {
    super.matches(item, matchState);
    if (item is! CloudinaryImage) return false;
    return item.url.isNotEmpty && item.publicId.isNotEmpty;
  }
}

class InvalidCloudinaryUrlMatcher extends GenericMatcher {
  InvalidCloudinaryUrlMatcher() : super();

  @override
  bool matches(item, Map matchState) {
    super.matches(item, matchState);
    return item is InvalidCloudinaryUrlException;
  }
}
