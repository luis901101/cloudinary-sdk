import 'package:cloudinary_sdk/src/models/cloudinary_image.dart';

class CloudinaryTransformation {
  final String _path;
  final String _publicId;
  Map<String, String> _params = {};
  List<Map<String, String>> _chains = [];

  CloudinaryTransformation(this._path, this._publicId);

  CloudinaryTransformation width(int width) {
    return param('w', width);
  }

  CloudinaryTransformation height(int height) {
    return param('h', height);
  }

  CloudinaryTransformation x(int x) {
    return param('x', x);
  }

  CloudinaryTransformation y(int y) {
    return param('y', y);
  }

  CloudinaryTransformation crop(String value) {
    return param('c', value);
  }

  CloudinaryTransformation thumb() {
    return crop('thumb');
  }

  CloudinaryTransformation scale() {
    return crop('scale');
  }

  CloudinaryTransformation fit() {
    return crop('fit');
  }

  CloudinaryTransformation gravity(String value) {
    return param('g', value);
  }

  CloudinaryTransformation face() {
    return gravity('face');
  }

  CloudinaryTransformation quality(String value) {
    return param('q', value);
  }

  CloudinaryTransformation radius(int value) {
    return param('r', value);
  }

  CloudinaryTransformation angle(int angle) {
    return param('a', angle);
  }

  CloudinaryTransformation opacity(int value) {
    return param('o', value);
  }

  CloudinaryTransformation effect(String value) {
    return param('e', value);
  }

  CloudinaryTransformation overlay(CloudinaryImage cloudinaryImage) {
    return param('l', cloudinaryImage.publicId.replaceAll('/', ':'));
  }

  CloudinaryTransformation underlay(CloudinaryImage cloudinaryImage) {
    return param('u', cloudinaryImage.publicId.replaceAll('/', ':'));
  }

  String generate() {
    if (_params.isNotEmpty) {
      _chains.add(_params);
    }

    String url = _path;

    _chains.forEach((element) {
      url += _values(element);
      url += '/';
    });

    url += _publicId;

    return url;
  }

  CloudinaryTransformation chain() {
    // clone
    _chains.add(Map.from(_params));
    _params.clear();
    return this;
  }

  String _values(Map<String, String> items) {
    final keys = items.keys.toList();
    keys.sort();

    List<String> values = [];

    keys.forEach((key) {
      values.add('${key}_${items[key]}');
    });

    return values.join(',');
  }

  CloudinaryTransformation param(String key, dynamic value) {
    if (value != null) {
      _params.addAll({key: value.toString()});
    }
    return this;
  }

  @override
  String toString() {
    return generate();
  }
}
