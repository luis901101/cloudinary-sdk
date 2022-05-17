# cloudinary_sdk

This is a pure dart package for Cloudinary API that allows you to do signed and unsigned uploads to your cloudinary cloud.

## Description
This package is intended to be used for signed and unsigned uploads to your cloud, it allows you to destroy/delete files and makes it easy to access image url with transformations

## Installation
The first thing is to add **cloudinary_sdk** as a dependency of your project, for this you can use the command:

**For purely Dart projects**
```shell
dart pub add cloudinary_sdk
```
**For Flutter projects**
```shell
flutter pub add cloudinary_sdk
```
This command will add **cloudinary_sdk** to the **pubspec.yaml** of your project.
Finally you just have to run:

`dart pub get` **or** `flutter pub get` depending on the project type and this will download the dependency to your pub-cache

## How to use
### Initialize a Cloudinary object
```dart
/// This three params can be obtained directly from your Cloudinary account Dashboard.
/// The .full(...) factory constructor is recommended only for server side apps, where [apiKey] and 
/// [apiSecret] are secure. 
final cloudinary = Cloudinary.full(
  apiKey: apiKey,
  apiSecret: apiSecret,
  cloudName: cloudName,
);
```
or
```dart
/// The .basic(...) factory constructor is recommended for client side apps, where [apiKey] and 
/// [apiSecret] must not be used, so .basic(...) constructor allows to do later unsigned requests.
final cloudinary = Cloudinary.basic(
  cloudName: cloudName,
);
```
Optionally you can pass an `apiUrl` as well, but it's not required because this package uses by default https://api.cloudinary.com/v1_1 which is the current apiUrl at the time of writing this.


### Do a single file signed upload
Recommended only for server side apps.
```dart
  final response = await cloudinary.uploadResource(
    CloudinaryUploadResource(
      filePath: file.path,
      fileBytes: file.readAsBytesSync(),
      resourceType: CloudinaryResourceType.image,
      folder: cloudinaryCustomFolder,
      fileName: 'some-name',
      progressCallback: (count, total) {
        print(
          'Uploading image from file with progress: $count/$total');
        })
      )
  );

  if(response.isSuccessful) {
    print('Get your image from with ${response.secureUrl}');  
  }
    
```
You can upload a file from path or byte array representation, you can also pass an `optParams` map to do a more elaborated upload according to https://cloudinary.com/documentation/image_upload_api_reference
The `cloudinary.uploadResource(...)` function is fully documented, you can check the description to know what other options you have.

### Do multiple file signed upload
Recommended only for server side apps.
```dart
  final resources = await Future.wait(files?.map((file) async =>
      CloudinaryUploadResource(
        filePath: file.path,
        fileBytes: file.readAsBytesSync(),
        resourceType: CloudinaryResourceType.image,
        folder: cloudinaryCustomFolder,
        progressCallback: (count, total) {
            print(
              'Uploading image from file with progress: $count/$total');
            })
        )
      )));
  List<CloudinaryResponse> responses = await cloudinary.uploadResources(resources);

  responses.forEach((response) {
    if(response.isSuccessful) {
      print('Get your image from with ${response.secureUrl}');    
    }
  });
```
This function does repeatedly calls to `cloudinary.uploadResource(...)` described above.


### Do a single file unsigned upload
Recommended for server client side apps.
The way to do this request is almost the same as above, the only difference is the `uploadPreset` which is required for unsigned uploads.
```dart
  final response = await cloudinary.unsignedUploadResource(
    CloudinaryUploadResource(
      uploadPreset: somePreset,
      filePath: file.path,
      fileBytes: file.readAsBytesSync(),
      resourceType: CloudinaryResourceType.image,
      folder: cloudinaryCustomFolder,
      fileName: 'some-name',
      progressCallback: (count, total) {
        print(
          'Uploading image from file with progress: $count/$total');
        })
      )
  );

  if(response.isSuccessful) {
    print('Get your image from with ${response.secureUrl}');  
  }
    
```
You can upload a file from path or byte array representation, you can also pass an `optParams` map to do a more elaborated upload according to https://cloudinary.com/documentation/image_upload_api_reference
The `cloudinary.uploadResource(...)` function is fully documented, you can check the description to know what other options you have.

### Do multiple file unsigned upload
Recommended for server client side apps.
The way to do this request is almost the same as above, the only difference is the `uploadPreset` which is required for unsigned uploads.
```dart
  final resources = await Future.wait(files?.map((file) async =>
      CloudinaryUploadResource(
        uploadPreset: somePreset,
        filePath: file.path,
        fileBytes: file.readAsBytesSync(),
        resourceType: CloudinaryResourceType.image,
        folder: cloudinaryCustomFolder,
        progressCallback: (count, total) {
            print(
              'Uploading image from file with progress: $count/$total');
            })
        )
      )));
  List<CloudinaryResponse> responses = await cloudinary.uploadResources(resources);

  responses.forEach((response) {
    if(response.isSuccessful) {
      print('Get your image from with ${response.secureUrl}');    
    }
  });
```
This function does repeatedly calls to `cloudinary.uploadResource(...)` described above.

### Do a single file delete *(this will use the cloudinary destroy method)*
```dart
    final response = await cloudinary.deleteResource(
      url: url,
      resourceType: CloudinaryResourceType.image,
      invalidate: false,
    );
    if(response.isSuccessful ?? false){
      //Do something else
    }
```
To delete a cloudinary file it´s necessary a `public_id`, as you can see in the sample code the `deleteResource(...)` function can delete a file by it's url...
You can also pass an `optParams` map to do a more elaborated delete *(destroy)* according to https://cloudinary.com/documentation/image_upload_api_reference#destroy_method
The `cloudinary.deleteResource(...)` function is fully documented, you can check the description to know what other options you have.

### Do a multiple files delete *(this will use the cloudinary delete resources method)*
```dart
    final response = await cloudinary.deleteResources(
        urls: urlPhotos,
        resourceType: CloudinaryResourceType.image
      );
    if(response.isSuccessful ?? false){
      Map<String, dynamic> deleted = response.deleted;//in deleted Map you will find all the public ids and the status 'deleted'
    }

```
To delete multiple cloudinary files it´s necessary a list of `public_id's`, as you can see in the sample code the `deleteResources(...)` function can delete files from a list of urls...
You can also pass an `optParams` map to do a more elaborated delete according to https://cloudinary.com/documentation/admin_api#delete_resources
The `cloudinary.deleteResources(...)` function is fully documented, you can check the description to know what other options you have.

### Load an Image from cloudinary with some transformations
```
    final cloudinaryImage = CloudinaryImage(url);
    String transformedUrl = cloudinaryImage.transform().width(256).height(256).thumb().face().opacity(30).angle(45).generate();
    return Image.network(transformedUrl);
```

### Note:
It's recommended to check the tests and example code for a better idea of how to work with this package.