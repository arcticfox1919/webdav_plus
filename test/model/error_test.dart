import 'package:test/test.dart';
import 'package:webdav_plus/src/model/error.dart';

void main() {
  group('Error', () {
    group('XML Generation', () {
      test('should generate error XML with single condition', () {
        final error = Error(conditions: ['lock-token-submitted']);
        final xml = error.toXml();

        expect(xml, contains('<D:error>'));
        expect(xml, contains('<D:lock-token-submitted/>'));
        expect(xml, contains('</D:error>'));
      });

      test('should generate error XML with multiple conditions', () {
        final error = Error(
          conditions: [
            'lock-token-submitted',
            'cannot-modify-protected-property',
            'prop-find-finite-depth',
          ],
        );
        final xml = error.toXml();

        expect(xml, contains('<D:error>'));
        expect(xml, contains('<D:lock-token-submitted/>'));
        expect(xml, contains('<D:cannot-modify-protected-property/>'));
        expect(xml, contains('<D:prop-find-finite-depth/>'));
        expect(xml, contains('</D:error>'));
      });

      test('should generate empty error XML', () {
        final error = Error(conditions: []);
        final xml = error.toXml();

        expect(xml, equals('      <D:error>\n      </D:error>'));
      });

      test('should handle complex error condition names', () {
        final error = Error(
          conditions: [
            'lock-token-matches-request-uri',
            'no-conflicting-lock',
            'no-external-entities',
            'preserved-live-properties',
          ],
        );
        final xml = error.toXml();

        expect(xml, contains('<D:lock-token-matches-request-uri/>'));
        expect(xml, contains('<D:no-conflicting-lock/>'));
        expect(xml, contains('<D:no-external-entities/>'));
        expect(xml, contains('<D:preserved-live-properties/>'));
      });

      test('should handle error conditions with special characters', () {
        final error = Error(
          conditions: [
            'custom-error-condition',
            'error_with_underscores',
            'error.with.dots',
          ],
        );
        final xml = error.toXml();

        expect(xml, contains('<D:custom-error-condition/>'));
        expect(xml, contains('<D:error_with_underscores/>'));
        expect(xml, contains('<D:error.with.dots/>'));
      });
    });

    group('Construction', () {
      test('should create with single condition', () {
        final error = Error(conditions: ['test-condition']);
        expect(error.conditions, equals(['test-condition']));
      });

      test('should create with multiple conditions', () {
        final conditions = ['condition1', 'condition2', 'condition3'];
        final error = Error(conditions: conditions);
        expect(error.conditions, equals(conditions));
      });

      test('should create with empty conditions', () {
        final error = Error(conditions: []);
        expect(error.conditions, isEmpty);
      });

      test('should preserve condition order', () {
        final conditions = ['z-condition', 'a-condition', 'm-condition'];
        final error = Error(conditions: conditions);
        expect(error.conditions, equals(conditions));
      });
    });

    group('Common WebDAV Error Conditions', () {
      test('should handle standard WebDAV error conditions', () {
        final standardConditions = [
          'lock-token-submitted',
          'no-conflicting-lock',
          'no-external-entities',
          'preserved-live-properties',
          'propfind-finite-depth',
          'cannot-modify-protected-property',
        ];

        for (final condition in standardConditions) {
          final error = Error(conditions: [condition]);
          final xml = error.toXml();
          expect(xml, contains('<D:$condition/>'));
        }
      });

      test('should handle locking-related error conditions', () {
        final error = Error(
          conditions: [
            'lock-token-submitted',
            'no-conflicting-lock',
            'no-external-entities',
            'lock-token-matches-request-uri',
          ],
        );
        final xml = error.toXml();

        expect(xml, contains('<D:lock-token-submitted/>'));
        expect(xml, contains('<D:no-conflicting-lock/>'));
        expect(xml, contains('<D:no-external-entities/>'));
        expect(xml, contains('<D:lock-token-matches-request-uri/>'));
      });

      test('should handle property-related error conditions', () {
        final error = Error(
          conditions: [
            'cannot-modify-protected-property',
            'property-update-failed',
            'preserved-live-properties',
          ],
        );
        final xml = error.toXml();

        expect(xml, contains('<D:cannot-modify-protected-property/>'));
        expect(xml, contains('<D:property-update-failed/>'));
        expect(xml, contains('<D:preserved-live-properties/>'));
      });

      test('should handle PROPFIND-related error conditions', () {
        final error = Error(
          conditions: ['propfind-finite-depth', 'prop-find-finite-depth'],
        );
        final xml = error.toXml();

        expect(xml, contains('<D:propfind-finite-depth/>'));
        expect(xml, contains('<D:prop-find-finite-depth/>'));
      });
    });

    group('Edge Cases', () {
      test('should handle duplicate conditions', () {
        final error = Error(
          conditions: [
            'duplicate-condition',
            'unique-condition',
            'duplicate-condition',
          ],
        );
        final xml = error.toXml();

        // Should include both duplicates
        final duplicateMatches =
            xml.split('<D:duplicate-condition/>').length - 1;
        expect(duplicateMatches, equals(2));
        expect(xml, contains('<D:unique-condition/>'));
      });

      test('should handle very long condition names', () {
        final longCondition =
            'very-long-error-condition-name-that-exceeds-normal-length-limits';
        final error = Error(conditions: [longCondition]);
        final xml = error.toXml();

        expect(xml, contains('<D:$longCondition/>'));
      });

      test('should handle empty string condition', () {
        final error = Error(conditions: ['']);
        final xml = error.toXml();

        expect(xml, contains('<D:/>'));
      });

      test('should handle single character conditions', () {
        final error = Error(conditions: ['a', 'b', 'c']);
        final xml = error.toXml();

        expect(xml, contains('<D:a/>'));
        expect(xml, contains('<D:b/>'));
        expect(xml, contains('<D:c/>'));
      });
    });

    group('XML Structure', () {
      test('should maintain proper XML structure with multiple conditions', () {
        final error = Error(conditions: ['first', 'second', 'third']);
        final xml = error.toXml();

        expect(xml, startsWith('      <D:error>'));
        expect(xml, endsWith('      </D:error>'));
        expect(xml, contains('\n'));

        // Check that conditions are properly nested
        final lines = xml.split('\n');
        expect(lines.first, equals('      <D:error>'));
        expect(lines.last, equals('      </D:error>'));
        expect(
          lines.length,
          equals(5),
        ); // Opening tag + 3 conditions + closing tag
      });

      test('should format XML with proper indentation', () {
        final error = Error(conditions: ['condition1', 'condition2']);
        final xml = error.toXml();

        final lines = xml.split('\n');
        expect(lines[0], equals('      <D:error>'));
        expect(lines[1], equals('        <D:condition1/>'));
        expect(lines[2], equals('        <D:condition2/>'));
        expect(lines[3], equals('      </D:error>'));
      });
    });
  });
}
