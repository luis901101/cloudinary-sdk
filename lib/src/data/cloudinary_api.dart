import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CloudinaryApi {
  static const defaultUrl = 'https://api.cloudinary.com/v1_1/';
  final String apiUrl;
  final Dio _dio;
  final Dio _deleteDio;

  CloudinaryApi({String? url, String? apiKey, String? apiSecret})
      : apiUrl = (url?.isEmpty ?? true) ? url = defaultUrl : url!,
        _dio = Dio(BaseOptions(baseUrl: '$url/',)),
        _deleteDio = Dio(BaseOptions(baseUrl: '$url/'.replaceFirst('https://', 'https://$apiKey:$apiSecret@'),));

  /// To do post requests to Cloudinary API
  Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _dio.post(path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);

  /// To do delete requests to Cloudinary API
  Future<Response<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _deleteDio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  /// Generates a proper Cloudinary Authentication Signature according to https://cloudinary.com/documentation/upload_images#generating_authentication_signatures
  String? getSignature(
      {String? secret, int? timeStamp, Map<String, dynamic>? params}) {
    timeStamp ??= DateTime.now().millisecondsSinceEpoch;
    String? signature;
    try {
      Map<String, dynamic> signatureParams = {}..addAll(params ?? {});
      signatureParams['timestamp'] = timeStamp;

      //Removing unwanted params
      signatureParams.remove('api_key');
      signatureParams.remove('cloud_name');
      signatureParams.remove('file');
      signatureParams.remove('resource_type');

      //Merging key and value with '='
      List<String> paramsList = [];
      signatureParams.forEach((key, value) => paramsList.add('$key=$value'));

      //Sorting params alphabetically
      paramsList.sort();

      //Merging params with '&'
      StringBuffer stringParams = StringBuffer();
      if (paramsList.isNotEmpty) stringParams.write(paramsList[0]);
      for (int i = 1; i < paramsList.length; ++i) {
        stringParams.write('&${paramsList[i]}');
      }

      //Adding API Secret to the params
      stringParams.write(secret);

      //Generating signatureHash
      var bytes = utf8.encode(stringParams.toString().trim());
      signature = sha1.convert(bytes).toString();
    } catch (e) {
      print(e);
    }
    return signature;
  }
}
