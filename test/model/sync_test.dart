import 'package:test/test.dart';
import 'package:webdav_plus/src/model/sync.dart';

void main() {
  group('SyncCollection', () {
    group('XML Generation', () {
      test('should generate sync collection request XML', () {
        final syncRequest = SyncCollection(
          syncToken: 'http://example.com/token/12345',
          syncLevel: '1',
          properties: ['displayname', 'getcontentlength'],
        );
        final xml = syncRequest.toXml();

        expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));
        expect(xml, contains('<D:sync-collection xmlns:D="DAV:">'));
        expect(
          xml,
          contains(
            '<D:sync-token>http://example.com/token/12345</D:sync-token>',
          ),
        );
        expect(xml, contains('<D:sync-level>1</D:sync-level>'));
        expect(xml, contains('<D:prop>'));
        expect(xml, contains('<D:displayname/>'));
        expect(xml, contains('<D:getcontentlength/>'));
        expect(xml, contains('</D:sync-collection>'));
      });

      test(
        'should generate sync collection request with different sync level',
        () {
          final syncRequest = SyncCollection(
            syncToken: 'http://example.com/ns/sync/1234',
            syncLevel: 'infinity',
            properties: ['resourcetype'],
          );
          final xml = syncRequest.toXml();

          expect(
            xml,
            contains(
              '<D:sync-token>http://example.com/ns/sync/1234</D:sync-token>',
            ),
          );
          expect(xml, contains('<D:sync-level>infinity</D:sync-level>'));
          expect(xml, contains('<D:resourcetype/>'));
        },
      );

      test('should generate sync collection request with empty properties', () {
        final syncRequest = SyncCollection(
          syncToken: 'http://example.com/token/0',
          syncLevel: '1',
          properties: [],
        );
        final xml = syncRequest.toXml();

        expect(xml, isNot(contains('<D:prop>')));
        expect(xml, isNot(contains('<D:displayname/>')));
      });

      test('should generate sync collection request with limit', () {
        final syncRequest = SyncCollection(
          syncToken: 'token123',
          syncLevel: '1',
          properties: ['displayname'],
          limit: 100,
        );
        final xml = syncRequest.toXml();

        expect(xml, contains('<D:limit>'));
        expect(xml, contains('<D:nresults>100</D:nresults>'));
        expect(xml, contains('</D:limit>'));
      });

      test('should generate sync collection request without limit', () {
        final syncRequest = SyncCollection(
          syncToken: 'token123',
          syncLevel: '1',
          properties: ['displayname'],
        );
        final xml = syncRequest.toXml();

        expect(xml, isNot(contains('<D:limit>')));
      });
    });

    group('Construction', () {
      test('should create with required parameters', () {
        final syncRequest = SyncCollection(
          syncToken: 'test-token',
          syncLevel: '1',
        );

        expect(syncRequest.syncToken, equals('test-token'));
        expect(syncRequest.syncLevel, equals('1'));
        expect(syncRequest.properties, isEmpty);
        expect(syncRequest.limit, isNull);
      });

      test('should create with properties', () {
        final properties = ['displayname', 'getcontentlength'];
        final syncRequest = SyncCollection(
          syncToken: 'test-token',
          syncLevel: '1',
          properties: properties,
        );

        expect(syncRequest.properties, equals(properties));
      });

      test('should create with limit', () {
        final syncRequest = SyncCollection(
          syncToken: 'test-token',
          syncLevel: '1',
          limit: 50,
        );

        expect(syncRequest.limit, equals(50));
      });
    });

    group('Edge Cases', () {
      test('should handle empty sync token', () {
        final syncRequest = SyncCollection(syncToken: '', syncLevel: '1');
        final xml = syncRequest.toXml();

        expect(xml, contains('<D:sync-token></D:sync-token>'));
      });

      test('should handle different sync levels', () {
        final levels = ['0', '1', 'infinity'];

        for (final level in levels) {
          final syncRequest = SyncCollection(
            syncToken: 'token',
            syncLevel: level,
          );
          final xml = syncRequest.toXml();

          expect(xml, contains('<D:sync-level>$level</D:sync-level>'));
        }
      });

      test('should handle URL sync tokens', () {
        final syncRequest = SyncCollection(
          syncToken: 'http://example.com/sync/token?version=123&state=active',
          syncLevel: '1',
        );
        final xml = syncRequest.toXml();

        expect(
          xml,
          contains(
            '<D:sync-token>http://example.com/sync/token?version=123&state=active</D:sync-token>',
          ),
        );
      });

      test('should handle special characters in sync token', () {
        final syncRequest = SyncCollection(
          syncToken: 'token-with-special-chars-!@#\$%^&*()',
          syncLevel: '1',
        );
        final xml = syncRequest.toXml();

        expect(
          xml,
          contains(
            '<D:sync-token>token-with-special-chars-!@#\$%^&*()</D:sync-token>',
          ),
        );
      });

      test('should handle Unicode characters in sync token', () {
        final syncRequest = SyncCollection(
          syncToken: 'token-测试-🔄-синхронизация',
          syncLevel: '1',
        );
        final xml = syncRequest.toXml();

        expect(
          xml,
          contains('<D:sync-token>token-测试-🔄-синхронизация</D:sync-token>'),
        );
      });
    });
  });

  group('SyncToken', () {
    group('XML Generation', () {
      test('should generate sync token XML', () {
        final syncToken = SyncToken(token: 'http://example.com/token/123');
        final xml = syncToken.toXml();

        expect(
          xml,
          equals('<D:sync-token>http://example.com/token/123</D:sync-token>'),
        );
      });

      test('should generate empty sync token XML', () {
        final syncToken = SyncToken(token: '');
        final xml = syncToken.toXml();

        expect(xml, equals('<D:sync-token></D:sync-token>'));
      });

      test('should handle various token formats', () {
        final tokens = [
          'simple-token',
          'http://example.com/sync/123',
          'urn:uuid:12345678-1234-1234-1234-123456789abc',
          'base64-encoded-token==',
        ];

        for (final tokenValue in tokens) {
          final syncToken = SyncToken(token: tokenValue);
          final xml = syncToken.toXml();
          expect(xml, equals('<D:sync-token>$tokenValue</D:sync-token>'));
        }
      });
    });

    group('Construction', () {
      test('should create with token', () {
        final syncToken = SyncToken(token: 'test-token');
        expect(syncToken.token, equals('test-token'));
      });
    });
  });

  group('SyncLevel', () {
    group('XML Generation', () {
      test('should generate sync level XML', () {
        final syncLevel = SyncLevel(level: '1');
        final xml = syncLevel.toXml();

        expect(xml, equals('<D:sync-level>1</D:sync-level>'));
      });

      test('should handle different sync levels', () {
        final levels = ['0', '1', 'infinity'];

        for (final levelValue in levels) {
          final syncLevel = SyncLevel(level: levelValue);
          final xml = syncLevel.toXml();
          expect(xml, equals('<D:sync-level>$levelValue</D:sync-level>'));
        }
      });
    });

    group('Construction', () {
      test('should create with level', () {
        final syncLevel = SyncLevel(level: 'infinity');
        expect(syncLevel.level, equals('infinity'));
      });
    });
  });

  group('Limit', () {
    group('XML Generation', () {
      test('should generate limit XML', () {
        final limit = Limit(nresults: 100);
        final xml = limit.toXml();

        expect(xml, contains('<D:limit>'));
        expect(xml, contains('<D:nresults>100</D:nresults>'));
        expect(xml, contains('</D:limit>'));
      });

      test('should handle different result counts', () {
        final counts = [1, 50, 100, 1000];

        for (final count in counts) {
          final limit = Limit(nresults: count);
          final xml = limit.toXml();
          expect(xml, contains('<D:nresults>$count</D:nresults>'));
        }
      });

      test('should handle zero results', () {
        final limit = Limit(nresults: 0);
        final xml = limit.toXml();

        expect(xml, contains('<D:nresults>0</D:nresults>'));
      });
    });

    group('Construction', () {
      test('should create with nresults', () {
        final limit = Limit(nresults: 42);
        expect(limit.nresults, equals(42));
      });
    });
  });

  group('Token Handling', () {
    group('Token Validation', () {
      test('should handle valid HTTP URL tokens', () {
        final validTokens = [
          'http://example.com/sync/token',
          'https://example.com/sync/token/123',
          'http://dav.example.com/sync?version=1',
        ];

        for (final token in validTokens) {
          final syncRequest = SyncCollection(syncToken: token, syncLevel: '1');
          expect(syncRequest.syncToken, equals(token));
        }
      });

      test('should handle opaque tokens', () {
        final opaqueTokens = [
          'abc123',
          'token-with-dashes',
          'TOKEN_WITH_UNDERSCORES',
          '12345',
          'base64EncodedToken==',
        ];

        for (final token in opaqueTokens) {
          final syncRequest = SyncCollection(syncToken: token, syncLevel: '1');
          expect(syncRequest.syncToken, equals(token));
        }
      });

      test('should handle initial sync token', () {
        final syncRequest = SyncCollection(
          syncToken: 'http://example.com/ns/sync/initial',
          syncLevel: '1',
        );

        expect(
          syncRequest.syncToken,
          equals('http://example.com/ns/sync/initial'),
        );
      });
    });

    group('Token Comparison', () {
      test('should handle token equality', () {
        final token1 = 'http://example.com/token/123';
        final token2 = 'http://example.com/token/123';

        final request1 = SyncCollection(syncToken: token1, syncLevel: '1');
        final request2 = SyncCollection(syncToken: token2, syncLevel: '1');

        expect(request1.syncToken, equals(request2.syncToken));
      });

      test('should handle token differences', () {
        final token1 = 'http://example.com/token/123';
        final token2 = 'http://example.com/token/124';

        final request1 = SyncCollection(syncToken: token1, syncLevel: '1');
        final request2 = SyncCollection(syncToken: token2, syncLevel: '1');

        expect(request1.syncToken, isNot(equals(request2.syncToken)));
      });
    });
  });
}
