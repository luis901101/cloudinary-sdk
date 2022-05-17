import 'dart:async';
import 'dart:io';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:cloudinary_sdk_example/alert_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloudinary_sdk_example/image_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';


/// Make sure to put environment variables in your
/// flutter run command or in your Additional run args in your selected
/// configuration.
/// Take into account not all envs are necessary
///
/// For example:
///
/// flutter run
/// --dart-define=CLOUDINARY_API_URL=https://api.cloudinary.com/v1_1
/// --dart-define=CLOUDINARY_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxx
/// --dart-define=CLOUDINARY_API_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxx
/// --dart-define=CLOUDINARY_CLOUD_NAME=xxxxxxxxxxxxxxxxxxxxxxxxxxx
/// --dart-define=CLOUDINARY_FOLDER=xxxxxxxxxxxxxxxxxxxxxxxxxxx
/// --dart-define=CLOUDINARY_UPLOAD_PRESET=xxxxxxxxxxxxxxxxxxxxxxxxxxx
///
const String apiUrl = String.fromEnvironment('CLOUDINARY_API_URL', defaultValue: 'https://api.cloudinary.com/v1_1');
const String apiKey = String.fromEnvironment('CLOUDINARY_API_KEY', defaultValue: '');
const String apiSecret = String.fromEnvironment('CLOUDINARY_API_SECRET', defaultValue: '');
const String cloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME', defaultValue: '');
const String folder = String.fromEnvironment('CLOUDINARY_FOLDER', defaultValue: 'test/my-folder');
const String uploadPreset = String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET', defaultValue: '');

final cloudinary = Cloudinary.full(apiUrl: apiUrl, apiKey: apiKey, apiSecret: apiSecret, cloudName: cloudName);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloudinary Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Cloudinary Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum UploadMode {
  single,
  multiple,
}

enum FileSource {
  path,
  bytes,
}

enum DeleteMode {
  batch,
  iterative,
}

class DataTransmitNotifier {
  final String path;
  late final ProgressCallback? progressCallback;
  final notifier = ValueNotifier<double>(0);

  DataTransmitNotifier({required this.path, ProgressCallback? progressCallback}) {
    this.progressCallback = progressCallback ?? (count, total) {
      notifier.value = count.toDouble() / total.toDouble();
    };
  }
}

class _MyHomePageState extends State<MyHomePage> {
  static const int loadImage = 1;
  static const int doSignedUpload = 2;
  static const int doUnsignedUpload = 3;
  static const int deleteUploadedData = 4;
  List<DataTransmitNotifier> dataImages = [];
  List<CloudinaryResponse> cloudinaryResponses = [];
  bool loading = false;
  String? errorMessage;
  UploadMode uploadMode = UploadMode.single;
  FileSource fileSource = FileSource.path;
  DeleteMode deleteMode = DeleteMode.batch;

  @override
  void initState() {
    super.initState();
  }

  void onUploadModeChanged(UploadMode? value) => setState(() => uploadMode = value!);

  void onUploadSourceChanged(FileSource? value) =>
      setState(() => fileSource = value!);

  void onDeleteModeChanged(DeleteMode? value) => setState(() => deleteMode = value!);

  Widget get uploadModeView => Column(
        children: [
          const Text("Upload mode"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RadioListTile<UploadMode>(
                    title: const Text("Single"),
                    value: UploadMode.single,
                    groupValue: uploadMode,
                    onChanged: onUploadModeChanged),
              ),
              Expanded(
                child: RadioListTile<UploadMode>(
                    title: const Text("Multiple"),
                    value: UploadMode.multiple,
                    groupValue: uploadMode,
                    onChanged: onUploadModeChanged),
              ),
            ],
          )
        ],
      );

  Widget get uploadSourceView => Column(
        children: [
          const Text("File source"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RadioListTile<FileSource>(
                    title: const Text("Path"),
                    value: FileSource.path,
                    groupValue: fileSource,
                    onChanged: onUploadSourceChanged),
              ),
              Expanded(
                child: RadioListTile<FileSource>(
                    title: const Text("Bytes"),
                    value: FileSource.bytes,
                    groupValue: fileSource,
                    onChanged: onUploadSourceChanged),
              ),
            ],
          )
        ],
      );

  Widget get deleteModeView => Column(
        children: [
          const Text("Delete mode"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RadioListTile<DeleteMode>(
                    title: const Text("Batch"),
                    value: DeleteMode.batch,
                    groupValue: deleteMode,
                    onChanged: onDeleteModeChanged),
              ),
              Expanded(
                child: RadioListTile<DeleteMode>(
                    title: const Text("Iterative"),
                    value: DeleteMode.iterative,
                    groupValue: deleteMode,
                    onChanged: onDeleteModeChanged),
              ),
            ],
          )
        ],
      );

  Widget imageFromPathView(DataTransmitNotifier data) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.file(
            File(data.path),
            width: 100,
            height: 100,
          ),
          ValueListenableBuilder<double>(
            key: ValueKey(data.path),
            valueListenable: data.notifier,
            builder: (context, value, child) {
              if (value == 0 && !loading) return const SizedBox();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: value,
                  ),
                  Text('${(value * 100).toInt()} %'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget imageFromUrlView(CloudinaryResponse resource) {
    final image = resource.cloudinaryImage;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          image!.transform().width(256).thumb().generate()!,
          width: 100,
          height: 100,
        ),
        SizedBox(
          width: 100,
          child: Text(resource.originalFilename ?? resource.publicId ?? resource.secureUrl ?? 'Unknown',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget imageGalleryView({
    bool fromPath = true,
  }) {
    List imagesSource = fromPath ? dataImages : cloudinaryResponses;

    final imageViews = List.generate(imagesSource.length, (index) {
      final source = imagesSource[index];
      return fromPath ? imageFromPathView(source) : imageFromUrlView(source);
    });

    if (loading && !fromPath) {
      imageViews.add(const Center(
        child: CircularProgressIndicator(),
      ));
    }
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: imageViews,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 16),
                const Text(
                  'Photos from file',
                ),
                const SizedBox(
                  height: 16,
                ),
                imageGalleryView(fromPath: true),
                ElevatedButton(
                  onPressed: loading || dataImages.isEmpty
                      ? null
                      : () {
                          dataImages = [];
                          setState(() {});
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.deepPurple;
                    }),
                  ),
                  child: const Text(
                    'Clear list',
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(
                  height: 48,
                ),
                const Text(
                  'Photos from cloudinary',
                ),
                const SizedBox(
                  height: 16,
                ),
                imageGalleryView(fromPath: false),
                const SizedBox(
                  height: 32,
                ),
                Visibility(
                    visible: errorMessage?.isNotEmpty ?? false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$errorMessage",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, color: Colors.red.shade900),
                        ),
                        const SizedBox(
                          height: 128,
                        ),
                      ],
                    )),
                ElevatedButton(
                  onPressed: loading || cloudinaryResponses.isEmpty
                      ? null
                      : () {
                          cloudinaryResponses = [];
                          setState(() {});
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.purple;
                    }),
                  ),
                  child: const Text(
                    'Clear list',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                uploadModeView,
                const SizedBox(
                  height: 16,
                ),
                uploadSourceView,
                const SizedBox(
                  height: 16,
                ),
                deleteModeView,
                const SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ||
                          (dataImages.isEmpty &&
                              cloudinaryResponses.isEmpty)
                          ? null
                          : () {
                        dataImages = [];
                        cloudinaryResponses = [];
                        setState(() {});
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              return states.contains(MaterialState.disabled)
                                  ? null
                                  : Colors.blue;
                            }),
                      ),
                      child: const Text(
                        'Clear all',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading || dataImages.isEmpty
                          ? null
                          : () => onClick(doSignedUpload),
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(const EdgeInsets.all(8))
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'Signed upload',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Signed uploads are recommended only for server side, because it requires an api key and api secret to be able to upload images to Cloudinary. For uploading images from client side like mobile or web app consider "Unsigned upload"',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading || dataImages.isEmpty
                          ? null
                          : () => onClick(doUnsignedUpload),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
                        backgroundColor:
                        MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              return states.contains(MaterialState.disabled)
                                  ? null
                                  : Colors.deepOrange;
                            }),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'Unsigned upload',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Unsigned uploads are recommended from client side like mobile or web app. This upload doesn\'t require an api key or api secret to upload to Cloudinary.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading || cloudinaryResponses.isEmpty
                              ? null
                              : () => onClick(deleteUploadedData),
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                  return states.contains(MaterialState.disabled)
                                      ? null
                                      : Colors.red.shade600;
                                }),
                          ),
                          child: const Text(
                            'Delete uploaded images',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom,),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onClick(loadImage),
        tooltip: 'Choose photo',
        child: const Icon(Icons.photo),
      ),
    );
  }

  void onNewImages(List<String> filePaths) {
    if (filePaths.isNotEmpty) {
      for (final path in filePaths) {
        if (path.isNotEmpty) {
          dataImages.add(DataTransmitNotifier(path: path));
        }
      }
      setState(() {});
    }
  }

  Future<List<int>> getFileBytes(String path) async {
    return await File(path).readAsBytes();
  }

  Future<void> doSingleUpload({bool signed = true}) async {
    try {
      final data = dataImages.first;
      List<int>? fileBytes;

      if (fileSource == FileSource.bytes) {
        fileBytes = await getFileBytes(data.path);
      }

      final resource = CloudinaryUploadResource(
        filePath: data.path,
        fileBytes: fileBytes,
        resourceType: CloudinaryResourceType.image,
        folder: folder,
        fileName: 'single-${DateTime.now().millisecondsSinceEpoch}',
        progressCallback: data.progressCallback,
        uploadPreset: uploadPreset,
      );
      CloudinaryResponse response = signed ?
        await cloudinary.uploadResource(resource) :
        await cloudinary.unsignedUploadResource(resource);

      if (response.isSuccessful && response.secureUrl!.isNotEmpty) {
        cloudinaryResponses.add(response);
      } else {
        errorMessage = response.error;
      }
    } catch (e) {
      errorMessage = e.toString();
      print(e);
    }
  }

  Future<void> doMultipleUpload({bool signed = true}) async {
    try {
      List<CloudinaryUploadResource> resources = await Future.wait(
          dataImages.map((data) async => CloudinaryUploadResource(
            filePath: fileSource == FileSource.path ? data.path : null,
            fileBytes: fileSource == FileSource.bytes
                ? await getFileBytes(data.path)
                : null,
            resourceType: CloudinaryResourceType.image,
            folder: folder,
            progressCallback: data.progressCallback,
            uploadPreset: uploadPreset,
          )));

      List<CloudinaryResponse> responses = signed ?
        await cloudinary.uploadResources(resources) :
        await cloudinary.unsignedUploadResources(resources);
      for (var response in responses) {
        if (response.isSuccessful) {
          cloudinaryResponses.add(response);
        } else {
          errorMessage = response.error;
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      print(e);
    }
  }

  Future<void> upload({bool signed = true}) async {
    showLoading();
    switch (uploadMode) {
      case UploadMode.multiple: return doMultipleUpload(signed: signed);
      case UploadMode.single: return doSingleUpload(signed: signed);
      default:
    }
  }

  Future<void> doBatchDelete() async {
    CloudinaryResponse response = await cloudinary.deleteResources(
      urls: cloudinaryResponses.map((e) => e.secureUrl!).toList(),
      resourceType: CloudinaryResourceType.image
    );

    if (response.isSuccessful) {
      cloudinaryResponses = [];
      // Check for deleted status...
      // Map<String, dynamic> deleted = response.deleted;
    } else {
      errorMessage = response.error;
    }
  }

  Future<void> doIterativeDelete() async {
    for (int i = 0; i < cloudinaryResponses.length; i++) {
      String url = cloudinaryResponses[i].secureUrl!;
      final response = await cloudinary.deleteResource(
        url: url,
        resourceType: CloudinaryResourceType.image,
        invalidate: false,
      );
      if (response.isSuccessful) {
        cloudinaryResponses.removeWhere((element) => element.secureUrl == url);
        --i;
      }
    }
  }

  Future<void> delete() async {
    showLoading();
    switch (deleteMode) {
      case DeleteMode.batch:
        return doBatchDelete();
      case DeleteMode.iterative:
        return doIterativeDelete();
      default:
    }
  }

  void onClick(int id) async {
    errorMessage = null;
    try {
      switch (id) {
        case loadImage:
          AlertUtils.showImagePickerModal(
            context: context,
            onImageFromCamera: () async {
              onNewImages(await handleImagePickerResponse(
                  ImageUtils.takePhoto(cameraDevice: CameraDevice.rear)));
            },
            onImageFromGallery: () async {
              onNewImages(await handleImagePickerResponse(
                  ImageUtils.pickImageFromGallery()));
            },
          );
          break;
        case doSignedUpload:
          await upload();
          break;
        case doUnsignedUpload:
          await upload(signed: false);
          break;
        case deleteUploadedData:
          await delete();
          break;
      }
    } catch (e) {
      print(e);
      loading = false;
      setState(() => errorMessage = e.toString());
    } finally {
      if (loading) hideLoading();
    }
  }

  void showLoading() => setState(() => loading = true);

  void hideLoading() => setState(() => loading = false);

  Future<List<String>> handleImagePickerResponse(Future getImageCall) async {
    Map<String, dynamic> resource =
    await (getImageCall as FutureOr<Map<String, dynamic>>);
    if (resource.isEmpty) return [];
    switch (resource['status']) {
      case 'SUCCESS':
        Navigator.pop(context);
        return resource['data'];
      default:
        ImageUtils.showPermissionExplanation(
            context: context, message: resource['message']);
        break;
    }
    return [];
  }
}
