import 'dart:typed_data';
import 'dart:convert';
import '../lib/webdav_plus.dart';

/// Example demonstrating domain authentication and advanced WebDAV features
/// This example shows how to use the enhanced WebDAV client with NTLM domain authentication
Future<void> main() async {
  // Create a WebDAV client instance
  final client = WebdavClient();

  try {
    // Example 1: Basic authentication (as before)
    print('=== Basic Authentication Example ===');
    client.setCredentials('username', 'password', isPreemptive: true);

    // Example 2: Domain authentication (NEW FEATURE)
    print('=== Domain Authentication Example ===');
    client.setCredentialsWithDomain(
      'username', // Username
      'password', // Password
      'COMPANYDOMAIN', // Windows domain
      'WORKSTATION01', // Workstation name
      isPreemptive: true, // Enable preemptive auth for better performance
    );

    print('Domain authentication configured successfully!');
    print('Username will be sent as: COMPANYDOMAIN\\username');
    print('Workstation header will be set to: WORKSTATION01');

    // Example 3: Connect to a WebDAV server with domain auth
    const serverUrl = 'https://webdav.example.com/files/';

    // List directory contents
    print('\n=== Listing Directory Contents ===');
    try {
      final resources = await client.list(serverUrl);
      for (final resource in resources) {
        print('${resource.isDirectory ? '[DIR]' : '[FILE]'} ${resource.name}');
        print('  Path: ${resource.path}');
        print('  Size: ${resource.contentLength} bytes');
        print('  Modified: ${resource.modified ?? 'N/A'}');
        print('');
      }
    } catch (e) {
      print('Error listing directory: $e');
    }

    // Example 4: Upload a file with domain authentication
    print('=== File Upload Example ===');
    try {
      final testData = utf8.encode('Hello WebDAV World with Domain Auth!');
      await client.put(
        '${serverUrl}test-file.txt',
        Uint8List.fromList(testData),
      );
      print('File uploaded successfully with domain authentication!');
    } catch (e) {
      print('Error uploading file: $e');
    }

    // Example 5: Version-aware operations (NEW FEATURE)
    print('=== Version Control Example ===');
    try {
      final versionUrl = '${serverUrl}versioned-file.txt';

      // Create initial version
      await client.put(
        versionUrl,
        Uint8List.fromList(utf8.encode('Version 1 content')),
      );

      // Check out for editing (if server supports DeltaV)
      await client.checkout(versionUrl);

      // Make changes
      await client.put(
        versionUrl,
        Uint8List.fromList(utf8.encode('Version 2 content')),
      );

      // Check in new version
      await client.checkin(versionUrl);

      // List version history
      final versions = await client.versionsList(versionUrl);
      print('Version history:');
      for (final version in versions) {
        print('  - ${version.path} (${version.modified})');
      }
    } catch (e) {
      print('Error with version control operations: $e');
    }

    // Example 6: Advanced search capabilities (NEW FEATURE)
    print('=== Advanced Search Example ===');
    try {
      // Search for files containing specific text
      final searchResults = await client.search(
        serverUrl,
        'contentcontains',
        'domain authentication',
      );

      print('Files containing "domain authentication":');
      for (final result in searchResults) {
        print('  - ${result.path}');
      }
    } catch (e) {
      print('Error with search: $e');
    }

    // Example 7: Access Control Lists (ACL) management (NEW FEATURE)
    print('=== ACL Management Example ===');
    try {
      final fileUrl = '${serverUrl}protected-file.txt';

      // Get current ACL
      final acl = await client.getAcl(fileUrl);
      print('Current ACL has ${acl.aces.length} access control entries');

      // The ACL management would require proper ACE setup
      // This is a demonstration of the API availability
      print('ACL information retrieved successfully');
    } catch (e) {
      print('Error with ACL operations: $e');
    }

    // Example 8: Quota management (NEW FEATURE)
    print('=== Quota Information Example ===');
    try {
      final quota = await client.getQuota(serverUrl);
      print('Storage quota:');
      print('  Used: ${quota.quotaUsedBytes ?? 'Unknown'} bytes');
      print('  Available: ${quota.quotaAvailableBytes ?? 'Unknown'} bytes');
    } catch (e) {
      print('Error getting quota information: $e');
    }

    // Example 9: Locking operations (NEW FEATURE)
    print('=== File Locking Example ===');
    try {
      final fileUrl = '${serverUrl}locked-file.txt';

      // Lock the file
      final lockToken = await client.lock(fileUrl);
      print('File locked with token: $lockToken');

      // Refresh the lock
      await client.refreshLock(fileUrl, lockToken, '300'); // 5 minutes
      print('Lock refreshed successfully');

      // Unlock the file
      await client.unlock(fileUrl, lockToken);
      print('File unlocked successfully');
    } catch (e) {
      print('Error with locking operations: $e');
    }

    print('\n=== All Examples Completed ===');
    print(
      'The WebDAV client now supports all major features from the Java Sardine library:',
    );
    print('- Domain authentication with NTLM support');
    print('- Version control operations');
    print('- Advanced search capabilities');
    print('- Access control list management');
    print('- Quota information retrieval');
    print('- File locking and unlocking');
    print('- And much more!');
  } finally {
    // Clean up resources
    client.dispose();
  }
}

/// Helper class for search operations
class SearchProperty {
  final String property;
  final SearchRelation relation;
  final String value;

  SearchProperty(this.property, this.relation, this.value);
}

enum SearchRelation { equals, like, greaterThan, lessThan }

enum SearchOperator { and, or }
