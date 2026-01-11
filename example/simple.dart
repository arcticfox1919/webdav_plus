import 'dart:convert';
import 'package:webdav_plus/webdav_plus.dart';

/// Simple WebDAV CRUD operations demo
void main() async {
  // WebDAV server base URL
  const baseUrl = 'https://webdav.example.com/test';

  // Create client with authentication
  final client = WebdavClient.withCredentials('username', 'password');

  try {
    // ==================== CREATE ====================

    // Create a directory (if not exists)
    if (!await client.exists('$baseUrl/my_folder')) {
      await client.createDirectory('$baseUrl/my_folder/');
      print('✓ Directory created');
    } else {
      print('✓ Directory already exists');
    }

    // Upload a file (if not exists)
    if (!await client.exists('$baseUrl/my_folder/hello.txt')) {
      final content = utf8.encode('Hello, WebDAV!');
      await client.put('$baseUrl/my_folder/hello.txt', content);
      print('✓ File uploaded');
    } else {
      print('✓ File already exists');
    }

    // ==================== READ ====================

    // List directory contents
    final resources = await client.list('${baseUrl}/my_folder/');
    print('✓ Directory listing (${resources.length} items):');
    for (final res in resources) {
      final name = res.name.isEmpty ? '(root)' : Uri.decodeComponent(res.name);
      final path = Uri.decodeComponent(res.path);
      print('  - $name (${res.isDirectory ? "folder" : "file"}) path: $path');
    }

    // Download file content
    final data = await client.get('$baseUrl/my_folder/hello.txt');
    print('✓ File content: ${utf8.decode(data)}');

    // ==================== UPDATE ====================

    // Update file content
    final newContent = utf8.encode('Hello, WebDAV! (Updated)');
    await client.put('$baseUrl/my_folder/hello.txt', newContent);
    print('✓ File updated');

    // // Update custom properties
    await client.patch('$baseUrl/my_folder/hello.txt', {
      'author': 'WebDAV User',
      'description': 'A simple text file',
    });
    print('✓ Properties updated');

    // // ==================== DELETE ====================

    // // Delete file
    await client.delete('$baseUrl/my_folder/hello.txt');
    print('✓ File deleted');

    // Delete directory
    await client.delete('$baseUrl/my_folder/');
    print('✓ Directory deleted');

    print('\n🎉 All CRUD operations completed successfully!');
  } on WebDAVException catch (e) {
    print('WebDAV error: ${e.message} (status: ${e.statusCode})');
  } catch (e) {
    print('Error: $e');
  }
}
