import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:webdav_plus/webdav_plus.dart';

/// Size of the file used by the upload tests.
const _fileSize = 4 * 1024 * 1024;

/// A local WebDAV endpoint that reads the request body slowly, so an upload
/// stays in flight long enough to be aborted.
class _SlowPutServer {
  _SlowPutServer(this._server) {
    _server.listen(_handle);
  }

  final HttpServer _server;
  int receivedBytes = 0;

  String get baseUrl => 'http://127.0.0.1:${_server.port}';

  Future<void> _handle(HttpRequest request) async {
    try {
      if (request.method == 'PUT') {
        await for (final chunk in request) {
          receivedBytes += chunk.length;
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        request.response.statusCode = HttpStatus.created;
      } else {
        request.response.statusCode = HttpStatus.ok;
      }
    } catch (_) {
      // The client may close the connection while the body is being read.
    } finally {
      try {
        await request.response.close();
      } catch (_) {
        // The connection is already gone.
      }
    }
  }

  Future<void> close() => _server.close(force: true);
}

WebdavClient _createClient(_SlowPutServer server) {
  return WebdavClient.withCredentials(
    'user',
    'pass',
    baseUrl: server.baseUrl,
    isPreemptive: true,
  );
}

/// Waits for [upload] and returns either its error or null when it succeeds.
Future<Object?> _captureError(Future<void> upload) {
  return upload.then<Object?>((_) => null, onError: (Object error) => error);
}

void main() {
  late _SlowPutServer server;
  late Directory tempDir;
  late File file;

  setUp(() async {
    server = _SlowPutServer(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
    tempDir = await Directory.systemTemp.createTemp('webdav_abort_test');
    file = File('${tempDir.path}/big.bin');
    await file.writeAsBytes(List<int>.filled(_fileSize, 7));
  });

  tearDown(() async {
    await server.close();
    await tempDir.delete(recursive: true);
  });

  test('putFileStream aborts the upload when abortTrigger completes', () async {
    final client = _createClient(server);
    final abortTrigger = Completer<void>();
    final upload = client.putFileStream(
      '/dir/big.bin',
      file,
      abortTrigger: abortTrigger.future,
    );

    await Future<void>.delayed(const Duration(milliseconds: 200));
    final abortedAt = DateTime.now();
    abortTrigger.complete();
    final error = await _captureError(upload);
    final elapsedMs = DateTime.now().difference(abortedAt).inMilliseconds;

    expect(error, isA<WebDAVNetworkException>());
    expect(
      (error as WebDAVNetworkException).cause,
      isA<http.RequestAbortedException>(),
    );
    expect(elapsedMs, lessThan(1500));
    expect(server.receivedBytes, lessThan(_fileSize));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('putStream aborts the upload when abortTrigger completes', () async {
    final client = _createClient(server);
    final abortTrigger = Completer<void>();
    final upload = client.putStream(
      '/dir/big.bin',
      file.openRead(),
      _fileSize,
      'application/octet-stream',
      abortTrigger: abortTrigger.future,
    );

    await Future<void>.delayed(const Duration(milliseconds: 200));
    final abortedAt = DateTime.now();
    abortTrigger.complete();
    final error = await _captureError(upload);
    final elapsedMs = DateTime.now().difference(abortedAt).inMilliseconds;

    expect(error, isA<WebDAVNetworkException>());
    expect(
      (error as WebDAVNetworkException).cause,
      isA<http.RequestAbortedException>(),
    );
    expect(elapsedMs, lessThan(1500));
    expect(server.receivedBytes, lessThan(_fileSize));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('putFileStream uploads fully when abortTrigger does not complete',
      () async {
    final client = _createClient(server);
    final abortTrigger = Completer<void>();

    await client.putFileStream(
      '/dir/big.bin',
      file,
      abortTrigger: abortTrigger.future,
    );

    expect(server.receivedBytes, _fileSize);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
