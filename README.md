# cloudinary_sdk

This is a dart package for Cloudinary API that allows you to upload and manage files in your cloudinary cloud.

## Description
This package is intended to be used for signed uploading to your cloud, it allows you to destroy/delete files and makes it easy to access image url with transformations

## How to use

### Add dependency
```yaml
# Add this line to your flutter project dependencies
cloudinary_sdk: ^1.0.0+1
```
and run `flutter pub get` to download the library sources to your pub-cache.

### Initialize a Cloudinary object
```dart
final cloudinary = Cloudinary(
      <YOUR_API_KEY>,
      <YOUR_API_SECRET>,
      <YOUR_CLOUD_NAME>
    );
```
This three params can be obtained directly from your Cloudinary account Dashboard.

### Do a single file upload

```dart
  final response = await cloudinary.uploadFile(
    filePath: filePath,
    resourceType: CloudinaryResourceType.image,
    folder: cloudinaryCustomFolder,
  );

  //OR

  final response = await cloudinary.uploadFile(
    fileBytes: fileBytes,
    resourceType: CloudinaryResourceType.image,
    folder: cloudinaryCustomFolder,
  );

  //OR

  final response = await cloudinary.uploadResource(
    CloudinaryUploadResource(
      filePath: filePath,
      fileBytes: fileBytes,
      resourceType: CloudinaryResourceType.image,
      folder: cloudinaryCustomFolder,
      fileName: 'asd@asd.com'
    )
  );

  if(response.isSuccessful ?? false)
    urlPhotos.add(response.secureUrl);
```
You can upload a file from path or byte array representation, you can also pass an `optParams` map to do a more elaborated upload according to https://cloudinary.com/documentation/image_upload_api_reference
The cloudinary.uploadFile(...) function is fully documented, you can check the description to know what other options you have.

### Do a multiple file upload

```dart
  List<CloudinaryResponse> responses = await cloudinary.uploadFiles(
    filePaths: filePaths,
    resourceType: CloudinaryResourceType.image,
    folder: cloudinaryCustomFolder,
  );

  //OR
  
  List<CloudinaryResponse> responses = await cloudinary.uploadFiles(
    filesBytes: filesBytes,
    resourceType: CloudinaryResourceType.image,
    folder: cloudinaryCustomFolder,
  );

  //OR
  
  final resources = await Future.wait(pathPhotos?.map((path) async =>
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
    if(response.isSuccessful ?? false)
      urlPhotos.add(response.secureUrl);
  });
```
This function does repeatedly calls to cloudinary.uploadFile(...) / cloudinary.uploadResource(...) described in the step above.

### Do a single file delete *(this will use the cloudinary destroy method)*

```dart
    final response = await cloudinary.deleteFile(
      url: url,
      resourceType: CloudinaryResourceType.image,
      invalidate: false,
    );
    if(response.isSuccessful ?? false){
      //Do something else
    }
```
To delete a cloudinary file it´s necessary a `public_id`, as you can see in the sample code the deleteFile(...) function can delete a file by it's url...
You can also pass an `optParams` map to do a more elaborated delete *(destroy)* according to https://cloudinary.com/documentation/image_upload_api_reference#destroy_method
The cloudinary.deleteFile(...) function is fully documented, you can check the description to know what other options you have.

### Do a multiple files delete *(this will use the cloudinary delete resources method)*

```dart
    final response = await cloudinary.deleteFiles(
        urls: urlPhotos,
        resourceType: CloudinaryResourceType.image
      );
    if(response.isSuccessful ?? false){
      Map<String, dynamic> deleted = response.deleted;//in deleted Map you will find all the public ids and the status 'deleted'
    }

```
To delete multiple cloudinary files it´s necessary a list of `public_id's`, as you can see in the sample code the deleteFiles(...) function can delete files from a list of urls...
You can also pass an `optParams` map to do a more elaborated delete according to https://cloudinary.com/documentation/admin_api#delete_resources
The cloudinary.deleteFiles(...) function is fully documented, you can check the description to know what other options you have.

### Load an Image from cloudinary with some transformations

```
    final cloudinaryImage = CloudinaryImage(urlPhotos[index]);
    String transformedUrl = cloudinaryImage.transform().width(256).height(256).thumb().face().opacity(30).angle(45).generate();
    return Image.network(transformedUrl);
```

### Note:
It's recommended to check the example code for a better idea of how to work with this package.