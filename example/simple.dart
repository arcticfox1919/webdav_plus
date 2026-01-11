import 'dart:convert';
import 'dart:io';
import 'package:webdav_plus/webdav_plus.dart';

/// Simple WebDAV CRUD operations demo
void main() async {
  // Create client with base URL and authentication
  // All subsequent paths can be relative to this base URL
  // Note: isPreemptive is required for streaming uploads (putFileStream, putStream)
  final client = WebdavClient.withCredentials(
    'username',
    'password',
    baseUrl: 'https://webdav.example.com/test',
    isPreemptive: true, // Required for streaming uploads
  );

  try {
    // ==================== CREATE ====================

    // Create a directory (if not exists)
    // Note: paths are relative to baseUrl
    if (!await client.exists('/my_folder')) {
      await client.createDirectory('/my_folder/');
      print('✓ Directory created');
    } else {
      print('✓ Directory already exists');
    }

    // Upload a file (if not exists)
    if (!await client.exists('/my_folder/hello.txt')) {
      final content = utf8.encode('Hello, WebDAV!');
      await client.put('/my_folder/hello.txt', content);
      print('✓ File uploaded');
    } else {
      print('✓ File already exists');
    }

    // Upload local file with progress tracking (for large files, memory efficient)
    final localFile = File('/path/to/local/video.mp4');
    await client.putFileStream(
      '/my_folder/video.mp4',
      localFile,
      onProgress: (sent, total) {
        print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
      },
    );
    print('✓ Large file uploaded with progress');

    // ==================== READ ====================

    // List directory contents
    final resources = await client.list('/my_folder/');
    print('✓ Directory listing (${resources.length} items):');
    for (final res in resources) {
      final name = res.name.isEmpty ? '(root)' : Uri.decodeComponent(res.name);
      final path = Uri.decodeComponent(res.path);
      print('  - $name (${res.isDirectory ? "folder" : "file"}) path: $path');
    }

    // Download file content
    final data = await client.get('/my_folder/hello.txt');
    print('✓ File content: ${utf8.decode(data)}');

    // Download large file to disk with progress tracking (memory efficient)
    await client.downloadToFile(
      '/my_folder/video.mp4',
      '/path/to/save/video.mp4',
      onProgress: (received, total) {
        final progress = total > 0 ? (received / total * 100) : 0;
        print('Download progress: ${progress.toStringAsFixed(1)}%');
      },
    );
    print('✓ Large file downloaded with progress');

    // ==================== UPDATE ====================

    // Update file content
    final newContent = utf8.encode('Hello, WebDAV! (Updated)');
    await client.put('/my_folder/hello.txt', newContent);
    print('✓ File updated');

    // // Update custom properties
    await client.patch('/my_folder/hello.txt', {
      'author': 'WebDAV User',
      'description': 'A simple text file',
    });
    print('✓ Properties updated');

    // // ==================== DELETE ====================

    // // Delete file
    await client.delete('/my_folder/hello.txt');
    print('✓ File deleted');

    // Delete directory
    await client.delete('/my_folder/');
    print('✓ Directory deleted');

    print('\n🎉 All CRUD operations completed successfully!');
  } on WebDAVException catch (e) {
    print('WebDAV error: ${e.message} (status: ${e.statusCode})');
  } catch (e) {
    print('Error: $e');
  }
}
