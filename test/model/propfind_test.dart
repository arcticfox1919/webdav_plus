import 'package:test/test.dart';
import 'package:webdav_plus/src/model/propfind.dart';

void main() {
  group('Propfind', () {
    group('XML Generation', () {
      test('should generate allprop XML correctly', () {
        final propfind = Propfind(allprop: Allprop());
        final xml = propfind.toXml();

        expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));
        expect(xml, contains('<D:propfind xmlns:D="DAV:">'));
        expect(xml, contains('<D:allprop/>'));
        expect(xml, contains('</D:propfind>'));
      });

      test('should generate propname XML correctly', () {
        final propfind = Propfind(propname: Propname());
        final xml = propfind.toXml();

        expect(xml, contains('<D:propfind xmlns:D="DAV:">'));
        expect(xml, contains('<D:propname/>'));
        expect(xml, contains('</D:propfind>'));
      });

      test('should generate prop XML with standard properties', () {
        final propfind = Propfind(
          prop: Prop(
            properties: {'getcontentlength', 'getlastmodified', 'resourcetype'},
          ),
        );
        final xml = propfind.toXml();

        expect(xml, contains('<D:propfind xmlns:D="DAV:">'));
        expect(xml, contains('<D:prop>'));
        expect(xml, contains('<D:getcontentlength/>'));
        expect(xml, contains('<D:getlastmodified/>'));
        expect(xml, contains('<D:resourcetype/>'));
        expect(xml, contains('</D:prop>'));
        expect(xml, contains('</D:propfind>'));
      });

      test('should generate prop XML with custom properties', () {
        final propfind = Propfind(
          prop: Prop(
            properties: {'displayname'},
            customProperties: {
              'author': 'John Doe',
              'category': 'documents',
              'emptyProp': '',
            },
          ),
        );
        final xml = propfind.toXml();

        expect(xml, contains('<D:prop>'));
        expect(xml, contains('<D:displayname/>'));
        expect(xml, contains('<S:author xmlns:S="SAR:">John Doe</S:author>'));
        expect(
          xml,
          contains('<S:category xmlns:S="SAR:">documents</S:category>'),
        );
        expect(xml, contains('<S:emptyProp xmlns:S="SAR:"/>'));
        expect(xml, contains('</D:prop>'));
      });

      test('should handle empty propfind', () {
        final propfind = Propfind();
        final xml = propfind.toXml();

        expect(xml, contains('<D:propfind xmlns:D="DAV:">'));
        expect(xml, contains('</D:propfind>'));
        expect(xml, isNot(contains('<D:allprop/>')));
        expect(xml, isNot(contains('<D:propname/>')));
        expect(xml, isNot(contains('<D:prop>')));
      });
    });

    group('Prop class', () {
      test('should handle empty properties', () {
        final prop = Prop();
        final xml = prop.toXml();

        expect(xml, equals('<D:prop>\n</D:prop>'));
      });

      test('should generate XML for mixed properties', () {
        final prop = Prop(
          properties: {'getcontenttype', 'getetag'},
          customProperties: {'title': 'Test Document'},
        );
        final xml = prop.toXml();

        expect(xml, contains('<D:getcontenttype/>'));
        expect(xml, contains('<D:getetag/>'));
        expect(
          xml,
          contains('<S:title xmlns:S="SAR:">Test Document</S:title>'),
        );
      });

      test('should handle special characters in custom properties', () {
        final prop = Prop(
          customProperties: {
            'description': 'File with <special> & "quoted" characters',
          },
        );
        final xml = prop.toXml();

        expect(
          xml,
          contains(
            '<S:description xmlns:S="SAR:">File with <special> & "quoted" characters</S:description>',
          ),
        );
      });
    });
  });

  group('Allprop', () {
    test('should create instance correctly', () {
      final allprop = Allprop();
      expect(allprop, isNotNull);
    });
  });

  group('Propname', () {
    test('should create instance correctly', () {
      final propname = Propname();
      expect(propname, isNotNull);
    });
  });
}
