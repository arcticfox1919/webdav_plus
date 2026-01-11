import 'package:test/test.dart';
import 'package:webdav_plus/src/model/propstat.dart';
import 'package:webdav_plus/src/model/propfind.dart';
import 'package:webdav_plus/src/model/error.dart';

void main() {
  group('Propstat', () {
    group('XML Generation', () {
      test('should generate basic propstat XML', () {
        final propstat = Propstat(
          prop: Prop(properties: {'getcontentlength', 'getcontenttype'}),
          status: 'HTTP/1.1 200 OK',
        );
        final xml = propstat.toXml();

        expect(xml, contains('<D:propstat>'));
        expect(xml, contains('<D:prop>'));
        expect(xml, contains('<D:getcontentlength/>'));
        expect(xml, contains('<D:getcontenttype/>'));
        expect(xml, contains('</D:prop>'));
        expect(xml, contains('<D:status>HTTP/1.1 200 OK</D:status>'));
        expect(xml, contains('</D:propstat>'));
      });

      test('should generate propstat with custom properties', () {
        final propstat = Propstat(
          prop: Prop(
            properties: {'displayname'},
            customProperties: {'author': 'John Doe', 'category': 'documents'},
          ),
          status: 'HTTP/1.1 200 OK',
        );
        final xml = propstat.toXml();

        expect(xml, contains('<D:displayname/>'));
        expect(xml, contains('<S:author xmlns:S="SAR:">John Doe</S:author>'));
        expect(
          xml,
          contains('<S:category xmlns:S="SAR:">documents</S:category>'),
        );
      });

      test('should include error when provided', () {
        final propstat = Propstat(
          prop: Prop(properties: {'protected-property'}),
          status: 'HTTP/1.1 403 Forbidden',
          error: Error(conditions: ['cannot-modify-protected-property']),
        );
        final xml = propstat.toXml();

        expect(xml, contains('<D:status>HTTP/1.1 403 Forbidden</D:status>'));
        expect(xml, contains('<D:error>'));
        expect(xml, contains('<D:cannot-modify-protected-property/>'));
        expect(xml, contains('</D:error>'));
      });

      test('should include responsedescription when provided', () {
        final propstat = Propstat(
          prop: Prop(properties: {'test-prop'}),
          status: 'HTTP/1.1 404 Not Found',
          responsedescription: 'Property not found',
        );
        final xml = propstat.toXml();

        expect(
          xml,
          contains(
            '<D:responsedescription>Property not found</D:responsedescription>',
          ),
        );
      });

      test('should generate complete propstat with all elements', () {
        final propstat = Propstat(
          prop: Prop(
            properties: {'getcontentlength'},
            customProperties: {'title': 'Test Document'},
          ),
          status: 'HTTP/1.1 207 Multi-Status',
          error: Error(
            conditions: [
              'lock-token-submitted',
              'cannot-modify-protected-property',
            ],
          ),
          responsedescription: 'Mixed property status',
        );
        final xml = propstat.toXml();

        expect(xml, contains('<D:getcontentlength/>'));
        expect(
          xml,
          contains('<S:title xmlns:S="SAR:">Test Document</S:title>'),
        );
        expect(xml, contains('<D:status>HTTP/1.1 207 Multi-Status</D:status>'));
        expect(xml, contains('<D:lock-token-submitted/>'));
        expect(xml, contains('<D:cannot-modify-protected-property/>'));
        expect(
          xml,
          contains(
            '<D:responsedescription>Mixed property status</D:responsedescription>',
          ),
        );
      });

      test('should handle empty properties', () {
        final propstat = Propstat(prop: Prop(), status: 'HTTP/1.1 200 OK');
        final xml = propstat.toXml();

        expect(xml, contains('<D:propstat>'));
        expect(xml, contains('<D:prop>'));
        expect(xml, contains('</D:prop>'));
        expect(xml, contains('<D:status>HTTP/1.1 200 OK</D:status>'));
        expect(xml, contains('</D:propstat>'));
      });
    });

    group('Construction', () {
      test('should create with minimal parameters', () {
        final prop = Prop(properties: {'test'});
        final propstat = Propstat(prop: prop, status: 'HTTP/1.1 200 OK');

        expect(propstat.prop, equals(prop));
        expect(propstat.status, equals('HTTP/1.1 200 OK'));
        expect(propstat.error, isNull);
        expect(propstat.responsedescription, isNull);
      });

      test('should create with all parameters', () {
        final prop = Prop(properties: {'test'});
        final error = Error(conditions: ['test-condition']);
        final propstat = Propstat(
          prop: prop,
          status: 'HTTP/1.1 404 Not Found',
          error: error,
          responsedescription: 'Test description',
        );

        expect(propstat.prop, equals(prop));
        expect(propstat.status, equals('HTTP/1.1 404 Not Found'));
        expect(propstat.error, equals(error));
        expect(propstat.responsedescription, equals('Test description'));
      });
    });

    group('Status Codes', () {
      test('should handle various HTTP status codes', () {
        final statusCodes = [
          'HTTP/1.1 200 OK',
          'HTTP/1.1 404 Not Found',
          'HTTP/1.1 403 Forbidden',
          'HTTP/1.1 409 Conflict',
          'HTTP/1.1 507 Insufficient Storage',
        ];

        for (final status in statusCodes) {
          final propstat = Propstat(
            prop: Prop(properties: {'test'}),
            status: status,
          );
          final xml = propstat.toXml();
          expect(xml, contains('<D:status>$status</D:status>'));
        }
      });
    });

    group('Error Handling', () {
      test('should handle propstat with multiple error conditions', () {
        final propstat = Propstat(
          prop: Prop(properties: {'prop1', 'prop2'}),
          status: 'HTTP/1.1 403 Forbidden',
          error: Error(
            conditions: [
              'cannot-modify-protected-property',
              'lock-token-submitted',
              'prop-find-finite-depth',
            ],
          ),
        );
        final xml = propstat.toXml();

        expect(xml, contains('<D:cannot-modify-protected-property/>'));
        expect(xml, contains('<D:lock-token-submitted/>'));
        expect(xml, contains('<D:prop-find-finite-depth/>'));
      });

      test('should handle empty error conditions', () {
        final propstat = Propstat(
          prop: Prop(properties: {'test'}),
          status: 'HTTP/1.1 400 Bad Request',
          error: Error(conditions: []),
        );
        final xml = propstat.toXml();

        expect(xml, contains('<D:error>'));
        expect(xml, contains('</D:error>'));
      });
    });
  });
}
