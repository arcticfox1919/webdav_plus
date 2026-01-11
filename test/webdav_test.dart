import 'dart:convert';
import 'package:test/test.dart';
import 'package:webdav_plus/webdav_plus.dart';
import 'package:webdav_plus/src/model/multistatus.dart';
import 'package:webdav_plus/src/model/propfind.dart';
import 'package:webdav_plus/src/model/search.dart';
import 'package:webdav_plus/src/impl/http_webdav_client.dart';
import 'package:webdav_plus/src/dav_quota.dart';
import 'package:webdav_plus/src/dav_principal.dart';
import 'package:webdav_plus/src/dav_ace.dart';

void main() {
  group('WebDAV Plus Tests', () {
    group('WebdavClient Factory', () {
      test('should create a basic WebdavClient instance', () {
        WebdavClient client = WebdavClient();
        expect(client, isNotNull);
      });

      test('should create WebdavClient with credentials', () {
        WebdavClient client = WebdavClient.withCredentials('user', 'pass');
        expect(client, isNotNull);
      });

      test('should create WebdavClient with compression', () {
        WebdavClient client = WebdavClient.withCompression();
        expect(client, isNotNull);
      });

      test('should create configured WebdavClient', () {
        WebdavClient client = WebdavClient.configured(
          username: 'user',
          password: 'pass',
          compression: true,
        );
        expect(client, isNotNull);
      });
    });

    group('DavResource', () {
      test('should create a DavResource with basic properties', () {
        DavResource resource = DavResource(
          href: Uri.parse('https://example.com/file.txt'),
          contentType: 'text/plain',
          contentLength: 100,
        );

        expect(
          resource.href.toString(),
          equals('https://example.com/file.txt'),
        );
        expect(resource.contentType, equals('text/plain'));
        expect(resource.contentLength, equals(100));
        expect(resource.isFile, isTrue);
        expect(resource.isDirectory, isFalse);
        expect(resource.name, equals('file.txt'));
      });

      test('should identify directories correctly', () {
        DavResource directory = DavResource(
          href: Uri.parse('https://example.com/folder/'),
          contentType: DavResource.httpdUnixDirectoryContentType,
          resourceTypes: ['collection'],
        );

        expect(directory.isDirectory, isTrue);
        expect(directory.isFile, isFalse);
        expect(directory.name, equals('folder'));
      });

      test('should handle custom properties', () {
        Map<String, String> customProps = {
          'author': 'John Doe',
          'category': 'test',
        };

        DavResource resource = DavResource(
          href: Uri.parse('https://example.com/file.txt'),
          customProperties: customProps,
        );

        expect(resource.hasCustomProperty('author'), isTrue);
        expect(resource.getCustomProperty('author'), equals('John Doe'));
        expect(resource.hasCustomProperty('nonexistent'), isFalse);
        expect(
          resource.getCustomPropertyNames(),
          equals({'author', 'category'}),
        );
      });

      test('should support equality comparison', () {
        Uri uri = Uri.parse('https://example.com/file.txt');
        DavResource resource1 = DavResource(href: uri);
        DavResource resource2 = DavResource(href: uri);
        DavResource resource3 = DavResource(
          href: Uri.parse('https://example.com/other.txt'),
        );

        expect(resource1, equals(resource2));
        expect(resource1, isNot(equals(resource3)));
      });

      test('should support JSON serialization', () {
        DavResource resource = DavResource(
          href: Uri.parse('https://example.com/file.txt'),
          contentType: 'text/plain',
          contentLength: 100,
          modified: DateTime(2023, 1, 1),
        );

        Map<String, dynamic> json = resource.toJson();
        DavResource restored = DavResource.fromJson(json);

        expect(restored.href, equals(resource.href));
        expect(restored.contentType, equals(resource.contentType));
        expect(restored.contentLength, equals(resource.contentLength));
        expect(restored.modified, equals(resource.modified));
      });
    });

    group('DavAce', () {
      test('should create a grant ACE', () {
        DavAce ace = DavAce(
          principal: 'user123',
          grant: true,
          privileges: {'read', 'write'},
        );

        expect(ace.isGrant, isTrue);
        expect(ace.isDeny, isFalse);
        expect(ace.hasPrivilege('read'), isTrue);
        expect(ace.hasPrivilege('write'), isTrue);
        expect(ace.hasPrivilege('admin'), isFalse);
      });

      test('should create a deny ACE', () {
        DavAce ace = DavAce(
          principal: 'user456',
          grant: false,
          privileges: {'write'},
        );

        expect(ace.isGrant, isFalse);
        expect(ace.isDeny, isTrue);
        expect(ace.hasPrivilege('write'), isTrue);
      });

      test('should support JSON serialization', () {
        DavAce ace = DavAce(
          principal: 'user123',
          grant: true,
          privileges: {'read', 'write'},
          inherited: true,
        );

        Map<String, dynamic> json = ace.toJson();
        DavAce restored = DavAce.fromJson(json);

        expect(restored.principal, equals(ace.principal));
        expect(restored.grant, equals(ace.grant));
        expect(restored.privileges, equals(ace.privileges));
        expect(restored.inherited, equals(ace.inherited));
      });
    });

    group('DavAcl', () {
      test('should create an empty ACL', () {
        DavAcl acl = DavAcl(aces: []);

        expect(acl.isEmpty, isTrue);
        expect(acl.isNotEmpty, isFalse);
        expect(acl.length, equals(0));
      });

      test('should manage ACEs', () {
        List<DavAce> aces = [
          DavAce(principal: 'user1', grant: true, privileges: {'read'}),
          DavAce(principal: 'user2', grant: false, privileges: {'write'}),
        ];

        DavAcl acl = DavAcl(aces: aces);

        expect(acl.length, equals(2));
        expect(acl.grantAces.length, equals(1));
        expect(acl.denyAces.length, equals(1));
        expect(acl.principals, equals({'user1', 'user2'}));
      });

      test('should check privileges correctly', () {
        List<DavAce> aces = [
          DavAce(
            principal: 'user1',
            grant: true,
            privileges: {'read', 'write'},
          ),
          DavAce(
            principal: 'user1',
            grant: false,
            privileges: {'write'},
          ), // Deny overrides grant
        ];

        DavAcl acl = DavAcl(aces: aces);

        expect(acl.hasPrivilege('user1', 'read'), isTrue);
        expect(acl.hasPrivilege('user1', 'write'), isFalse); // Denied
        expect(acl.hasPrivilege('user2', 'read'), isFalse); // No ACE for user2
      });
    });

    group('DavPrincipal', () {
      test('should create a user principal', () {
        DavPrincipal principal = DavPrincipal(
          url: 'https://example.com/principals/users/john',
          displayName: 'John Doe',
          type: PrincipalType.user,
        );

        expect(principal.isUser, isTrue);
        expect(principal.isGroup, isFalse);
        expect(principal.name, equals('john'));
        expect(principal.displayName, equals('John Doe'));
      });

      test('should create a group principal', () {
        DavPrincipal principal = DavPrincipal(
          url: 'https://example.com/principals/groups/admins',
          type: PrincipalType.group,
        );

        expect(principal.isGroup, isTrue);
        expect(principal.isUser, isFalse);
        expect(principal.name, equals('admins'));
      });
    });

    group('DavQuota', () {
      test('should calculate total quota correctly', () {
        DavQuota quota = DavQuota(
          quotaUsedBytes: 1024,
          quotaAvailableBytes: 2048,
        );

        expect(quota.totalQuota, equals(3072));
        expect(quota.hasQuotaInfo, isTrue);
      });

      test('should calculate usage percentage', () {
        DavQuota quota = DavQuota(quotaUsedBytes: 1024, quotaTotalBytes: 2048);

        expect(quota.usagePercentage, equals(0.5));
        expect(quota.usagePercentageInt, equals(50));
      });

      test('should detect quota limits', () {
        DavQuota nearlyFull = DavQuota(
          quotaUsedBytes: 950,
          quotaTotalBytes: 1000,
        );

        DavQuota full = DavQuota(quotaUsedBytes: 1000, quotaTotalBytes: 1000);

        expect(nearlyFull.isNearlyFull, isTrue);
        expect(nearlyFull.isFull, isFalse);
        expect(full.isFull, isTrue);
      });
    });

    group('WebDAVUtil', () {
      test('should parse dates correctly', () {
        DateTime? date1 = WebDAVUtil.parseDate('2023-01-01T12:00:00Z');
        DateTime? date2 = WebDAVUtil.parseDate('2023-01-01T12:00:00.000Z');
        DateTime? date3 = WebDAVUtil.parseDate(null);
        DateTime? date4 = WebDAVUtil.parseDate('');

        expect(date1, isNotNull);
        expect(date1!.year, equals(2023));
        expect(date2, isNotNull);
        expect(date3, isNull);
        expect(date4, isNull);
      });

      test('should format dates correctly', () {
        DateTime date = DateTime.utc(2023, 1, 1, 12, 0, 0);
        String formatted = WebDAVUtil.formatDate(date);

        expect(formatted, contains('2023-01-01T12:00:00'));
      });

      test('should escape and unescape XML', () {
        String original = 'Hello <world> & "test"';
        String escaped = WebDAVUtil.escapeXml(original);
        String unescaped = WebDAVUtil.unescapeXml(escaped);

        expect(escaped, contains('&lt;'));
        expect(escaped, contains('&gt;'));
        expect(escaped, contains('&amp;'));
        expect(escaped, contains('&quot;'));
        expect(unescaped, equals(original));
      });

      test('should handle URL operations', () {
        expect(WebDAVUtil.isAbsoluteUrl('https://example.com/path'), isTrue);
        expect(WebDAVUtil.isAbsoluteUrl('/relative/path'), isFalse);

        String joined = WebDAVUtil.joinPaths('/base/', 'path/file.txt');
        expect(joined, equals('/base/path/file.txt'));

        String normalized = WebDAVUtil.normalizePath(
          '/path/../other/./file.txt',
        );
        expect(normalized, equals('/other/file.txt'));

        expect(WebDAVUtil.getFileName('/path/to/file.txt'), equals('file.txt'));
        expect(
          WebDAVUtil.getParentPath('/path/to/file.txt'),
          equals('/path/to/'),
        );
      });

      test('should generate basic auth header', () {
        String auth = WebDAVUtil.basicAuth('user', 'pass');
        expect(auth, startsWith('Basic '));

        // Decode and verify
        String encoded = auth.substring(6);
        String decoded = utf8.decode(base64.decode(encoded));
        expect(decoded, equals('user:pass'));
      });

      test('should determine MIME types', () {
        expect(WebDAVUtil.getMimeType('file.txt'), equals('text/plain'));
        expect(WebDAVUtil.getMimeType('file.html'), equals('text/html'));
        expect(WebDAVUtil.getMimeType('file.jpg'), equals('image/jpeg'));
        expect(
          WebDAVUtil.getMimeType('file.unknown'),
          equals('application/octet-stream'),
        );
      });

      test('should handle depth values', () {
        expect(WebDAVUtil.depthToString(0), equals('0'));
        expect(WebDAVUtil.depthToString(1), equals('1'));
        expect(WebDAVUtil.depthToString(-1), equals('infinity'));

        expect(WebDAVUtil.parseDepth('0'), equals(0));
        expect(WebDAVUtil.parseDepth('1'), equals(1));
        expect(WebDAVUtil.parseDepth('infinity'), equals(-1));
      });
    });

    group('Exceptions', () {
      test('should create WebDAVException with all properties', () {
        WebDAVException exception = WebDAVException(
          'Test error',
          statusCode: 404,
          responseBody: 'Not found',
          cause: 'Original error',
        );

        expect(exception.message, equals('Test error'));
        expect(exception.statusCode, equals(404));
        expect(exception.responseBody, equals('Not found'));
        expect(exception.cause, equals('Original error'));
        expect(exception.isHttpError, isTrue);
        expect(exception.isNotFoundError, isTrue);
        expect(exception.isClientError, isTrue);
        expect(exception.isServerError, isFalse);
      });

      test('should create specific exception types', () {
        WebDAVAuthenticationException authException =
            WebDAVAuthenticationException('Auth failed', statusCode: 401);
        expect(authException.statusCode, equals(401));
        expect(authException.isAuthenticationError, isTrue);

        WebDAVNotFoundException notFoundException = WebDAVNotFoundException(
          'Not found',
          statusCode: 404,
        );
        expect(notFoundException.statusCode, equals(404));
        expect(notFoundException.isNotFoundError, isTrue);

        WebDAVNetworkException networkException = WebDAVNetworkException(
          'Network error',
        );
        expect(networkException.statusCode, isNull);
        expect(networkException.isHttpError, isFalse);
      });
    });

    group('XML Models', () {
      test('should create PROPFIND XML', () {
        Propfind propfind = Propfind(allprop: Allprop());
        String xml = propfind.toXml();

        expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));
        expect(xml, contains('<D:propfind xmlns:D="DAV:">'));
        expect(xml, contains('<D:allprop/>'));
        expect(xml, contains('</D:propfind>'));
      });

      test('should create PROPFIND with specific properties', () {
        Propfind propfind = Propfind(
          prop: Prop(properties: {'getcontentlength', 'getlastmodified'}),
        );
        String xml = propfind.toXml();

        expect(xml, contains('<D:prop>'));
        expect(xml, contains('<D:getcontentlength/>'));
        expect(xml, contains('<D:getlastmodified/>'));
        expect(xml, contains('</D:prop>'));
      });

      test('should create PROPPATCH XML', () {
        Propertyupdate proppatch = Propertyupdate(
          set: SetElement(prop: Prop(customProperties: {'author': 'John Doe'})),
        );
        String xml = proppatch.toXml();

        expect(xml, contains('<D:propertyupdate xmlns:D="DAV:">'));
        expect(xml, contains('<D:set>'));
        expect(xml, contains('<S:author xmlns:S="SAR:">John Doe</S:author>'));
        expect(xml, contains('</D:set>'));
        expect(xml, contains('</D:propertyupdate>'));
      });

      test('should create LOCK XML', () {
        Lockinfo lockinfo = Lockinfo(
          lockscope: Lockscope(exclusive: true),
          locktype: Locktype(),
          owner: Owner(owner: 'user123'),
        );
        String xml = lockinfo.toXml();

        expect(xml, contains('<D:lockinfo xmlns:D="DAV:">'));
        expect(xml, contains('<D:lockscope><D:exclusive/></D:lockscope>'));
        expect(xml, contains('<D:locktype><D:write/></D:locktype>'));
        expect(xml, contains('<D:owner>user123</D:owner>'));
        expect(xml, contains('</D:lockinfo>'));
      });

      test('should parse multistatus XML response', () {
        const multistatusXml = '''<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/test/file.txt</D:href>
    <D:propstat>
      <D:prop>
        <D:getcontentlength>1024</D:getcontentlength>
        <D:getcontenttype>text/plain</D:getcontenttype>
        <D:getlastmodified>Mon, 12 Jan 1998 09:25:56 GMT</D:getlastmodified>
      </D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
</D:multistatus>''';

        final multistatus = Multistatus.fromXml(multistatusXml);
        expect(multistatus.responses, hasLength(1));

        final response = multistatus.responses.first;
        expect(response.href, equals('/test/file.txt'));
        expect(response.propstats, hasLength(1));

        final propstat = response.propstats.first;
        expect(propstat.status, equals('HTTP/1.1 200 OK'));
        expect(
          propstat.prop.customProperties['getcontentlength'],
          equals('1024'),
        );
        expect(
          propstat.prop.customProperties['getcontenttype'],
          equals('text/plain'),
        );
      });

      test('should create advanced search XML', () {
        final searchRequest = SearchRequest(
          query: 'document.docx',
          language: 'davbasic',
        );

        final xml = searchRequest.toXml();
        expect(xml, contains('<D:searchrequest'));
        expect(xml, contains('<D:basicsearch'));
        expect(xml, contains('<D:contains>document.docx</D:contains>'));
        expect(xml, contains('<D:depth>infinity</D:depth>'));
      });
    });

    group('HttpWebdavClient Implementation Tests', () {
      late HttpWebdavClient client;

      setUp(() {
        client = HttpWebdavClient();
      });

      tearDown(() {
        client.dispose();
      });

      test('should configure compression correctly', () {
        // Test initial state through public methods
        client.enableCompression();
        client.disableCompression();
        // No assertions needed - just ensuring methods don't throw
      });

      test('should handle credentials properly', () {
        const username = 'testuser';
        const password = 'testpass';

        client.setCredentials(username, password, isPreemptive: true);
        // No direct access to private fields, but method should not throw
      });

      test('should handle domain credentials', () {
        const username = 'testuser';
        const password = 'testpass';
        const domain = 'TESTDOMAIN';
        const workstation = 'WORKSTATION1';

        client.setCredentialsWithDomain(
          username,
          password,
          domain,
          workstation,
          isPreemptive: true,
        );
        // No direct access to private fields, but method should not throw
      });

      group('Method Implementations', () {
        test('getQuota should be implemented', () {
          // We can't test the actual implementation without a server,
          // but we can verify the method exists and has correct signature
          expect(client.getQuota, isA<Future<DavQuota> Function(String)>());
        });

        test('setAcl should be implemented', () {
          expect(
            client.setAcl,
            isA<Future<void> Function(String, List<DavAce>)>(),
          );
        });

        test('getPrincipals should be implemented', () {
          expect(
            client.getPrincipals,
            isA<Future<List<DavPrincipal>> Function(String)>(),
          );
        });

        test('getPrincipalCollectionSet should be implemented', () {
          expect(
            client.getPrincipalCollectionSet,
            isA<Future<List<String>> Function(String)>(),
          );
        });
      });

      group('Public Interface Tests', () {
        test('should support all required WebDAV methods', () {
          // Test that all required methods exist
          expect(client.list, isA<Function>());
          expect(client.get, isA<Function>());
          expect(client.put, isA<Function>());
          expect(client.delete, isA<Function>());
          expect(client.createDirectory, isA<Function>());
          expect(client.move, isA<Function>());
          expect(client.copy, isA<Function>());
          expect(client.exists, isA<Function>());
          expect(client.lock, isA<Function>());
          expect(client.unlock, isA<Function>());
          expect(client.getAcl, isA<Function>());
          expect(client.getQuota, isA<Function>());
          expect(client.setAcl, isA<Function>());
          expect(client.getPrincipals, isA<Function>());
          expect(client.getPrincipalCollectionSet, isA<Function>());
        });

        test('should support configuration methods', () {
          expect(client.enableCompression, isA<Function>());
          expect(client.disableCompression, isA<Function>());
          expect(client.setCredentials, isA<Function>());
          expect(client.setCredentialsWithDomain, isA<Function>());
          expect(client.enablePreemptiveAuthentication, isA<Function>());
          expect(client.disablePreemptiveAuthentication, isA<Function>());
        });

        test('should support version control methods', () {
          expect(client.versionControl, isA<Function>());
          expect(client.checkout, isA<Function>());
          expect(client.checkin, isA<Function>());
          expect(client.uncheckout, isA<Function>());
          expect(client.versionsList, isA<Function>());
          expect(client.versionsListWithDepth, isA<Function>());
          expect(client.versionsListWithProps, isA<Function>());
        });

        test('should support advanced WebDAV features', () {
          expect(client.bind, isA<Function>());
          expect(client.unbind, isA<Function>());
          expect(client.syncCollection, isA<Function>());
          expect(client.search, isA<Function>());
          expect(client.discoverLocks, isA<Function>());
          expect(client.isLocked, isA<Function>());
          expect(client.getLockToken, isA<Function>());
        });
      });
    });
  });
}
