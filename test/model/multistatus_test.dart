import 'package:test/test.dart';
import 'package:webdav_plus/src/model/multistatus.dart';
import 'package:webdav_plus/src/model/response.dart';
import 'package:webdav_plus/src/model/propstat.dart';
import 'package:webdav_plus/src/model/propfind.dart';

void main() {
  group('Multistatus', () {
    group('XML Generation', () {
      test('should generate empty multistatus XML', () {
        final multistatus = Multistatus(responses: []);
        final xml = multistatus.toXml();

        expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));
        expect(xml, contains('<D:multistatus xmlns:D="DAV:">'));
        expect(xml, contains('</D:multistatus>'));
      });

      test('should generate multistatus with single response', () {
        final response = Response(
          href: '/test/file.txt',
          propstats: [
            Propstat(
              prop: Prop(properties: {'getcontentlength'}),
              status: 'HTTP/1.1 200 OK',
            ),
          ],
        );
        final multistatus = Multistatus(responses: [response]);
        final xml = multistatus.toXml();

        expect(xml, contains('<D:multistatus xmlns:D="DAV:">'));
        expect(xml, contains('<D:response>'));
        expect(xml, contains('<D:href>/test/file.txt</D:href>'));
        expect(xml, contains('</D:response>'));
        expect(xml, contains('</D:multistatus>'));
      });

      test('should generate multistatus with multiple responses', () {
        final responses = [
          Response(
            href: '/test/file1.txt',
            propstats: [
              Propstat(
                prop: Prop(properties: {'getcontentlength'}),
                status: 'HTTP/1.1 200 OK',
              ),
            ],
          ),
          Response(
            href: '/test/file2.txt',
            propstats: [
              Propstat(
                prop: Prop(properties: {'getcontenttype'}),
                status: 'HTTP/1.1 200 OK',
              ),
            ],
          ),
        ];
        final multistatus = Multistatus(responses: responses);
        final xml = multistatus.toXml();

        expect(xml, contains('/test/file1.txt'));
        expect(xml, contains('/test/file2.txt'));
        expect(xml.split('<D:response>').length - 1, equals(2));
      });

      test('should include response description when provided', () {
        final multistatus = Multistatus(
          responses: [],
          responsedescription: 'Batch operation completed',
        );
        final xml = multistatus.toXml();

        expect(
          xml,
          contains(
            '<D:responsedescription>Batch operation completed</D:responsedescription>',
          ),
        );
      });

      test('should handle complex multistatus with various elements', () {
        final response = Response(
          href: '/test/complex.xml',
          propstats: [
            Propstat(
              prop: Prop(
                properties: {'getcontentlength', 'getlastmodified'},
                customProperties: {'author': 'Test Author'},
              ),
              status: 'HTTP/1.1 200 OK',
            ),
          ],
          location: 'https://example.com/moved/complex.xml',
        );
        final multistatus = Multistatus(
          responses: [response],
          responsedescription: 'Complex response test',
        );
        final xml = multistatus.toXml();

        expect(xml, contains('<D:href>/test/complex.xml</D:href>'));
        expect(xml, contains('<D:prop>'));
        expect(xml, contains('getcontentlength'));
        expect(xml, contains('getlastmodified'));
        expect(
          xml,
          contains('<S:author xmlns:S="SAR:">Test Author</S:author>'),
        );
        expect(xml, contains('<D:status>HTTP/1.1 200 OK</D:status>'));
        expect(xml, contains('<D:location>'));
        expect(
          xml,
          contains('<D:href>https://example.com/moved/complex.xml</D:href>'),
        );
        expect(xml, contains('</D:location>'));
        expect(
          xml,
          contains(
            '<D:responsedescription>Complex response test</D:responsedescription>',
          ),
        );
      });
    });

    group('Construction', () {
      test('should create with minimal parameters', () {
        final multistatus = Multistatus(responses: []);
        expect(multistatus.responses, isEmpty);
        expect(multistatus.responsedescription, isNull);
      });

      test('should create with all parameters', () {
        final responses = [Response(href: '/test', propstats: [])];
        final multistatus = Multistatus(
          responses: responses,
          responsedescription: 'Test description',
        );
        expect(multistatus.responses, equals(responses));
        expect(multistatus.responsedescription, equals('Test description'));
      });
    });
  });
}
