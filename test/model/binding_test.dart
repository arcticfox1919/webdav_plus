import 'package:test/test.dart';
import 'package:webdav_plus/src/model/binding.dart';

void main() {
  group('Bind', () {
    group('XML Generation', () {
      test('should generate bind request XML', () {
        final bind = Bind(
          segment: 'newname.txt',
          href: '/path/to/existing/resource.txt',
        );
        final xml = bind.toXml();

        expect(xml, contains('<D:bind xmlns:D="DAV:">'));
        expect(xml, contains('<D:segment>newname.txt</D:segment>'));
        expect(
          xml,
          contains('<D:href>/path/to/existing/resource.txt</D:href>'),
        );
        expect(xml, contains('</D:bind>'));
      });

      test('should generate bind request with different paths', () {
        final bind = Bind(
          segment: 'document.pdf',
          href: '/documents/reports/annual-report.pdf',
        );
        final xml = bind.toXml();

        expect(xml, contains('<D:segment>document.pdf</D:segment>'));
        expect(
          xml,
          contains('<D:href>/documents/reports/annual-report.pdf</D:href>'),
        );
      });

      test('should generate bind request with special characters', () {
        final bind = Bind(
          segment: 'file with spaces & special chars.txt',
          href: '/path/to/file with spaces & special chars.txt',
        );
        final xml = bind.toXml();

        expect(
          xml,
          contains(
            '<D:segment>file with spaces & special chars.txt</D:segment>',
          ),
        );
        expect(
          xml,
          contains(
            '<D:href>/path/to/file with spaces & special chars.txt</D:href>',
          ),
        );
      });

      test('should generate bind request with Unicode characters', () {
        final bind = Bind(segment: '测试文档.txt', href: '/documents/测试文档.txt');
        final xml = bind.toXml();

        expect(xml, contains('<D:segment>测试文档.txt</D:segment>'));
        expect(xml, contains('<D:href>/documents/测试文档.txt</D:href>'));
      });

      test('should generate bind request with URL encoded paths', () {
        final bind = Bind(
          segment: 'encoded%20file.txt',
          href: '/path/to/encoded%20file.txt',
        );
        final xml = bind.toXml();

        expect(xml, contains('<D:segment>encoded%20file.txt</D:segment>'));
        expect(xml, contains('<D:href>/path/to/encoded%20file.txt</D:href>'));
      });

      test('should include namespace declaration', () {
        final bind = Bind(segment: 'test', href: '/test');
        final xml = bind.toXml();

        expect(xml, contains('xmlns:D="DAV:"'));
      });
    });

    group('Construction', () {
      test('should create with segment and href', () {
        final bind = Bind(segment: 'test-segment', href: '/test/href');

        expect(bind.segment, equals('test-segment'));
        expect(bind.href, equals('/test/href'));
      });

      test('should create with empty values', () {
        final bind = Bind(segment: '', href: '');

        expect(bind.segment, equals(''));
        expect(bind.href, equals(''));
      });

      test('should create with long values', () {
        final longSegment = 'a' * 200;
        final longHref = '/path/to/${'very-long-filename' * 10}.txt';
        final bind = Bind(segment: longSegment, href: longHref);

        expect(bind.segment, equals(longSegment));
        expect(bind.href, equals(longHref));
      });
    });

    group('Edge Cases', () {
      test('should handle root path href', () {
        final bind = Bind(segment: 'root-file', href: '/');
        final xml = bind.toXml();

        expect(xml, contains('<D:href>/</D:href>'));
      });

      test('should handle relative href', () {
        final bind = Bind(segment: 'relative-file', href: 'relative/path');
        final xml = bind.toXml();

        expect(xml, contains('<D:href>relative/path</D:href>'));
      });

      test('should handle absolute URL href', () {
        final bind = Bind(
          segment: 'external-file',
          href: 'http://example.com/file.txt',
        );
        final xml = bind.toXml();

        expect(xml, contains('<D:href>http://example.com/file.txt</D:href>'));
      });
    });
  });

  group('UnBind', () {
    group('XML Generation', () {
      test('should generate unbind request XML', () {
        final unbind = UnBind(segment: 'oldname.txt');
        final xml = unbind.toXml();

        expect(xml, contains('<D:unbind xmlns:D="DAV:">'));
        expect(xml, contains('<D:segment>oldname.txt</D:segment>'));
        expect(xml, contains('</D:unbind>'));
      });

      test('should generate unbind request with different segment', () {
        final unbind = UnBind(segment: 'document-to-remove.pdf');
        final xml = unbind.toXml();

        expect(xml, contains('<D:segment>document-to-remove.pdf</D:segment>'));
      });

      test('should generate unbind request with special characters', () {
        final unbind = UnBind(segment: 'file with spaces & special chars.txt');
        final xml = unbind.toXml();

        expect(
          xml,
          contains(
            '<D:segment>file with spaces & special chars.txt</D:segment>',
          ),
        );
      });

      test('should generate unbind request with Unicode characters', () {
        final unbind = UnBind(segment: '要删除的文档.txt');
        final xml = unbind.toXml();

        expect(xml, contains('<D:segment>要删除的文档.txt</D:segment>'));
      });

      test('should generate unbind request with URL encoded segment', () {
        final unbind = UnBind(segment: 'encoded%20file.txt');
        final xml = unbind.toXml();

        expect(xml, contains('<D:segment>encoded%20file.txt</D:segment>'));
      });

      test('should include namespace declaration', () {
        final unbind = UnBind(segment: 'test');
        final xml = unbind.toXml();

        expect(xml, contains('xmlns:D="DAV:"'));
      });
    });

    group('Construction', () {
      test('should create with segment', () {
        final unbind = UnBind(segment: 'test-segment');
        expect(unbind.segment, equals('test-segment'));
      });

      test('should create with empty segment', () {
        final unbind = UnBind(segment: '');
        expect(unbind.segment, equals(''));
      });

      test('should create with long segment', () {
        final longSegment = 'very-long-filename-' * 10 + '.txt';
        final unbind = UnBind(segment: longSegment);
        expect(unbind.segment, equals(longSegment));
      });
    });

    group('Edge Cases', () {
      test('should handle directory segment', () {
        final unbind = UnBind(segment: 'directory/');
        final xml = unbind.toXml();

        expect(xml, contains('<D:segment>directory/</D:segment>'));
      });

      test('should handle segment with path separators', () {
        final unbind = UnBind(segment: 'path/to/file.txt');
        final xml = unbind.toXml();

        expect(xml, contains('<D:segment>path/to/file.txt</D:segment>'));
      });

      test('should handle segment with query parameters', () {
        final unbind = UnBind(segment: 'file.txt?version=1');
        final xml = unbind.toXml();

        expect(xml, contains('<D:segment>file.txt?version=1</D:segment>'));
      });
    });
  });

  group('Segment', () {
    group('XML Generation', () {
      test('should generate segment XML', () {
        final segment = Segment(value: 'filename.txt');
        final xml = segment.toXml();

        expect(xml, equals('<D:segment>filename.txt</D:segment>'));
      });

      test('should generate segment with special characters', () {
        final segment = Segment(value: 'file with spaces & symbols.txt');
        final xml = segment.toXml();

        expect(
          xml,
          equals('<D:segment>file with spaces & symbols.txt</D:segment>'),
        );
      });

      test('should generate segment with Unicode', () {
        final segment = Segment(value: '文档.txt');
        final xml = segment.toXml();

        expect(xml, equals('<D:segment>文档.txt</D:segment>'));
      });

      test('should generate empty segment', () {
        final segment = Segment(value: '');
        final xml = segment.toXml();

        expect(xml, equals('<D:segment></D:segment>'));
      });

      test('should generate segment with URL encoding', () {
        final segment = Segment(value: 'encoded%20filename.txt');
        final xml = segment.toXml();

        expect(xml, equals('<D:segment>encoded%20filename.txt</D:segment>'));
      });
    });

    group('Construction', () {
      test('should create with value', () {
        final segment = Segment(value: 'test-value');
        expect(segment.value, equals('test-value'));
      });

      test('should create with empty value', () {
        final segment = Segment(value: '');
        expect(segment.value, equals(''));
      });

      test('should create with complex value', () {
        final complexValue = 'path/to/file with spaces & symbols (2023).txt';
        final segment = Segment(value: complexValue);
        expect(segment.value, equals(complexValue));
      });
    });

    group('Edge Cases', () {
      test('should handle values with XML special characters', () {
        final segment = Segment(value: 'file<test>&"quotes".txt');
        final xml = segment.toXml();

        expect(xml, equals('<D:segment>file<test>&"quotes".txt</D:segment>'));
      });

      test('should handle very long values', () {
        final longValue = 'very-long-filename-' * 20 + '.txt';
        final segment = Segment(value: longValue);
        final xml = segment.toXml();

        expect(xml, equals('<D:segment>$longValue</D:segment>'));
      });

      test('should handle values with newlines', () {
        final segment = Segment(value: 'line1\nline2');
        final xml = segment.toXml();

        expect(xml, equals('<D:segment>line1\nline2</D:segment>'));
      });

      test('should handle values with tabs', () {
        final segment = Segment(value: 'tab\tseparated');
        final xml = segment.toXml();

        expect(xml, equals('<D:segment>tab\tseparated</D:segment>'));
      });
    });
  });

  group('Binding Protocol Integration', () {
    group('BIND Operation', () {
      test('should create proper BIND request', () {
        final bind = Bind(
          segment: 'alias.txt',
          href: '/original/path/file.txt',
        );
        final xml = bind.toXml();

        // Should be a complete, well-formed XML for BIND request
        expect(xml, startsWith('<D:bind xmlns:D="DAV:">'));
        expect(xml, endsWith('</D:bind>'));
        expect(xml, contains('<D:segment>alias.txt</D:segment>'));
        expect(xml, contains('<D:href>/original/path/file.txt</D:href>'));
      });

      test('should create BIND for collection', () {
        final bind = Bind(
          segment: 'shared-folder',
          href: '/users/john/documents/',
        );
        final xml = bind.toXml();

        expect(xml, contains('<D:segment>shared-folder</D:segment>'));
        expect(xml, contains('<D:href>/users/john/documents/</D:href>'));
      });
    });

    group('UNBIND Operation', () {
      test('should create proper UNBIND request', () {
        final unbind = UnBind(segment: 'alias-to-remove.txt');
        final xml = unbind.toXml();

        // Should be a complete, well-formed XML for UNBIND request
        expect(xml, startsWith('<D:unbind xmlns:D="DAV:">'));
        expect(xml, endsWith('</D:unbind>'));
        expect(xml, contains('<D:segment>alias-to-remove.txt</D:segment>'));
      });

      test('should create UNBIND for collection', () {
        final unbind = UnBind(segment: 'old-shared-folder');
        final xml = unbind.toXml();

        expect(xml, contains('<D:segment>old-shared-folder</D:segment>'));
      });
    });

    group('Workflow Example', () {
      test('should demonstrate typical bind/unbind workflow', () {
        // Create a new binding
        final bind = Bind(
          segment: 'current-project',
          href: '/projects/2023/important-project/',
        );
        final bindXml = bind.toXml();

        expect(bindXml, contains('<D:bind xmlns:D="DAV:">'));
        expect(bindXml, contains('<D:segment>current-project</D:segment>'));

        // Later, remove the binding
        final unbind = UnBind(segment: 'current-project');
        final unbindXml = unbind.toXml();

        expect(unbindXml, contains('<D:unbind xmlns:D="DAV:">'));
        expect(unbindXml, contains('<D:segment>current-project</D:segment>'));
      });
    });
  });
}
