/// Example demonstrating the enhanced WebDAV Plus client features
///
/// This example shows how to use the new features added to match
/// the Java Sardine library functionality.
library;

import 'dart:typed_data';
import 'package:webdav_plus/webdav_plus.dart';

void main() async {
  // Create a WebDAV client
  final client = WebdavClient.withCredentials('username', 'password');

  try {
    // Example 1: Version listing (new feature)
    print('Getting versions list...');
    final versions = await client.versionsList(
      'https://webdav.example.com/file.txt',
    );
    print('Found ${versions.length} versions');

    // Example 2: Get specific version of a file (new feature)
    print('Getting specific version...');
    final versionData = await client.getVersion(
      'https://webdav.example.com/file.txt',
      'version-1.0',
    );
    print('Version data size: ${versionData.length} bytes');

    // Example 3: NTLM authentication support (new feature)
    client.setCredentialsWithDomain(
      'username',
      'password',
      'DOMAIN',
      'WORKSTATION',
    );

    // Example 4: PUT with custom headers (new feature)
    final data = Uint8List.fromList('Hello WebDAV!'.codeUnits);
    await client.putWithHeaders(
      'https://webdav.example.com/new-file.txt',
      data,
      {'X-Custom-Header': 'custom-value'},
    );

    // Example 5: DELETE with headers (new feature)
    await client.deleteWithHeaders('https://webdav.example.com/temp-file.txt', {
      'X-Delete-Reason': 'cleanup',
    });

    // Example 6: Enhanced authentication control (new features)
    client.enablePreemptiveAuthentication('webdav.example.com');
    client.ignoreCookies();

    // Example 7: Advanced copy/move operations (new features)
    await client.moveWithHeaders(
      'https://webdav.example.com/source.txt',
      'https://webdav.example.com/dest.txt',
      true,
      {'X-Move-Reason': 'reorganization'},
    );

    await client.copyWithHeaders(
      'https://webdav.example.com/source.txt',
      'https://webdav.example.com/backup.txt',
      true,
      {'X-Backup-Type': 'automatic'},
    );

    // Example 8: Content length control (new feature)
    await client.putWithContentLength(
      'https://webdav.example.com/large-file.bin',
      data,
      'application/octet-stream',
      true, // expect continue
      data.length,
    );

    print('All operations completed successfully!');
  } catch (e) {
    print('Error: $e');
  } finally {
    // Clean up resources (new feature)
    client.shutdown();
  }
}

/// Example of version control operations
void versionControlExample() async {
  final client = WebdavClient.withCredentials('username', 'password');

  try {
    final url = 'https://webdav.example.com/versioned-file.txt';

    // Put file under version control
    await client.versionControl(url);

    // Check out for editing
    await client.checkout(url);

    // Make changes (upload new content)
    final newContent = Uint8List.fromList('Updated content'.codeUnits);
    await client.put(url, newContent);

    // Check in to create new version
    final newVersionUrl = await client.checkin(url);
    print('Created new version: $newVersionUrl');

    // Get version history
    final versionHistory = await client.getVersionHistory(url);
    print('Version history: $versionHistory');

    // List all versions with properties
    final versionsWithProps = await client.versionsListWithProps(url, 1, {
      'version-name',
      'creator-displayname',
      'creation-date',
    });

    for (final version in versionsWithProps) {
      print('Version: ${version.href}, Created: ${version.creation}');
    }
  } catch (e) {
    print('Version control error: $e');
  } finally {
    client.shutdown();
  }
}
