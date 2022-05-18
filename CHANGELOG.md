The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Types of changes
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

## 4.0.1+9
### Changed
- CloudinaryResponse updated with named argument constructor

## 4.0.0+8
### Added
- Unsigned uploads.
- ApiUrl param added to Cloudinary constructor
- ProgressCallback added to listen for resource uploads.

### Changed
- Breaking changes in `Cloudinary` constructor which now provides two factory .full() and .basic() constructors.

### Deprecated
- `deleteFiles` deprecated use `deleteResources` instead.
- `deleteFile` deprecated use `deleteResource` instead.
- `uploadFiles` deprecated use `uploadResources` instead.
- `uploadFile` deprecated use `uploadResource` instead. 

## 3.0.1+7
### Fixed
- Fixed bug in null-check operator on deleteFile function

## 3.0.0+6 (Breaking Change)
### Added
- Support for null-safety

### Changed
- Example updated with BATCH and ITERATIVE resource delete

### Fixed
- Fixed bug that prevented deleting multiple resources from a public_ids list

## 2.0.0+5 (Breaking Change)
### Added
- Support for upload file from byte array
- CloudinaryUploadResource class created to support uploadResource(...) and uploadResources(...) functions

### Changed
- uploadFile(...) function params changed
- uploadFiles(...) function params changed

## 1.0.3+4
### Fixed
- Fixed bug on uploadFile function that was ignoring optParams

## 1.0.2+3
### Fixed
- Fixed bug on **publicId** parsing from url on CloudinaryImage when url had encoded characters

## 1.0.1+2
### Changed
- Example app name changed

### Removed
- Removed unnecessary functions

## 1.0.0+1
- First release
