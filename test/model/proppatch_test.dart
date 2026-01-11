import 'package:test/test.dart';
import 'package:webdav_plus/src/model/proppatch.dart';
import 'package:webdav_plus/src/model/propfind.dart';

void main() {
  group('Propertyupdate', () {
    group('XML Generation', () {
      test('should generate set operation XML', () {
        final propertyupdate = Propertyupdate(
          set: SetElement(prop: Prop(customProperties: {'author': 'John Doe'})),
        );
        final xml = propertyupdate.toXml();

        expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));
        expect(xml, contains('<D:propertyupdate xmlns:D="DAV:">'));
        expect(xml, contains('<D:set>'));
        expect(xml, contains('<S:author xmlns:S="SAR:">John Doe</S:author>'));
        expect(xml, contains('</D:set>'));
        expect(xml, contains('</D:propertyupdate>'));
      });

      test('should generate remove operation XML', () {
        final propertyupdate = Propertyupdate(
          remove: Remove(prop: Prop(properties: {'author'})),
        );
        final xml = propertyupdate.toXml();

        expect(xml, contains('<D:propertyupdate xmlns:D="DAV:">'));
        expect(xml, contains('<D:remove>'));
        expect(xml, contains('<D:author/>'));
        expect(xml, contains('</D:remove>'));
        expect(xml, contains('</D:propertyupdate>'));
      });

      test('should generate both set and remove operations', () {
        final propertyupdate = Propertyupdate(
          set: SetElement(prop: Prop(customProperties: {'title': 'New Title'})),
          remove: Remove(prop: Prop(properties: {'oldprop'})),
        );
        final xml = propertyupdate.toXml();

        expect(xml, contains('<D:set>'));
        expect(xml, contains('<S:title xmlns:S="SAR:">New Title</S:title>'));
        expect(xml, contains('</D:set>'));
        expect(xml, contains('<D:remove>'));
        expect(xml, contains('<D:oldprop/>'));
        expect(xml, contains('</D:remove>'));
      });

      test('should handle empty propertyupdate', () {
        final propertyupdate = Propertyupdate();
        final xml = propertyupdate.toXml();

        expect(xml, contains('<D:propertyupdate xmlns:D="DAV:">'));
        expect(xml, contains('</D:propertyupdate>'));
        expect(xml, isNot(contains('<D:set>')));
        expect(xml, isNot(contains('<D:remove>')));
      });

      test(
        'should generate complex set operation with multiple properties',
        () {
          final propertyupdate = Propertyupdate(
            set: SetElement(
              prop: Prop(
                properties: {'displayname'},
                customProperties: {
                  'author': 'Jane Smith',
                  'category': 'documents',
                  'priority': 'high',
                },
              ),
            ),
          );
          final xml = propertyupdate.toXml();

          expect(xml, contains('<D:displayname/>'));
          expect(
            xml,
            contains('<S:author xmlns:S="SAR:">Jane Smith</S:author>'),
          );
          expect(
            xml,
            contains('<S:category xmlns:S="SAR:">documents</S:category>'),
          );
          expect(xml, contains('<S:priority xmlns:S="SAR:">high</S:priority>'));
        },
      );
    });

    group('Construction', () {
      test('should create with set operation only', () {
        final set = SetElement(prop: Prop(properties: {'test'}));
        final propertyupdate = Propertyupdate(set: set);

        expect(propertyupdate.set, equals(set));
        expect(propertyupdate.remove, isNull);
      });

      test('should create with remove operation only', () {
        final remove = Remove(prop: Prop(properties: {'test'}));
        final propertyupdate = Propertyupdate(remove: remove);

        expect(propertyupdate.set, isNull);
        expect(propertyupdate.remove, equals(remove));
      });

      test('should create with both operations', () {
        final set = SetElement(prop: Prop(properties: {'prop1'}));
        final remove = Remove(prop: Prop(properties: {'prop2'}));
        final propertyupdate = Propertyupdate(set: set, remove: remove);

        expect(propertyupdate.set, equals(set));
        expect(propertyupdate.remove, equals(remove));
      });

      test('should create empty propertyupdate', () {
        final propertyupdate = Propertyupdate();

        expect(propertyupdate.set, isNull);
        expect(propertyupdate.remove, isNull);
      });
    });
  });

  group('SetElement', () {
    group('XML Generation', () {
      test('should generate set XML with standard properties', () {
        final set = SetElement(
          prop: Prop(properties: {'displayname', 'getcontenttype'}),
        );
        final xml = set.toXml();

        expect(xml, contains('<D:set>'));
        expect(xml, contains('<D:displayname/>'));
        expect(xml, contains('<D:getcontenttype/>'));
        expect(xml, contains('</D:set>'));
      });

      test('should generate set XML with custom properties', () {
        final set = SetElement(
          prop: Prop(
            customProperties: {'author': 'Test Author', 'version': '1.0'},
          ),
        );
        final xml = set.toXml();

        expect(
          xml,
          contains('<S:author xmlns:S="SAR:">Test Author</S:author>'),
        );
        expect(xml, contains('<S:version xmlns:S="SAR:">1.0</S:version>'));
      });

      test('should handle empty properties', () {
        final set = SetElement(prop: Prop());
        final xml = set.toXml();

        expect(xml, contains('<D:set>'));
        expect(xml, contains('<D:prop>'));
        expect(xml, contains('</D:prop>'));
        expect(xml, contains('</D:set>'));
      });

      test('should handle special characters in property values', () {
        final set = SetElement(
          prop: Prop(
            customProperties: {'description': 'Text with <tags> & "quotes"'},
          ),
        );
        final xml = set.toXml();

        expect(
          xml,
          contains(
            '<S:description xmlns:S="SAR:">Text with <tags> & "quotes"</S:description>',
          ),
        );
      });
    });

    group('Construction', () {
      test('should create with prop', () {
        final prop = Prop(properties: {'test'});
        final set = SetElement(prop: prop);

        expect(set.prop, equals(prop));
      });
    });
  });

  group('Remove', () {
    group('XML Generation', () {
      test('should generate remove XML with standard properties', () {
        final remove = Remove(prop: Prop(properties: {'author', 'category'}));
        final xml = remove.toXml();

        expect(xml, contains('<D:remove>'));
        expect(xml, contains('<D:author/>'));
        expect(xml, contains('<D:category/>'));
        expect(xml, contains('</D:remove>'));
      });

      test('should generate remove XML with custom properties', () {
        final remove = Remove(
          prop: Prop(customProperties: {'oldprop': '', 'deprecated': ''}),
        );
        final xml = remove.toXml();

        expect(xml, contains('<S:oldprop xmlns:S="SAR:"/>'));
        expect(xml, contains('<S:deprecated xmlns:S="SAR:"/>'));
      });

      test('should handle empty properties', () {
        final remove = Remove(prop: Prop());
        final xml = remove.toXml();

        expect(xml, contains('<D:remove>'));
        expect(xml, contains('<D:prop>'));
        expect(xml, contains('</D:prop>'));
        expect(xml, contains('</D:remove>'));
      });

      test('should generate remove XML with mixed properties', () {
        final remove = Remove(
          prop: Prop(
            properties: {'displayname'},
            customProperties: {'customfield': ''},
          ),
        );
        final xml = remove.toXml();

        expect(xml, contains('<D:displayname/>'));
        expect(xml, contains('<S:customfield xmlns:S="SAR:"/>'));
      });
    });

    group('Construction', () {
      test('should create with prop', () {
        final prop = Prop(properties: {'test'});
        final remove = Remove(prop: prop);

        expect(remove.prop, equals(prop));
      });
    });
  });

  group('Integration Tests', () {
    test('should handle complex PROPPATCH with multiple operations', () {
      final propertyupdate = Propertyupdate(
        set: SetElement(
          prop: Prop(
            properties: {'displayname'},
            customProperties: {
              'title': 'Updated Document',
              'author': 'New Author',
              'version': '2.0',
            },
          ),
        ),
        remove: Remove(
          prop: Prop(
            properties: {'getlastmodified'},
            customProperties: {'oldcategory': '', 'deprecated-field': ''},
          ),
        ),
      );
      final xml = propertyupdate.toXml();

      // Verify set operations
      expect(xml, contains('<D:set>'));
      expect(xml, contains('<D:displayname/>'));
      expect(
        xml,
        contains('<S:title xmlns:S="SAR:">Updated Document</S:title>'),
      );
      expect(xml, contains('<S:author xmlns:S="SAR:">New Author</S:author>'));
      expect(xml, contains('<S:version xmlns:S="SAR:">2.0</S:version>'));

      // Verify remove operations
      expect(xml, contains('<D:remove>'));
      expect(xml, contains('<D:getlastmodified/>'));
      expect(xml, contains('<S:oldcategory xmlns:S="SAR:"/>'));
      expect(xml, contains('<S:deprecated-field xmlns:S="SAR:"/>'));

      // Verify structure
      expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));
      expect(xml, contains('<D:propertyupdate xmlns:D="DAV:">'));
      expect(xml, contains('</D:propertyupdate>'));
    });
  });
}
