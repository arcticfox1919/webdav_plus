/// WebDAV Plus - A comprehensive WebDAV client library for Dart
///
/// This library provides a complete WebDAV client implementation following
/// the WebDAV protocol specifications (RFC 4918 and related RFCs).
///
/// Features:
/// - Full WebDAV protocol support (PROPFIND, PROPPATCH, MKCOL, DELETE, etc.)
/// - HTTP Basic Authentication with preemptive and challenge-response modes
/// - File upload/download operations
/// - Directory listing and property management
/// - WebDAV locking support
/// - Custom property handling
/// - Search operations
/// - Report generation
/// - Access Control List (ACL) support
/// - Quota management
///
/// Usage:
/// ```dart
/// import 'package:webdav_plus/webdav_plus.dart';
///
/// // Create a client with authentication
/// WebdavClient client = WebdavClient.withCredentials('username', 'password');
///
/// // List directory contents
/// List<DavResource> resources = await client.list('https://webdav.example.com/path/');
///
/// // Upload a file
/// await client.put('https://webdav.example.com/file.txt', utf8.encode('Hello World'));
///
/// // Create a directory
/// await client.createDirectory('https://webdav.example.com/newdir/');
/// ```
library webdav_plus;

// Core interfaces
export 'src/webdav_client.dart';

// Authentication handlers
export 'src/auth/authentication_handler.dart';

// Data models
export 'src/dav_resource.dart';
export 'src/dav_ace.dart';
export 'src/dav_acl.dart';
export 'src/dav_principal.dart';
export 'src/dav_quota.dart';

// Report system
export 'src/report/webdav_report.dart';

// XML Models (for advanced usage)
export 'src/model/propfind.dart';
export 'src/model/multistatus.dart';
export 'src/model/response.dart';
export 'src/model/propstat.dart';
export 'src/model/error.dart';
export 'src/model/lockinfo.dart';
export 'src/model/acl.dart';
export 'src/model/search.dart';
export 'src/model/proppatch.dart';
export 'src/model/lock.dart';
export 'src/model/properties.dart'
    hide Supportedlock, Lockentry, Lockdiscovery, ActivelockProperty;
export 'src/model/sync.dart';
export 'src/model/reports.dart';
export 'src/model/privileges.dart';
export 'src/model/binding.dart';

// Exceptions
export 'src/webdav_exception.dart';

// Utilities (for advanced usage)
export 'src/util/webdav_util.dart';
