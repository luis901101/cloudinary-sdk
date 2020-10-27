
enum CloudinaryDeliveryType {
  upload,
  private,
  fetch,
  authenticated,
  facebook,
  twitter,
  gravatar,
  youtube,
  hulu,
  vimeo,
  animoto,
  worldstarhiphop,
  dailymotion
}

extension CloudinaryDeliveryTypeUtils on CloudinaryDeliveryType {
  String get name {
    final String description = this.toString();
    final int indexOfDot = description.indexOf('.');
    assert(
    indexOfDot != -1 && indexOfDot < description.length - 1,
    'The provided object "$this" is not an enum.',
    );
    return description.substring(indexOfDot + 1);
  }
}
