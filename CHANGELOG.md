## 1.2.1

* Lowered `meta` package dependency to ^1.16.0 for broader compatibility

## 1.2.0

* Added `baseUrl` parameter to constructors for cleaner API with relative paths
* Made `contentType` optional in `putFileStream` with auto-detection from file extension
* Improved API documentation, especially for `isPreemptive` requirement in streaming uploads

## 1.1.0

* Fixed XML namespace parsing to support various prefix formats (D:, d:, no prefix) for better server compatibility
* Renamed privilege classes with clearer naming (e.g., ReadPrivilege, BindPrivilege) to avoid conflicts with binding.dart
* Added CRUD example (example/simple.dart) and improved API documentation

## 1.0.0

* Comprehensive WebDAV protocol client with file operations, directory management, property handling, locking, ACL, quota support and extensible authentication

