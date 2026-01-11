# WebDAV Plus - A Feature-Rich WebDAV Client Library for Dart

[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**WebDAV Plus** is a feature-rich WebDAV client library for Dart and Flutter. Compared to other Dart WebDAV libraries, it offers more comprehensive protocol support with modern Dart idioms, including locking, ACL, versioning, search, and synchronization capabilities.

## Why WebDAV Plus?

| Feature | WebDAV Plus | Other Dart Libraries |
|---------|-------------|---------------------|
| Core WebDAV (RFC 4918) | ✅ Supported | ✅ Partial |
| Locking (RFC 4918) | ✅ Supported | ❌ Limited |
| ACL (RFC 3744) | ✅ Supported | ❌ None |
| Versioning (RFC 3253) | ✅ Supported | ❌ None |
| Search (RFC 5323) | ✅ Basic | ❌ None |
| Sync (RFC 6578) | ✅ Basic | ❌ None |
| Quota (RFC 4331) | ✅ Supported | ❌ None |
| Streaming Support | ✅ Yes | ❌ Limited |
| Custom Auth Handlers | ✅ Extensible | ❌ Basic only |

## Features

### WebDAV Protocol Support
- **Core Operations**: PROPFIND, PROPPATCH, MKCOL, DELETE, PUT, GET, COPY, MOVE
- **Locking**: Exclusive/shared locks, lock refresh, lock discovery
- **Properties**: Full property management with custom namespace support

### Flexible Authentication System
- HTTP Basic Authentication with preemptive mode
- Domain authentication (NTLM-style username format)
- **Extensible auth handler interface** - easily integrate custom authentication schemes (OAuth, Kerberos, etc.)

### Advanced Resource Management
- **ACL (Access Control Lists)**: Read/modify permissions, principal management
- **Quota**: Query storage usage and availability
- **Versioning (DeltaV)**: Check-in, check-out, version history, baselines
- **Search**: DASL-based content and property search
- **Sync Collection**: Efficient incremental synchronization

### Performance Optimized
- **Streaming downloads**: Memory-efficient large file handling
- **Streaming uploads**: Upload from streams with progress tracking
- **Compression**: Built-in gzip/deflate support
- **Connection reuse**: HTTP client connection pooling

### Robust Error Handling
- Hierarchical exception system with specific error types
- Detailed error messages with HTTP status codes
- Automatic retry support for transient failures

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  webdav_plus: ^1.0.0
```

Then run:
```bash
dart pub get
```

## Quick Start

### Basic Operations

```dart
import 'package:webdav_plus/webdav_plus.dart';

void main() async {
  // Create a client with credentials
  final client = WebdavClient.withCredentials('username', 'password');
  
  final baseUrl = 'https://webdav.example.com/';
  
  // List directory contents
  List<DavResource> resources = await client.list(baseUrl);
  for (final resource in resources) {
    print('${resource.isDirectory ? "[DIR]" : "[FILE]"} ${resource.name}');
  }
  
  // Upload a file
  await client.put(
    '${baseUrl}hello.txt',
    Uint8List.fromList(utf8.encode('Hello, WebDAV!')),
  );
  
  // Download a file
  Uint8List content = await client.get('${baseUrl}hello.txt');
  print(utf8.decode(content));
  
  // Create a directory
  await client.createDirectory('${baseUrl}new-folder/');
  
  // Move/Copy resources
  await client.move('${baseUrl}hello.txt', '${baseUrl}new-folder/hello.txt');
  await client.copy('${baseUrl}new-folder/hello.txt', '${baseUrl}backup.txt');
  
  // Delete a resource
  await client.delete('${baseUrl}backup.txt');
  
  // Check if resource exists
  bool exists = await client.exists('${baseUrl}new-folder/');
  
  // Clean up
  client.dispose();
}
```

### Creating Clients

```dart
// Basic client (no authentication)
final client = WebdavClient();

// With credentials (challenge-response mode)
final client = WebdavClient.withCredentials('user', 'pass');

// With preemptive authentication (sends credentials immediately)
final client = WebdavClient.withCredentials('user', 'pass', isPreemptive: true);

// With compression enabled
final client = WebdavClient.withCompression();

// Fully configured
final client = WebdavClient.configured(
  username: 'user',
  password: 'pass',
  isPreemptive: true,
  compression: true,
);
```

## Advanced Usage

### Streaming Operations (Large Files)

For memory-efficient handling of large files:

```dart
// Streaming download - returns Stream<List<int>>
Stream<List<int>> stream = await client.getStream(url);

// Download directly to file with progress
await client.downloadToFile(
  url,
  '/path/to/local/file.zip',
  onProgress: (received, total) {
    double progress = total > 0 ? (received / total * 100) : 0;
    print('Download progress: ${progress.toStringAsFixed(1)}%');
  },
);

// Streaming upload from file with progress
await client.putFileStream(
  url,
  '/path/to/local/large-file.zip',
  onProgress: (sent, total) {
    print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
  },
);
```

### File Locking

```dart
// Acquire an exclusive lock
String lockToken = await client.lock(url);

try {
  // Perform operations while holding the lock
  await client.put(url, newContent);
  
  // Refresh the lock (extend timeout)
  await client.refreshLock(url, lockToken, '3600'); // 1 hour
} finally {
  // Always release the lock
  await client.unlock(url, lockToken);
}

// Check if a resource is locked
bool isLocked = await client.isLocked(url);

// Discover existing locks
List<DavResource> lockedResources = await client.discoverLocks(url);
```

### Access Control Lists (ACL)

```dart
// Get current ACL
DavAcl acl = await client.getAcl(url);
for (final ace in acl.aces) {
  print('Principal: ${ace.principal}');
  print('Privileges: ${ace.grantedPrivileges}');
}

// Check current user's privileges
List<String> privileges = await client.getCurrentUserPrivileges(url);
print('Your privileges: $privileges');

// Validate if user has specific privilege
bool canWrite = await client.hasPrivilege(url, 'write');
```

### Version Control (DeltaV)

```dart
// Put a resource under version control
await client.versionControl(url);

// Check out for editing
await client.checkout(url);

// Make modifications...
await client.put(url, updatedContent);

// Check in to create a new version
await client.checkin(url);

// Get version history
List<DavResource> versions = await client.versionsList(url);
for (final version in versions) {
  print('Version: ${version.path} - ${version.modified}');
}

// Undo checkout
await client.uncheckout(url);
```

### Quota Information

```dart
DavQuota quota = await client.getQuota(url);
print('Used: ${quota.quotaUsedBytes} bytes');
print('Available: ${quota.quotaAvailableBytes} bytes');
```

### Search

```dart
// Search for files by content
List<DavResource> results = await client.search(
  baseUrl,
  'contentcontains',
  'important document',
);

// Search by property
List<DavResource> results = await client.search(
  baseUrl,
  'displayname',
  'report',
);
```

### Sync Collection

```dart
// Initial sync (get all resources)
(List<DavResource> resources, String syncToken) = 
    await client.syncCollection(url, null);

// Store syncToken for later...

// Incremental sync (get only changes since last sync)
(List<DavResource> changes, String newToken) = 
    await client.syncCollection(url, syncToken);
```

## Authentication

### Preemptive vs Challenge-Response

**Challenge-Response (default):**
- Client sends request without credentials
- Server responds with 401 and WWW-Authenticate header
- Client retries with Authorization header
- More secure but requires extra round-trip

**Preemptive:**
- Client sends credentials with first request
- Faster (no extra round-trip)
- Required for streaming uploads (stream can't be replayed)

```dart
// Preemptive authentication
client.setCredentials('user', 'pass', isPreemptive: true);
```

### Domain Authentication

For Windows/NTLM environments:

```dart
client.setCredentialsWithDomain(
  'username',
  'password',
  'DOMAIN',
  'WORKSTATION',
  isPreemptive: true,
);
```

### Custom Authentication Handler

Implement the `AuthenticationHandler` interface for custom auth schemes:

```dart
class MyOAuthHandler implements AuthenticationHandler {
  final String accessToken;
  
  MyOAuthHandler(this.accessToken);
  
  @override
  String get schemeName => 'Bearer';
  
  @override
  Future<Map<String, String>> authenticate(
    http.BaseRequest request,
    http.StreamedResponse? response,
  ) async {
    return {'Authorization': 'Bearer $accessToken'};
  }
  
  @override
  bool canHandle(String scheme) => scheme.toLowerCase() == 'bearer';
  
  @override
  bool get requiresChallenge => false;
}

// Use the custom handler
client.setAuthenticationHandler(MyOAuthHandler(token), isPreemptive: true);
```

## Error Handling

```dart
try {
  await client.get(url);
} on WebDAVNotFoundException catch (e) {
  print('Resource not found: ${e.message}');
} on WebDAVAuthenticationException catch (e) {
  print('Authentication failed: ${e.message}');
} on WebDAVForbiddenException catch (e) {
  print('Access forbidden: ${e.message}');
} on WebDAVConflictException catch (e) {
  print('Conflict (e.g., locked resource): ${e.message}');
} on WebDAVLockedException catch (e) {
  print('Resource is locked: ${e.message}');
} on WebDAVInsufficientStorageException catch (e) {
  print('Storage quota exceeded: ${e.message}');
} on WebDAVNetworkException catch (e) {
  print('Network error: ${e.message}');
} on WebDAVException catch (e) {
  print('WebDAV error: ${e.message} (HTTP ${e.statusCode})');
}
```

## API Reference

### Core Methods

| Method | Description |
|--------|-------------|
| `list(url)` | List directory contents |
| `listWithDepth(url, depth)` | List with specific depth (0, 1, infinity) |
| `get(url)` | Download resource content |
| `getStream(url)` | Download as stream (memory-efficient) |
| `put(url, data)` | Upload content |
| `putStream(url, stream, length)` | Upload from stream |
| `delete(url)` | Delete resource |
| `createDirectory(url)` | Create collection (directory) |
| `move(src, dest)` | Move/rename resource |
| `copy(src, dest)` | Copy resource |
| `exists(url)` | Check if resource exists |

### Locking Methods

| Method | Description |
|--------|-------------|
| `lock(url)` | Acquire exclusive lock |
| `unlock(url, token)` | Release lock |
| `refreshLock(url, token, timeout)` | Extend lock timeout |
| `isLocked(url)` | Check if locked |
| `discoverLocks(url)` | Find all locks |

### ACL Methods

| Method | Description |
|--------|-------------|
| `getAcl(url)` | Get access control list |
| `setAcl(url, aces)` | Set access control list |
| `getCurrentUserPrivileges(url)` | Get current user's privileges |
| `hasPrivilege(url, privilege)` | Check specific privilege |

### Version Control Methods

| Method | Description |
|--------|-------------|
| `versionControl(url)` | Put under version control |
| `checkout(url)` | Check out for editing |
| `checkin(url)` | Check in new version |
| `uncheckout(url)` | Cancel checkout |
| `versionsList(url)` | Get version history |

## Compatibility

- **Dart SDK**: >= 3.8.0
- **Flutter**: All platforms (iOS, Android, Web, Desktop)
- **Standards**: RFC 4918, RFC 3744, RFC 3253, RFC 5323, RFC 6578, RFC 4331

## License

MIT License - see [LICENSE](LICENSE) for details.


