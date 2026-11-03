import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:webdav_plus/webdav_plus.dart';

/// Size of the file used by the download tests.
const _fileSize = 4 * 1024 * 1024;

/// Number of bytes written to the response per chunk.
const _chunkSize = 64 * 1024;

/// A local WebDAV endpoint that sends the response body slowly, so a download
/// stays in flight long enough to be aborted.
class _SlowGetServer {
  _SlowGetServer(this._server) {
    _server.listen(_handle);
  }

  final HttpServer _server;
  int sentBytes = 0;

  String get baseUrl => 'http://127.0.0.1:${_server.port}';

  Future<void> _handle(HttpRequest request) async {
    try {
      if (request.method != 'GET') {
        request.response.statusCode = HttpStatus.ok;
        await request.response.close();
        return;
      }
      final response = request.response;
      response.contentLength = _fileSize;
      final chunk = Uint8List(_chunkSize);
      while (sentBytes < _fileSize) {
        final remaining = _fileSize - sentBytes;
        final length = remaining < _chunkSize ? remaining : _chunkSize;
        response.add(length == _chunkSize ? chunk : Uint8List.sublistView(chunk, 0, length));
        await response.flush();
        sentBytes += length;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      await response.close();
    } catch (_) {
      // The client may close the connection before the body is fully sent.
    }
  }

  Future<void> close() => _server.close(force: true);
}

WebdavClient _createClient(_SlowGetServer server) {
  return WebdavClient.withCredentials(
    'user',
    'pass',
    baseUrl: server.baseUrl,
    isPreemptive: true,
  );
}

/// Waits for [download] and returns either its error or null when it succeeds.
Future<Object?> _captureError(Future<File> download) {
  return download.then<Object?>((_) => null, onError: (Object error) => error);
}

void main() {
  late _SlowGetServer server;
  late Directory tempDir;
  late String savePath;

  setUp(() async {
    server = _SlowGetServer(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
    tempDir = await Directory.systemTemp.createTemp('webdav_download_test');
    savePath = '${tempDir.path}/out.bin';
  });

  tearDown(() async {
    await server.close();
    await tempDir.delete(recursive: true);
  });

  test('downloadToFile aborts the download when abortTrigger completes', () async {
    final client = _createClient(server);
    final abortTrigger = Completer<void>();
    final download = client.downloadToFile(
      '/dir/big.bin',
      savePath,
      abortTrigger: abortTrigger.future,
    );

    await Future<void>.delayed(const Duration(milliseconds: 200));
    final abortedAt = DateTime.now();
    abortTrigger.complete();
    final error = await _captureError(download);
    final elapsedMs = DateTime.now().difference(abortedAt).inMilliseconds;

    expect(error, isA<WebDAVNetworkException>());
    expect(
      (error as WebDAVNetworkException).cause,
      isA<http.RequestAbortedException>(),
    );
    expect(elapsedMs, lessThan(1500));
    // The partially written file must be released so callers can delete it.
    final saved = File(savePath);
    expect(await saved.exists(), isTrue);
    expect(await saved.length(), lessThan(_fileSize));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('downloadToFile saves the whole file when abortTrigger does not complete',
      () async {
    final client = _createClient(server);
    final abortTrigger = Completer<void>();

    await client.downloadToFile(
      '/dir/big.bin',
      savePath,
      abortTrigger: abortTrigger.future,
    );

    expect(await File(savePath).length(), _fileSize);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
