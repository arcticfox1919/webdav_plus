import 'package:test/test.dart';
import 'package:webdav_plus/src/model/properties.dart';

void main() {
  group('Resourcetype', () {
    test('should create collection resource type', () {
      final resourcetype = Resourcetype(isCollection: true);

      expect(resourcetype.isCollection, isTrue);
      expect(resourcetype.customTypes, isEmpty);
    });

    test('should create non-collection resource type', () {
      final resourcetype = Resourcetype(isCollection: false);

      expect(resourcetype.isCollection, isFalse);
      expect(resourcetype.customTypes, isEmpty);
    });

    test('should create resource type with custom types', () {
      final customTypes = <String>['custom1', 'custom2'];
      final resourcetype = Resourcetype(
        isCollection: false,
        customTypes: customTypes,
      );

      expect(resourcetype.isCollection, isFalse);
      expect(resourcetype.customTypes, equals(customTypes));
    });

    test('should generate correct XML for collection', () {
      final resourcetype = Resourcetype(isCollection: true);
      final xml = resourcetype.toXml();

      expect(xml, contains('<D:resourcetype>'));
      expect(xml, contains('<D:collection/>'));
      expect(xml, contains('</D:resourcetype>'));
    });

    test('should generate correct XML for non-collection', () {
      final resourcetype = Resourcetype(isCollection: false);
      final xml = resourcetype.toXml();

      expect(xml, equals('<D:resourcetype>\n</D:resourcetype>'));
    });

    test('should generate correct XML with custom types', () {
      final resourcetype = Resourcetype(
        isCollection: true,
        customTypes: ['custom1', 'custom2'],
      );
      final xml = resourcetype.toXml();

      expect(xml, contains('<D:resourcetype>'));
      expect(xml, contains('<D:collection/>'));
      expect(xml, contains('custom1'));
      expect(xml, contains('custom2'));
      expect(xml, contains('</D:resourcetype>'));
    });
  });

  group('Collection', () {
    test('should create collection constant', () {
      const collection = Collection();

      expect(collection, isNotNull);
    });

    test('should generate correct XML', () {
      const collection = Collection();
      final xml = collection.toXml();

      expect(xml, equals('<D:collection/>'));
    });
  });

  group('Creationdate', () {
    test('should create with date', () {
      final date = DateTime(2023, 12, 25, 10, 30, 45);
      final creationdate = Creationdate(date: date);

      expect(creationdate.date, equals(date));
    });

    test('should generate correct XML', () {
      final date = DateTime(2023, 12, 25, 10, 30, 45);
      final creationdate = Creationdate(date: date);
      final xml = creationdate.toXml();

      expect(xml, contains('<D:creationdate>'));
      expect(xml, contains(date.toIso8601String()));
      expect(xml, contains('</D:creationdate>'));
    });
  });

  group('Displayname', () {
    test('should create with name', () {
      const displayname = Displayname(name: 'Test Display Name');

      expect(displayname.name, equals('Test Display Name'));
    });

    test('should generate correct XML', () {
      const displayname = Displayname(name: 'Test Display Name');
      final xml = displayname.toXml();

      expect(xml, equals('<D:displayname>Test Display Name</D:displayname>'));
    });

    test('should handle empty name', () {
      const displayname = Displayname(name: '');
      final xml = displayname.toXml();

      expect(xml, equals('<D:displayname></D:displayname>'));
    });
  });

  group('Getcontentlanguage', () {
    test('should create with language', () {
      const contentLanguage = Getcontentlanguage(language: 'en-US');

      expect(contentLanguage.language, equals('en-US'));
    });

    test('should generate correct XML', () {
      const contentLanguage = Getcontentlanguage(language: 'en-US');
      final xml = contentLanguage.toXml();

      expect(xml, equals('<D:getcontentlanguage>en-US</D:getcontentlanguage>'));
    });
  });

  group('Getcontentlength', () {
    test('should create with length', () {
      const contentLength = Getcontentlength(length: 1024);

      expect(contentLength.length, equals(1024));
    });

    test('should generate correct XML', () {
      const contentLength = Getcontentlength(length: 1024);
      final xml = contentLength.toXml();

      expect(xml, equals('<D:getcontentlength>1024</D:getcontentlength>'));
    });

    test('should handle zero length', () {
      const contentLength = Getcontentlength(length: 0);
      final xml = contentLength.toXml();

      expect(xml, equals('<D:getcontentlength>0</D:getcontentlength>'));
    });
  });

  group('Getcontenttype', () {
    test('should create with content type', () {
      const contentType = Getcontenttype(contentType: 'text/html');

      expect(contentType.contentType, equals('text/html'));
    });

    test('should generate correct XML', () {
      const contentType = Getcontenttype(contentType: 'text/html');
      final xml = contentType.toXml();

      expect(xml, equals('<D:getcontenttype>text/html</D:getcontenttype>'));
    });
  });

  group('Getetag', () {
    test('should create with etag', () {
      const etag = Getetag(etag: '"12345-abcdef"');

      expect(etag.etag, equals('"12345-abcdef"'));
    });

    test('should generate correct XML', () {
      const etag = Getetag(etag: '"12345-abcdef"');
      final xml = etag.toXml();

      expect(xml, equals('<D:getetag>"12345-abcdef"</D:getetag>'));
    });
  });

  group('Getlastmodified', () {
    test('should create with date', () {
      final date = DateTime(2023, 12, 25, 10, 30, 45);
      final lastModified = Getlastmodified(date: date);

      expect(lastModified.date, equals(date));
    });

    test('should generate correct XML with UTC conversion', () {
      final date = DateTime(2023, 12, 25, 10, 30, 45);
      final lastModified = Getlastmodified(date: date);
      final xml = lastModified.toXml();

      expect(xml, contains('<D:getlastmodified>'));
      expect(xml, contains(date.toUtc().toString()));
      expect(xml, contains('</D:getlastmodified>'));
    });
  });

  group('QuotaAvailableBytes', () {
    test('should create with bytes string', () {
      const quota = QuotaAvailableBytes(bytes: '1048576');

      expect(quota.bytes, equals('1048576'));
    });

    test('should generate correct XML', () {
      const quota = QuotaAvailableBytes(bytes: '1048576');
      final xml = quota.toXml();

      expect(
        xml,
        equals('<D:quota-available-bytes>1048576</D:quota-available-bytes>'),
      );
    });
  });

  group('QuotaUsedBytes', () {
    test('should create with bytes string', () {
      const quota = QuotaUsedBytes(bytes: '524288');

      expect(quota.bytes, equals('524288'));
    });

    test('should generate correct XML', () {
      const quota = QuotaUsedBytes(bytes: '524288');
      final xml = quota.toXml();

      expect(xml, equals('<D:quota-used-bytes>524288</D:quota-used-bytes>'));
    });
  });

  group('Link', () {
    test('should create with src and dst', () {
      const link = Link(src: '/source/path', dst: '/dest/path');

      expect(link.src, equals('/source/path'));
      expect(link.dst, equals('/dest/path'));
    });

    test('should generate correct XML', () {
      const link = Link(src: '/source/path', dst: '/dest/path');
      final xml = link.toXml();

      expect(xml, contains('<D:link>'));
      expect(xml, contains('<D:src>/source/path</D:src>'));
      expect(xml, contains('<D:dst>/dest/path</D:dst>'));
      expect(xml, contains('</D:link>'));
    });
  });

  group('Source', () {
    test('should create with empty links', () {
      const source = Source();

      expect(source.links, isEmpty);
    });

    test('should create with links', () {
      const links = [
        Link(src: '/src1', dst: '/dst1'),
        Link(src: '/src2', dst: '/dst2'),
      ];
      const source = Source(links: links);

      expect(source.links, equals(links));
    });

    test('should generate correct XML for empty source', () {
      const source = Source();
      final xml = source.toXml();

      expect(xml, contains('<D:source>'));
      expect(xml, contains('</D:source>'));
    });

    test('should generate correct XML with links', () {
      const source = Source(
        links: [
          Link(src: '/src1', dst: '/dst1'),
          Link(src: '/src2', dst: '/dst2'),
        ],
      );
      final xml = source.toXml();

      expect(xml, contains('<D:source>'));
      expect(xml, contains('<D:link>'));
      expect(xml, contains('/src1'));
      expect(xml, contains('/dst1'));
      expect(xml, contains('/src2'));
      expect(xml, contains('/dst2'));
      expect(xml, contains('</D:source>'));
    });
  });

  group('Lockentry', () {
    test('should create with lockscope and locktype', () {
      const lockentry = Lockentry(lockscope: 'exclusive', locktype: 'write');

      expect(lockentry.lockscope, equals('exclusive'));
      expect(lockentry.locktype, equals('write'));
    });

    test('should generate correct XML', () {
      const lockentry = Lockentry(lockscope: 'exclusive', locktype: 'write');
      final xml = lockentry.toXml();

      expect(xml, contains('<D:lockentry>'));
      expect(xml, contains('<D:lockscope>'));
      expect(xml, contains('<D:exclusive/>'));
      expect(xml, contains('</D:lockscope>'));
      expect(xml, contains('<D:locktype>'));
      expect(xml, contains('<D:write/>'));
      expect(xml, contains('</D:locktype>'));
      expect(xml, contains('</D:lockentry>'));
    });

    test('should handle shared lockscope', () {
      const lockentry = Lockentry(lockscope: 'shared', locktype: 'write');
      final xml = lockentry.toXml();

      expect(xml, contains('<D:shared/>'));
    });
  });

  group('Supportedlock', () {
    test('should create with empty lockentries', () {
      const supportedlock = Supportedlock();

      expect(supportedlock.lockentries, isEmpty);
    });

    test('should create with lockentries', () {
      const lockentries = [
        Lockentry(lockscope: 'exclusive', locktype: 'write'),
        Lockentry(lockscope: 'shared', locktype: 'write'),
      ];
      const supportedlock = Supportedlock(lockentries: lockentries);

      expect(supportedlock.lockentries, equals(lockentries));
    });

    test('should generate correct XML for empty supportedlock', () {
      const supportedlock = Supportedlock();
      final xml = supportedlock.toXml();

      expect(xml, contains('<D:supportedlock>'));
      expect(xml, contains('</D:supportedlock>'));
    });

    test('should generate correct XML with lockentries', () {
      const supportedlock = Supportedlock(
        lockentries: [
          Lockentry(lockscope: 'exclusive', locktype: 'write'),
          Lockentry(lockscope: 'shared', locktype: 'write'),
        ],
      );
      final xml = supportedlock.toXml();

      expect(xml, contains('<D:supportedlock>'));
      expect(xml, contains('<D:lockentry>'));
      expect(xml, contains('<D:exclusive/>'));
      expect(xml, contains('<D:shared/>'));
      expect(xml, contains('</D:supportedlock>'));
    });
  });

  group('ActivelockProperty', () {
    test('should create with required parameters', () {
      const activelock = ActivelockProperty(
        lockscope: 'exclusive',
        locktype: 'write',
        depth: 'infinity',
      );

      expect(activelock.lockscope, equals('exclusive'));
      expect(activelock.locktype, equals('write'));
      expect(activelock.depth, equals('infinity'));
      expect(activelock.owner, isNull);
      expect(activelock.timeout, isNull);
      expect(activelock.locktoken, isNull);
    });

    test('should create with all parameters', () {
      const activelock = ActivelockProperty(
        lockscope: 'exclusive',
        locktype: 'write',
        depth: '0',
        owner: 'user@example.com',
        timeout: 'Second-3600',
        locktoken: 'opaquelocktoken:12345',
      );

      expect(activelock.lockscope, equals('exclusive'));
      expect(activelock.locktype, equals('write'));
      expect(activelock.depth, equals('0'));
      expect(activelock.owner, equals('user@example.com'));
      expect(activelock.timeout, equals('Second-3600'));
      expect(activelock.locktoken, equals('opaquelocktoken:12345'));
    });

    test('should generate correct XML with minimal parameters', () {
      const activelock = ActivelockProperty(
        lockscope: 'exclusive',
        locktype: 'write',
        depth: 'infinity',
      );
      final xml = activelock.toXml();

      expect(xml, contains('<D:activelock>'));
      expect(xml, contains('<D:lockscope>'));
      expect(xml, contains('<D:exclusive/>'));
      expect(xml, contains('</D:lockscope>'));
      expect(xml, contains('<D:locktype>'));
      expect(xml, contains('<D:write/>'));
      expect(xml, contains('</D:locktype>'));
      expect(xml, contains('<D:depth>infinity</D:depth>'));
      expect(xml, contains('</D:activelock>'));
      expect(xml, isNot(contains('<D:owner>')));
      expect(xml, isNot(contains('<D:timeout>')));
      expect(xml, isNot(contains('<D:locktoken>')));
    });

    test('should generate correct XML with all parameters', () {
      const activelock = ActivelockProperty(
        lockscope: 'exclusive',
        locktype: 'write',
        depth: '0',
        owner: 'user@example.com',
        timeout: 'Second-3600',
        locktoken: 'opaquelocktoken:12345',
      );
      final xml = activelock.toXml();

      expect(xml, contains('<D:activelock>'));
      expect(xml, contains('<D:lockscope>'));
      expect(xml, contains('<D:exclusive/>'));
      expect(xml, contains('</D:lockscope>'));
      expect(xml, contains('<D:locktype>'));
      expect(xml, contains('<D:write/>'));
      expect(xml, contains('</D:locktype>'));
      expect(xml, contains('<D:depth>0</D:depth>'));
      expect(xml, contains('<D:owner>user@example.com</D:owner>'));
      expect(xml, contains('<D:timeout>Second-3600</D:timeout>'));
      expect(xml, contains('<D:locktoken>'));
      expect(xml, contains('<D:href>opaquelocktoken:12345</D:href>'));
      expect(xml, contains('</D:locktoken>'));
      expect(xml, contains('</D:activelock>'));
    });

    test('should handle shared lockscope', () {
      const activelock = ActivelockProperty(
        lockscope: 'shared',
        locktype: 'write',
        depth: 'infinity',
      );
      final xml = activelock.toXml();

      expect(xml, contains('<D:shared/>'));
    });
  });

  group('Lockdiscovery', () {
    test('should create with empty activelocks', () {
      const lockdiscovery = Lockdiscovery();

      expect(lockdiscovery.activelocks, isEmpty);
    });

    test('should create with activelocks', () {
      const activelocks = [
        ActivelockProperty(
          lockscope: 'exclusive',
          locktype: 'write',
          depth: 'infinity',
        ),
        ActivelockProperty(lockscope: 'shared', locktype: 'write', depth: '0'),
      ];
      const lockdiscovery = Lockdiscovery(activelocks: activelocks);

      expect(lockdiscovery.activelocks, equals(activelocks));
    });

    test('should generate correct XML for empty lockdiscovery', () {
      const lockdiscovery = Lockdiscovery();
      final xml = lockdiscovery.toXml();

      expect(xml, contains('<D:lockdiscovery>'));
      expect(xml, contains('</D:lockdiscovery>'));
    });

    test('should generate correct XML with activelocks', () {
      const lockdiscovery = Lockdiscovery(
        activelocks: [
          ActivelockProperty(
            lockscope: 'exclusive',
            locktype: 'write',
            depth: 'infinity',
          ),
          ActivelockProperty(
            lockscope: 'shared',
            locktype: 'write',
            depth: '0',
          ),
        ],
      );
      final xml = lockdiscovery.toXml();

      expect(xml, contains('<D:lockdiscovery>'));
      expect(xml, contains('<D:activelock>'));
      expect(xml, contains('<D:exclusive/>'));
      expect(xml, contains('<D:shared/>'));
      expect(xml, contains('<D:depth>infinity</D:depth>'));
      expect(xml, contains('<D:depth>0</D:depth>'));
      expect(xml, contains('</D:lockdiscovery>'));
    });
  });
}
