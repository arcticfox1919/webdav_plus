import 'dart:convert';
import 'dart:typed_data';
import 'package:webdav_plus/webdav_plus.dart';

/// Example of custom report implementation
class CustomReport implements WebDAVReport<List<String>> {
  @override
  String toXml() {
    return '''<?xml version="1.0" encoding="utf-8"?>
<C:custom-report xmlns:C="http://example.com/ns">
  <C:prop>
    <D:displayname xmlns:D="DAV:"/>
    <D:getcontenttype xmlns:D="DAV:"/>
  </C:prop>
</C:custom-report>''';
  }

  @override
  String generateRequestBody() => toXml();

  @override
  String? getDepth() => null;

  @override
  Map<String, String> getHeaders() => {};

  @override
  List<String> parseResponse(String responseXml) {
    // Parse the XML response and extract relevant data
    // This is a simplified example
    return ['result1', 'result2', 'result3'];
  }
}

/// Example demonstrating WebDAV Plus library usage
void main() async {
  // Create a WebDAV client with credentials
  WebdavClient client = WebdavClient.withCredentials(
    'username',
    'password',
    isPreemptive: true, // Use preemptive authentication
  );

  // Enable compression for better performance
  client.enableCompression();

  String baseUrl = 'https://webdav.example.com/';

  try {
    // Example 1: Check if server is accessible
    print('Checking server accessibility...');
    bool serverExists = await client.exists(baseUrl);
    print('Server accessible: $serverExists');

    // Example 2: List directory contents
    print('\nListing directory contents...');
    List<DavResource> resources = await client.list(baseUrl);
    for (DavResource resource in resources) {
      print(
        '${resource.isDirectory ? '[DIR]' : '[FILE]'} ${resource.name} '
        '(${resource.contentLength} bytes, modified: ${resource.modified})',
      );
    }

    // Example 3: Create a new directory
    String newDirUrl = '${baseUrl}test-directory/';
    print('\nCreating directory: $newDirUrl');
    await client.createDirectory(newDirUrl);
    print('Directory created successfully');

    // Example 4: Upload a text file
    String fileUrl = '${newDirUrl}hello.txt';
    String content =
        'Hello, WebDAV World!\nThis is a test file created by WebDAV2 library.';
    Uint8List data = utf8.encode(content);

    print('\nUploading file: $fileUrl');
    await client.putWithContentType(fileUrl, data, 'text/plain; charset=utf-8');
    print('File uploaded successfully');

    // Example 5: Download the file back
    print('\nDownloading file...');
    Uint8List downloadedData = await client.get(fileUrl);
    String downloadedContent = utf8.decode(downloadedData);
    print('Downloaded content: $downloadedContent');

    // Example 6: Get detailed resource information
    print('\nGetting detailed resource information...');
    List<DavResource> fileInfo = await client.listWithDepth(fileUrl, 0);
    if (fileInfo.isNotEmpty) {
      DavResource file = fileInfo.first;
      print('File details:');
      print('  Name: ${file.name}');
      print('  Size: ${file.contentLength} bytes');
      print('  Content-Type: ${file.contentType}');
      print('  ETag: ${file.etag}');
      print('  Last Modified: ${file.modified}');
      print('  Creation Date: ${file.creation}');
    }

    // Example 7: Set custom properties
    print('\nSetting custom properties...');
    Map<String, String> customProps = {
      'author': 'WebDAV2 Library',
      'category': 'example',
      'version': '1.0',
    };
    await client.patch(fileUrl, customProps);
    print('Custom properties set');

    // Example 8: Search for files (if server supports it)
    try {
      print('\nSearching for files...');
      List<DavResource> searchResults = await client.search(
        baseUrl,
        'sql',
        'SELECT * FROM SCOPE() WHERE "DAV:getcontenttype" LIKE \'text/%\'',
      );
      print('Found ${searchResults.length} text files');
    } catch (e) {
      print('Search not supported or failed: $e');
    }

    // Example 9: Copy the file
    String copyUrl = '${newDirUrl}hello-copy.txt';
    print('\nCopying file to: $copyUrl');
    await client.copy(fileUrl, copyUrl);
    print('File copied successfully');

    // Example 10: Lock a resource
    try {
      print('\nLocking resource...');
      String lockToken = await client.lock(fileUrl);
      print('Resource locked with token: $lockToken');

      // Unlock the resource
      print('Unlocking resource...');
      await client.unlock(fileUrl, lockToken);
      print('Resource unlocked successfully');
    } catch (e) {
      print('Locking not supported or failed: $e');
    }

    // Example 11: Move the copy
    String moveUrl = '${baseUrl}moved-hello.txt';
    print('\nMoving file to: $moveUrl');
    await client.move(copyUrl, moveUrl);
    print('File moved successfully');

    // Example 12: Clean up - delete created resources
    print('\nCleaning up...');
    await client.delete(moveUrl);
    await client.delete(fileUrl);
    await client.delete(newDirUrl);
    print('Cleanup completed');

    print('\nWebDAV2 example completed successfully!');
  } catch (e) {
    print('Error occurred: $e');
    if (e is WebDAVException) {
      print('HTTP Status: ${e.statusCode}');
      print('Response Body: ${e.responseBody}');
    }
  }
}

/// Example of advanced usage with custom reports
void advancedExample() async {
  WebdavClient client = WebdavClient.configured(
    username: 'admin',
    password: 'password',
    isPreemptive: true,
    compression: true,
  );

  try {
    List<String> results = await client.report(
      'https://webdav.example.com/',
      1,
      CustomReport(),
    );
    print('Custom report results: $results');
  } catch (e) {
    print('Custom report failed: $e');
  }
}
