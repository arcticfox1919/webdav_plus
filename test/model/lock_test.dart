import 'package:test/test.dart';
import 'package:webdav_plus/src/model/lock.dart';

void main() {
  group('Activelock', () {
    group('XML Generation', () {
      test('should generate basic activelock XML', () {
        final activelock = Activelock(
          lockscope: 'exclusive',
          locktype: 'write',
          depth: '0',
        );
        final xml = activelock.toXml();

        expect(xml, contains('<D:activelock>'));
        expect(xml, contains('<D:lockscope>'));
        expect(xml, contains('<D:exclusive/>'));
        expect(xml, contains('<D:locktype>'));
        expect(xml, contains('<D:write/>'));
        expect(xml, contains('<D:depth>0</D:depth>'));
        expect(xml, contains('</D:activelock>'));
      });

      test('should generate activelock XML with all optional fields', () {
        final activelock = Activelock(
          lockscope: 'shared',
          locktype: 'write',
          depth: 'infinity',
          owner: 'john.doe@example.com',
          timeout: 'Second-604800',
          locktoken: 'urn:uuid:12345678-1234-1234-1234-123456789abc',
        );
        final xml = activelock.toXml();

        expect(xml, contains('<D:shared/>'));
        expect(xml, contains('<D:depth>infinity</D:depth>'));
        expect(xml, contains('<D:owner>john.doe@example.com</D:owner>'));
        expect(xml, contains('<D:timeout>Second-604800</D:timeout>'));
        expect(xml, contains('<D:locktoken>'));
        expect(
          xml,
          contains(
            '<D:href>urn:uuid:12345678-1234-1234-1234-123456789abc</D:href>',
          ),
        );
      });

      test('should generate activelock XML without optional fields', () {
        final activelock = Activelock(
          lockscope: 'exclusive',
          locktype: 'write',
          depth: '1',
        );
        final xml = activelock.toXml();

        expect(xml, isNot(contains('<D:owner>')));
        expect(xml, isNot(contains('<D:timeout>')));
        expect(xml, isNot(contains('<D:locktoken>')));
      });

      test('should generate activelock XML with only some optional fields', () {
        final activelock = Activelock(
          lockscope: 'exclusive',
          locktype: 'write',
          depth: '0',
          owner: 'test@example.com',
          timeout: 'Infinite',
        );
        final xml = activelock.toXml();

        expect(xml, contains('<D:owner>test@example.com</D:owner>'));
        expect(xml, contains('<D:timeout>Infinite</D:timeout>'));
        expect(xml, isNot(contains('<D:locktoken>')));
      });
    });

    group('Construction', () {
      test('should create with required parameters', () {
        final activelock = Activelock(
          lockscope: 'exclusive',
          locktype: 'write',
          depth: '0',
        );

        expect(activelock.lockscope, equals('exclusive'));
        expect(activelock.locktype, equals('write'));
        expect(activelock.depth, equals('0'));
        expect(activelock.owner, isNull);
        expect(activelock.timeout, isNull);
        expect(activelock.locktoken, isNull);
      });

      test('should create with all parameters', () {
        final activelock = Activelock(
          lockscope: 'shared',
          locktype: 'write',
          depth: 'infinity',
          owner: 'user@example.com',
          timeout: 'Second-3600',
          locktoken: 'test-token',
        );

        expect(activelock.lockscope, equals('shared'));
        expect(activelock.locktype, equals('write'));
        expect(activelock.depth, equals('infinity'));
        expect(activelock.owner, equals('user@example.com'));
        expect(activelock.timeout, equals('Second-3600'));
        expect(activelock.locktoken, equals('test-token'));
      });
    });

    group('Edge Cases', () {
      test('should handle different lockscopes', () {
        final exclusive = Activelock(
          lockscope: 'exclusive',
          locktype: 'write',
          depth: '0',
        );
        final shared = Activelock(
          lockscope: 'shared',
          locktype: 'write',
          depth: '0',
        );

        expect(exclusive.toXml(), contains('<D:exclusive/>'));
        expect(shared.toXml(), contains('<D:shared/>'));
      });

      test('should handle different depth values', () {
        final depths = ['0', '1', 'infinity'];

        for (final depth in depths) {
          final activelock = Activelock(
            lockscope: 'exclusive',
            locktype: 'write',
            depth: depth,
          );
          final xml = activelock.toXml();
          expect(xml, contains('<D:depth>$depth</D:depth>'));
        }
      });

      test('should handle complex owner values', () {
        final activelock = Activelock(
          lockscope: 'exclusive',
          locktype: 'write',
          depth: '0',
          owner: 'User Name <user@example.com>',
        );
        final xml = activelock.toXml();

        expect(
          xml,
          contains('<D:owner>User Name <user@example.com></D:owner>'),
        );
      });

      test('should handle various timeout formats', () {
        final timeouts = ['Infinite', 'Second-3600', 'Second-604800'];

        for (final timeout in timeouts) {
          final activelock = Activelock(
            lockscope: 'exclusive',
            locktype: 'write',
            depth: '0',
            timeout: timeout,
          );
          final xml = activelock.toXml();
          expect(xml, contains('<D:timeout>$timeout</D:timeout>'));
        }
      });
    });
  });

  group('Lockdiscovery', () {
    group('XML Generation', () {
      test('should generate empty lockdiscovery XML', () {
        final lockdiscovery = Lockdiscovery();
        final xml = lockdiscovery.toXml();

        expect(xml, contains('<D:lockdiscovery>'));
        expect(xml, contains('</D:lockdiscovery>'));
        expect(xml, isNot(contains('<D:activelock>')));
      });

      test('should generate lockdiscovery XML with single activelock', () {
        final activelocks = [
          Activelock(lockscope: 'exclusive', locktype: 'write', depth: '0'),
        ];
        final lockdiscovery = Lockdiscovery(activelocks: activelocks);
        final xml = lockdiscovery.toXml();

        expect(xml, contains('<D:lockdiscovery>'));
        expect(xml, contains('<D:activelock>'));
        expect(xml, contains('<D:exclusive/>'));
        expect(xml, contains('</D:lockdiscovery>'));
      });

      test('should generate lockdiscovery XML with multiple activelocks', () {
        final activelocks = [
          Activelock(lockscope: 'exclusive', locktype: 'write', depth: '0'),
          Activelock(lockscope: 'shared', locktype: 'write', depth: '1'),
        ];
        final lockdiscovery = Lockdiscovery(activelocks: activelocks);
        final xml = lockdiscovery.toXml();

        expect(xml.split('<D:activelock>').length - 1, equals(2));
        expect(xml, contains('<D:exclusive/>'));
        expect(xml, contains('<D:shared/>'));
      });
    });

    group('Construction', () {
      test('should create with empty activelocks', () {
        final lockdiscovery = Lockdiscovery();
        expect(lockdiscovery.activelocks, isEmpty);
      });

      test('should create with activelocks list', () {
        final activelocks = [
          Activelock(lockscope: 'exclusive', locktype: 'write', depth: '0'),
        ];
        final lockdiscovery = Lockdiscovery(activelocks: activelocks);
        expect(lockdiscovery.activelocks, equals(activelocks));
      });
    });
  });

  group('Lockentry', () {
    group('XML Generation', () {
      test('should generate exclusive write lockentry XML', () {
        final lockentry = Lockentry(lockscope: 'exclusive', locktype: 'write');
        final xml = lockentry.toXml();

        expect(xml, contains('<D:lockentry>'));
        expect(xml, contains('<D:lockscope>'));
        expect(xml, contains('<D:exclusive/>'));
        expect(xml, contains('<D:locktype>'));
        expect(xml, contains('<D:write/>'));
        expect(xml, contains('</D:lockentry>'));
      });

      test('should generate shared write lockentry XML', () {
        final lockentry = Lockentry(lockscope: 'shared', locktype: 'write');
        final xml = lockentry.toXml();

        expect(xml, contains('<D:shared/>'));
        expect(xml, contains('<D:write/>'));
      });

      test('should generate different locktype combinations', () {
        final combinations = [
          ['exclusive', 'write'],
          ['shared', 'write'],
          ['exclusive', 'read'],
          ['shared', 'read'],
        ];

        for (final combo in combinations) {
          final lockentry = Lockentry(lockscope: combo[0], locktype: combo[1]);
          final xml = lockentry.toXml();
          expect(xml, contains('<D:${combo[0]}/>'));
          expect(xml, contains('<D:${combo[1]}/>'));
        }
      });
    });

    group('Construction', () {
      test('should create with lockscope and locktype', () {
        final lockentry = Lockentry(lockscope: 'exclusive', locktype: 'write');
        expect(lockentry.lockscope, equals('exclusive'));
        expect(lockentry.locktype, equals('write'));
      });

      test('should create with different combinations', () {
        final lockentry = Lockentry(lockscope: 'shared', locktype: 'read');
        expect(lockentry.lockscope, equals('shared'));
        expect(lockentry.locktype, equals('read'));
      });
    });
  });

  group('Supportedlock', () {
    group('XML Generation', () {
      test('should generate empty supportedlock XML', () {
        final supportedlock = Supportedlock();
        final xml = supportedlock.toXml();

        expect(xml, contains('<D:supportedlock>'));
        expect(xml, contains('</D:supportedlock>'));
        expect(xml, isNot(contains('<D:lockentry>')));
      });

      test('should generate supportedlock XML with single lockentry', () {
        final lockentries = [
          Lockentry(lockscope: 'exclusive', locktype: 'write'),
        ];
        final supportedlock = Supportedlock(lockentries: lockentries);
        final xml = supportedlock.toXml();

        expect(xml, contains('<D:supportedlock>'));
        expect(xml, contains('<D:lockentry>'));
        expect(xml, contains('<D:exclusive/>'));
        expect(xml, contains('<D:write/>'));
        expect(xml, contains('</D:supportedlock>'));
      });

      test('should generate supportedlock XML with multiple lockentries', () {
        final lockentries = [
          Lockentry(lockscope: 'exclusive', locktype: 'write'),
          Lockentry(lockscope: 'shared', locktype: 'write'),
        ];
        final supportedlock = Supportedlock(lockentries: lockentries);
        final xml = supportedlock.toXml();

        expect(xml.split('<D:lockentry>').length - 1, equals(2));
        expect(xml, contains('<D:exclusive/>'));
        expect(xml, contains('<D:shared/>'));
      });

      test(
        'should generate supportedlock XML with comprehensive lock support',
        () {
          final lockentries = [
            Lockentry(lockscope: 'exclusive', locktype: 'write'),
            Lockentry(lockscope: 'shared', locktype: 'write'),
            Lockentry(lockscope: 'exclusive', locktype: 'read'),
            Lockentry(lockscope: 'shared', locktype: 'read'),
          ];
          final supportedlock = Supportedlock(lockentries: lockentries);
          final xml = supportedlock.toXml();

          expect(xml.split('<D:lockentry>').length - 1, equals(4));
        },
      );
    });

    group('Construction', () {
      test('should create with empty lockentries', () {
        final supportedlock = Supportedlock();
        expect(supportedlock.lockentries, isEmpty);
      });

      test('should create with lockentries list', () {
        final lockentries = [
          Lockentry(lockscope: 'exclusive', locktype: 'write'),
        ];
        final supportedlock = Supportedlock(lockentries: lockentries);
        expect(supportedlock.lockentries, equals(lockentries));
      });
    });
  });

  group('Lock Integration', () {
    group('Complete Lock Workflow', () {
      test('should demonstrate lock discovery response', () {
        final lockdiscovery = Lockdiscovery(
          activelocks: [
            Activelock(
              lockscope: 'exclusive',
              locktype: 'write',
              depth: '0',
              owner: 'john.doe@example.com',
              timeout: 'Second-3600',
              locktoken: 'urn:uuid:12345678-1234-1234-1234-123456789abc',
            ),
          ],
        );
        final xml = lockdiscovery.toXml();

        expect(xml, contains('<D:lockdiscovery>'));
        expect(xml, contains('<D:activelock>'));
        expect(xml, contains('<D:owner>john.doe@example.com</D:owner>'));
        expect(xml, contains('<D:locktoken>'));
      });

      test('should demonstrate supported lock capabilities', () {
        final supportedlock = Supportedlock(
          lockentries: [
            Lockentry(lockscope: 'exclusive', locktype: 'write'),
            Lockentry(lockscope: 'shared', locktype: 'write'),
          ],
        );
        final xml = supportedlock.toXml();

        expect(xml, contains('<D:supportedlock>'));
        expect(xml.split('<D:lockentry>').length - 1, equals(2));
      });

      test('should handle multiple active locks', () {
        final lockdiscovery = Lockdiscovery(
          activelocks: [
            Activelock(
              lockscope: 'shared',
              locktype: 'write',
              depth: '0',
              owner: 'user1@example.com',
              timeout: 'Second-1800',
              locktoken: 'token-1',
            ),
            Activelock(
              lockscope: 'shared',
              locktype: 'write',
              depth: '0',
              owner: 'user2@example.com',
              timeout: 'Second-1800',
              locktoken: 'token-2',
            ),
          ],
        );
        final xml = lockdiscovery.toXml();

        expect(xml.split('<D:activelock>').length - 1, equals(2));
        expect(xml, contains('user1@example.com'));
        expect(xml, contains('user2@example.com'));
      });
    });

    group('Lock Token Handling', () {
      test('should handle various token formats', () {
        final tokenFormats = [
          'urn:uuid:12345678-1234-1234-1234-123456789abc',
          'opaquelocktoken:f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
          'http://example.com/locks/token123',
          'simple-token-123',
        ];

        for (final token in tokenFormats) {
          final activelock = Activelock(
            lockscope: 'exclusive',
            locktype: 'write',
            depth: '0',
            locktoken: token,
          );
          final xml = activelock.toXml();
          expect(xml, contains('<D:href>$token</D:href>'));
        }
      });
    });

    group('Timeout Handling', () {
      test('should handle different timeout formats', () {
        final timeoutFormats = [
          'Infinite',
          'Second-3600',
          'Second-604800', // 1 week
          'Second-2592000', // 30 days
        ];

        for (final timeout in timeoutFormats) {
          final activelock = Activelock(
            lockscope: 'exclusive',
            locktype: 'write',
            depth: '0',
            timeout: timeout,
          );
          final xml = activelock.toXml();
          expect(xml, contains('<D:timeout>$timeout</D:timeout>'));
        }
      });
    });
  });
}
