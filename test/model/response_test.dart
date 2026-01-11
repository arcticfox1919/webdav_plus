import 'package:test/test.dart';
import 'package:webdav_plus/src/model/response.dart';
import 'package:webdav_plus/src/model/propstat.dart';
import 'package:webdav_plus/src/model/propfind.dart';
import 'package:webdav_plus/src/model/error.dart';

void main() {
  group('Response', () {
    group('XML Generation', () {
      test('should generate basic response XML', () {
        final response = Response(
          href: '/test/file.txt',
          propstats: [
            Propstat(
              prop: Prop(properties: {'getcontentlength'}),
              status: 'HTTP/1.1 200 OK',
            ),
          ],
        );
        final xml = response.toXml();

        expect(xml, contains('<D:response>'));
        expect(xml, contains('<D:href>/test/file.txt</D:href>'));
        expect(xml, contains('<D:propstat>'));
        expect(xml, contains('<D:status>HTTP/1.1 200 OK</D:status>'));
        expect(xml, contains('</D:propstat>'));
        expect(xml, contains('</D:response>'));
      });

      test('should generate response with multiple propstats', () {
        final response = Response(
          href: '/test/file.txt',
          propstats: [
            Propstat(
              prop: Prop(properties: {'getcontentlength'}),
              status: 'HTTP/1.1 200 OK',
            ),
            Propstat(
              prop: Prop(properties: {'nonexistent'}),
              status: 'HTTP/1.1 404 Not Found',
            ),
          ],
        );
        final xml = response.toXml();

        expect(xml.split('<D:propstat>').length - 1, equals(2));
        expect(xml, contains('HTTP/1.1 200 OK'));
        expect(xml, contains('HTTP/1.1 404 Not Found'));
      });

      test('should include status when provided', () {
        final response = Response(
          href: '/test/file.txt',
          propstats: [],
          status: 'HTTP/1.1 404 Not Found',
        );
        final xml = response.toXml();

        expect(xml, contains('<D:status>HTTP/1.1 404 Not Found</D:status>'));
      });

      test('should include error when provided', () {
        final response = Response(
          href: '/test/file.txt',
          propstats: [],
          error: Error(conditions: ['lock-token-submitted']),
        );
        final xml = response.toXml();

        expect(xml, contains('<D:error>'));
        expect(xml, contains('<D:lock-token-submitted/>'));
        expect(xml, contains('</D:error>'));
      });

      test('should include responsedescription when provided', () {
        final response = Response(
          href: '/test/file.txt',
          propstats: [],
          responsedescription: 'File not found',
        );
        final xml = response.toXml();

        expect(
          xml,
          contains(
            '<D:responsedescription>File not found</D:responsedescription>',
          ),
        );
      });

      test('should include location when provided', () {
        final response = Response(
          href: '/test/file.txt',
          propstats: [],
          location: 'https://example.com/moved/file.txt',
        );
        final xml = response.toXml();

        expect(xml, contains('<D:location>'));
        expect(
          xml,
          contains('<D:href>https://example.com/moved/file.txt</D:href>'),
        );
        expect(xml, contains('</D:location>'));
      });

      test('should generate complete response with all elements', () {
        final response = Response(
          href: '/test/complex.xml',
          propstats: [
            Propstat(
              prop: Prop(properties: {'getcontentlength'}),
              status: 'HTTP/1.1 200 OK',
            ),
            Propstat(
              prop: Prop(properties: {'author'}),
              status: 'HTTP/1.1 404 Not Found',
              error: Error(conditions: ['cannot-modify-protected-property']),
            ),
          ],
          error: Error(conditions: ['lock-token-submitted']),
          responsedescription: 'Partial success',
          location: 'https://example.com/final/complex.xml',
        );
        final xml = response.toXml();

        expect(xml, contains('<D:href>/test/complex.xml</D:href>'));
        expect(xml, contains('HTTP/1.1 200 OK'));
        expect(xml, contains('HTTP/1.1 404 Not Found'));
        expect(xml, contains('<D:cannot-modify-protected-property/>'));
        expect(xml, contains('<D:lock-token-submitted/>'));
        expect(
          xml,
          contains(
            '<D:responsedescription>Partial success</D:responsedescription>',
          ),
        );
        expect(xml, contains('<D:location>'));
        expect(
          xml,
          contains('<D:href>https://example.com/final/complex.xml</D:href>'),
        );
        expect(xml, contains('</D:location>'));
      });
    });

    group('Construction', () {
      test('should create with minimal parameters', () {
        final response = Response(href: '/test', propstats: []);
        expect(response.href, equals('/test'));
        expect(response.propstats, isEmpty);
        expect(response.status, isNull);
        expect(response.error, isNull);
        expect(response.responsedescription, isNull);
        expect(response.location, isNull);
      });

      test('should create with all parameters', () {
        final propstats = [
          Propstat(
            prop: Prop(properties: {'test'}),
            status: 'HTTP/1.1 200 OK',
          ),
        ];
        final error = Error(conditions: ['test-condition']);
        final response = Response(
          href: '/test/file.txt',
          propstats: propstats,
          status: 'HTTP/1.1 404 Not Found',
          error: error,
          responsedescription: 'Test description',
          location: 'https://example.com/test',
        );

        expect(response.href, equals('/test/file.txt'));
        expect(response.propstats, equals(propstats));
        expect(response.status, equals('HTTP/1.1 404 Not Found'));
        expect(response.error, equals(error));
        expect(response.responsedescription, equals('Test description'));
        expect(response.location, equals('https://example.com/test'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty href', () {
        final response = Response(href: '', propstats: []);
        final xml = response.toXml();
        expect(xml, contains('<D:href></D:href>'));
      });

      test('should handle special characters in href', () {
        final response = Response(
          href: '/test/file with spaces & symbols.txt',
          propstats: [],
        );
        final xml = response.toXml();
        expect(
          xml,
          contains('<D:href>/test/file with spaces & symbols.txt</D:href>'),
        );
      });

      test('should handle empty propstats list', () {
        final response = Response(href: '/test', propstats: []);
        final xml = response.toXml();
        expect(xml, contains('<D:response>'));
        expect(xml, contains('<D:href>/test</D:href>'));
        expect(xml, contains('</D:response>'));
        expect(xml, isNot(contains('<D:propstat>')));
      });
    });
  });
}
