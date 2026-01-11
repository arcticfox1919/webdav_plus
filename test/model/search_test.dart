import 'package:test/test.dart';
import 'package:webdav_plus/src/model/search.dart';

void main() {
  group('SearchRequest', () {
    group('XML Generation', () {
      test('should generate basic DAV search request XML', () {
        final searchRequest = SearchRequest(
          query: 'test document',
          language: 'davbasic',
        );
        final xml = searchRequest.toXml();

        expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));
        expect(xml, contains('<D:searchrequest xmlns:D="DAV:">'));
        expect(xml, contains('<D:basicsearch>'));
        expect(xml, contains('<D:select>'));
        expect(xml, contains('<D:allprop/>'));
        expect(xml, contains('<D:from>'));
        expect(xml, contains('<D:scope>'));
        expect(xml, contains('<D:href>/</D:href>'));
        expect(xml, contains('<D:depth>infinity</D:depth>'));
        expect(xml, contains('<D:where>'));
        expect(xml, contains('<D:contains>test document</D:contains>'));
        expect(xml, contains('</D:basicsearch>'));
        expect(xml, contains('</D:searchrequest>'));
      });

      test('should generate SQL search request XML', () {
        final searchRequest = SearchRequest(
          query:
              'SELECT * FROM SCOPE() WHERE "DAV:displayname" LIKE \'%test%\'',
          language: 'sql',
        );
        final xml = searchRequest.toXml();

        expect(
          xml,
          contains(
            '<D:sql>SELECT * FROM SCOPE() WHERE "DAV:displayname" LIKE \'%test%\'</D:sql>',
          ),
        );
        expect(xml, isNot(contains('<D:basicsearch>')));
      });

      test('should generate search request with empty query', () {
        final searchRequest = SearchRequest(query: '', language: 'davbasic');
        final xml = searchRequest.toXml();

        expect(xml, contains('<D:contains></D:contains>'));
      });

      test('should handle special characters in query', () {
        final searchRequest = SearchRequest(
          query: 'test & "document" < >',
          language: 'davbasic',
        );
        final xml = searchRequest.toXml();

        expect(xml, contains('<D:contains>test & "document" < ></D:contains>'));
      });

      test('should generate different language search requests', () {
        final basicRequest = SearchRequest(
          query: 'test query',
          language: 'davbasic',
        );
        final basicXml = basicRequest.toXml();

        expect(basicXml, contains('<D:basicsearch>'));
        expect(basicXml, contains('<D:contains>test query</D:contains>'));
        expect(basicXml, isNot(contains('<D:sql>')));

        final sqlRequest = SearchRequest(query: 'test query', language: 'sql');
        final sqlXml = sqlRequest.toXml();

        expect(sqlXml, contains('<D:sql>test query</D:sql>'));
        expect(sqlXml, isNot(contains('<D:basicsearch>')));

        // Other languages default to SQL format
        final otherRequest = SearchRequest(
          query: 'test query',
          language: 'xpath',
        );
        final otherXml = otherRequest.toXml();

        expect(otherXml, contains('<D:sql>test query</D:sql>'));
        expect(otherXml, isNot(contains('<D:basicsearch>')));
      });

      test('should include XML declaration', () {
        final searchRequest = SearchRequest(
          query: 'test',
          language: 'davbasic',
        );
        final xml = searchRequest.toXml();

        expect(xml, startsWith('<?xml version="1.0" encoding="utf-8"?>'));
      });

      test('should use proper namespace declaration', () {
        final searchRequest = SearchRequest(
          query: 'test',
          language: 'davbasic',
        );
        final xml = searchRequest.toXml();

        expect(xml, contains('<D:searchrequest xmlns:D="DAV:">'));
      });
    });

    group('Construction', () {
      test('should create with query and language', () {
        final searchRequest = SearchRequest(
          query: 'test query',
          language: 'davbasic',
        );

        expect(searchRequest.query, equals('test query'));
        expect(searchRequest.language, equals('davbasic'));
      });

      test('should create with empty query', () {
        final searchRequest = SearchRequest(query: '', language: 'sql');

        expect(searchRequest.query, equals(''));
        expect(searchRequest.language, equals('sql'));
      });

      test('should create with various languages', () {
        final languages = ['davbasic', 'sql', 'xpath', 'custom'];

        for (final language in languages) {
          final searchRequest = SearchRequest(
            query: 'test',
            language: language,
          );
          expect(searchRequest.language, equals(language));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle null or undefined language gracefully', () {
        final searchRequest = SearchRequest(query: 'test', language: 'unknown');
        final xml = searchRequest.toXml();

        // Unknown languages default to SQL format
        expect(xml, contains('<D:sql>test</D:sql>'));
      });

      test('should handle long queries', () {
        final longQuery = 'a' * 1000;
        final searchRequest = SearchRequest(
          query: longQuery,
          language: 'davbasic',
        );
        final xml = searchRequest.toXml();

        expect(xml, contains('<D:contains>$longQuery</D:contains>'));
      });

      test('should handle multiline queries', () {
        final multilineQuery = '''SELECT *
FROM SCOPE()
WHERE "DAV:displayname" LIKE '%test%'
ORDER BY "DAV:getlastmodified"''';
        final searchRequest = SearchRequest(
          query: multilineQuery,
          language: 'sql',
        );
        final xml = searchRequest.toXml();

        expect(xml, contains('<D:sql>$multilineQuery</D:sql>'));
      });

      test('should handle Unicode characters in query', () {
        final unicodeQuery = 'test 测试 🔍 документ';
        final searchRequest = SearchRequest(
          query: unicodeQuery,
          language: 'davbasic',
        );
        final xml = searchRequest.toXml();

        expect(xml, contains('<D:contains>$unicodeQuery</D:contains>'));
      });
    });

    group('XML Escaping', () {
      test('should escape ampersand', () {
        final searchRequest = SearchRequest(
          query: 'cats & dogs',
          language: 'davbasic',
        );
        final xml = searchRequest.toXml();

        expect(xml, contains('<D:contains>cats & dogs</D:contains>'));
      });

      test('should escape quotes', () {
        final searchRequest = SearchRequest(
          query: 'test "quoted" text',
          language: 'davbasic',
        );
        final xml = searchRequest.toXml();

        expect(xml, contains('<D:contains>test "quoted" text</D:contains>'));
      });

      test('should escape angle brackets', () {
        final searchRequest = SearchRequest(
          query: 'a < b > c',
          language: 'davbasic',
        );
        final xml = searchRequest.toXml();

        expect(xml, contains('<D:contains>a < b > c</D:contains>'));
      });

      test('should escape all XML special characters together', () {
        final searchRequest = SearchRequest(
          query: 'test & "quote" < tag > \'apostrophe\'',
          language: 'davbasic',
        );
        final xml = searchRequest.toXml();

        expect(
          xml,
          contains(
            '<D:contains>test & "quote" < tag > \'apostrophe\'</D:contains>',
          ),
        );
      });
    });
  });
}
