
enum CloudinaryResourceType {
  image,
  raw,
  video,
  auto,
}

extension CloudinaryResourceTypeUtils on CloudinaryResourceType {
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
