import 'dart:io';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:cloudinary_sdk_example/alert_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloudinary_sdk_example/image_utils.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloudinary Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Cloudinary Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum UploadMode {
  SINGLE,
  MULTIPLE,
}

enum FileSource {
  PATH,
  BYTES,
}

class _MyHomePageState extends State<MyHomePage> {
  //Change this values with your own
  final String cloudinaryCustomFolder = "test/myfolder";
  final String cloudinaryApiKey = "111111111";
  final String cloudinaryApiSecret = "aaaaa-bbbbb-ccccccccc";
  final String cloudinaryCloudName = "my-cloud-name";
  static const int loadPhoto = 1;
  static const int uploadPhotos = 2;
  static const int deleteUploadedPhotos = 3;
  List<String> pathPhotos = [];
  List<String> urlPhotos = [];
  bool loading = false;
  Cloudinary cloudinary;
  String errorMessage;
  UploadMode uploadMode;
  FileSource fileSource;

  @override
  void initState() {
    super.initState();
    cloudinary =
        Cloudinary(cloudinaryApiKey, cloudinaryApiSecret, cloudinaryCloudName);
    uploadMode = UploadMode.MULTIPLE;
    fileSource = FileSource.PATH;
  }

  onUploadModeChanged(UploadMode value) => setState(() => uploadMode = value);
  onUploadSourceChanged(FileSource value) =>
      setState(() => fileSource = value);

  Widget get uploadModeView =>
    Column(
      children: [
        Text("Upload mode"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: RadioListTile<UploadMode>(
                title: Text("Single"),
                value: UploadMode.SINGLE,
                groupValue: uploadMode,
                onChanged: onUploadModeChanged
              ),
            ),
            Expanded(
              child: RadioListTile<UploadMode>(
                title: Text("Multiple"),
                value: UploadMode.MULTIPLE,
                groupValue: uploadMode,
                onChanged: onUploadModeChanged
              ),
            ),
          ],
        )
      ],
    );

  Widget get uploadSourceView =>
    Column(
      children: [
        Text("File source"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: RadioListTile<FileSource>(
                title: Text("Path"),
                value: FileSource.PATH,
                groupValue: fileSource,
                onChanged: onUploadSourceChanged
              ),
            ),
            Expanded(
              child: RadioListTile<FileSource>(
                title: Text("Bytes"),
                value: FileSource.BYTES,
                groupValue: fileSource,
                onChanged: onUploadSourceChanged
              ),
            ),
          ],
        )
      ],
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Fotos from file',
                ),
                SizedBox(
                  height: 16,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(pathPhotos.length, (index) {
                    return Image.file(
                      File(pathPhotos[index]),
                      width: 100,
                      height: 100,
                    );
                  }),
                ),
                ElevatedButton(
                  onPressed: loading || pathPhotos.isEmpty
                      ? null
                      : () {
                          pathPhotos = [];
                          setState(() {});
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.deepPurple;
                    }),
                  ),
                  child: Text(
                    'Clear list',
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(
                  height: 48,
                ),
                Text(
                  'Fotos from cloudinary',
                ),
                SizedBox(
                  height: 16,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(urlPhotos.length, (index) {
                    final cloudinaryImage = CloudinaryImage(urlPhotos[index]);
                    String transformedUrl = cloudinaryImage
                        .transform()
                        .width(256)
                        .thumb()
                        .generate();
                    return Image.network(
                      transformedUrl,
                      width: 100,
                      height: 100,
                    );
                  })..add(
                    Visibility(
                      visible: loading,
                      child: Center(
                        child: CircularProgressIndicator(),
                      )),
                  ),
                ),
                SizedBox(
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
                        SizedBox(
                          height: 128,
                        ),
                      ],
                    )),
                ElevatedButton(
                  onPressed: loading || urlPhotos.isEmpty
                      ? null
                      : () {
                          urlPhotos = [];
                          setState(() {});
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.purple;
                    }),
                  ),
                  child: Text(
                    'Clear list',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 32,),
                uploadModeView,
                SizedBox(height: 16,),
                uploadSourceView,
                SizedBox(height: 32,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading ||
                                  (pathPhotos.isEmpty && urlPhotos.isEmpty)
                              ? null
                              : () {
                                  pathPhotos = [];
                                  urlPhotos = [];
                                  setState(() {});
                                },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                              return states.contains(MaterialState.disabled)
                                  ? null
                                  : Colors.deepOrange;
                            }),
                          ),
                          child: Text(
                            'Clear all',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading || pathPhotos.isEmpty
                              ? null
                              : () => onClick(uploadPhotos),
                          child: Text(
                            'Upload',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading || pathPhotos.isEmpty
                              ? null
                              : () => onClick(deleteUploadedPhotos),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                              return states.contains(MaterialState.disabled)
                                  ? null
                                  : Colors.red.shade600;
                            }),
                          ),
                          child: Text(
                            'Delete uploaded photos',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onClick(loadPhoto),
        tooltip: 'Choose photo',
        child: Icon(Icons.photo),
      ),
    );
  }

  onNewPhoto(String filePath) {
    if (filePath?.isNotEmpty ?? false) {
      pathPhotos.add(filePath);
      setState(() {});
    }
  }

  Future<List<int>> getFileBytes(String path) async {
    return await File(path).readAsBytes();
  }

  doSingleUpload() async {
    try {
      String filePath;
      List<int> fileBytes;

      switch(fileSource) {
        case FileSource.PATH:
          filePath = pathPhotos[0];
          break;
        case FileSource.BYTES:
          fileBytes = await getFileBytes(pathPhotos[0]);
          break;
      }

      CloudinaryResponse response = await cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: filePath,
          fileBytes: fileBytes,
          resourceType: CloudinaryResourceType.image,
          folder: cloudinaryCustomFolder,
          fileName: 'asd@asd.com'
        )
      );

      if ((response.isSuccessful ?? false) &&
          (response.secureUrl?.isNotEmpty ?? false))
        urlPhotos.add(response.secureUrl);
      else {
        errorMessage = response?.error;
      }
    } catch (e) {
      errorMessage = e?.toString();
      print(e);
    }
  }

  doMultipleUpload() async {
    try {
      List<CloudinaryUploadResource> resources = [];

      resources = await Future.wait(pathPhotos?.map((path) async =>
          CloudinaryUploadResource(
            filePath: fileSource == FileSource.PATH ? path : null,
            fileBytes: fileSource == FileSource.BYTES
                ? await getFileBytes(path)
                : null,
            resourceType: CloudinaryResourceType.image,
            folder: cloudinaryCustomFolder,
          )));

      List<CloudinaryResponse> responses = await cloudinary.uploadResources(
          resources);
      responses.forEach((response) {
        if (response.isSuccessful ?? false)
          urlPhotos.add(response.secureUrl);
        else {
          errorMessage = response?.error;
        }
      });
    } catch (e) {
      errorMessage = e?.toString();
      print(e);
    }
  }

  upload() {
    showLoading();
    switch(uploadMode) {
      case UploadMode.MULTIPLE: return doMultipleUpload();
      case UploadMode.SINGLE: return doSingleUpload();
    }
  }

  void onClick(int id) async {
    errorMessage = null;
    try {
      switch (id) {
        case loadPhoto:
          AlertUtils.showImagePickerModal(
            context: context,
            onImageFromCamera: () async {
              onNewPhoto(await handleImagePickerResponse(
                  ImageUtils.takePhoto(cameraDevice: CameraDevice.rear)));
            },
            onImageFromGallery: () async {
              onNewPhoto(await handleImagePickerResponse(
                  ImageUtils.pickImageFromGallery()));
            },
          );
          break;
        case uploadPhotos:
          await upload();
          break;
        case deleteUploadedPhotos:
          showLoading();
          CloudinaryResponse response = await cloudinary.deleteFiles(
              urls: urlPhotos, resourceType: CloudinaryResourceType.image);

          if (response.isSuccessful ?? false) {
            urlPhotos = [];
            //Check for deleted status...
//            Map<String, dynamic> deleted = response.deleted;
          } else {
            errorMessage = response?.error;
          }

          //This is another approach...
//          for(int i = 0; i < urlPhotos.length; i++){
//            String url = urlPhotos[i];
//            final response = await cloudinary.deleteFile(
//              url: url,
//              resourceType: CloudinaryResourceType.image,
//              invalidate: false,
//            );
//            if(response.isSuccessful ?? false){
//              urlPhotos.remove(url);
//              --i;
//            }
//          }
          break;
      }
    } catch (e) {
      print(e);
      loading = false;
      setState(() => errorMessage = e?.toString());
    } finally {
      if (loading) hideLoading();
    }
  }

  showLoading() => setState(() => loading = true);

  hideLoading() => setState(() => loading = false);

  Future<String> handleImagePickerResponse(Future getImageCall) async {
    Map<String, dynamic> resource = await getImageCall;
    if (resource?.isEmpty ?? true) return null;
    switch (resource['status']) {
      case 'SUCCESS':
        Navigator.pop(context);
        return resource['data'].path;
        break;
      default:
        ImageUtils.showPermissionExplanation(
            context: context, message: resource['message']);
        break;
    }
    return null;
  }
}
