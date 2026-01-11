import 'package:test/test.dart';
import 'package:webdav_plus/src/model/lockinfo.dart';

void main() {
  group('Lockinfo', () {
    group('XML Generation', () {
      test('should generate basic exclusive lock XML', () {
        final lockinfo = Lockinfo(
          lockscope: Lockscope(exclusive: true),
          locktype: Locktype(),
        );
        final xml = lockinfo.toXml();

        expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));
        expect(xml, contains('<D:lockinfo xmlns:D="DAV:">'));
        expect(xml, contains('<D:lockscope><D:exclusive/></D:lockscope>'));
        expect(xml, contains('<D:locktype><D:write/></D:locktype>'));
        expect(xml, contains('</D:lockinfo>'));
      });

      test('should generate shared lock XML', () {
        final lockinfo = Lockinfo(
          lockscope: Lockscope(exclusive: false),
          locktype: Locktype(),
        );
        final xml = lockinfo.toXml();

        expect(xml, contains('<D:lockscope><D:shared/></D:lockscope>'));
        expect(xml, contains('<D:locktype><D:write/></D:locktype>'));
      });

      test('should include owner when provided', () {
        final lockinfo = Lockinfo(
          lockscope: Lockscope(exclusive: true),
          locktype: Locktype(),
          owner: Owner(owner: 'user123'),
        );
        final xml = lockinfo.toXml();

        expect(xml, contains('<D:lockscope><D:exclusive/></D:lockscope>'));
        expect(xml, contains('<D:locktype><D:write/></D:locktype>'));
        expect(xml, contains('<D:owner>user123</D:owner>'));
      });

      test('should handle empty owner string', () {
        final lockinfo = Lockinfo(
          lockscope: Lockscope(exclusive: true),
          locktype: Locktype(),
          owner: Owner(owner: ''),
        );
        final xml = lockinfo.toXml();

        expect(xml, contains('<D:owner></D:owner>'));
      });

      test('should handle special characters in owner', () {
        final lockinfo = Lockinfo(
          lockscope: Lockscope(exclusive: true),
          locktype: Locktype(),
          owner: Owner(owner: 'user@domain.com <Test User>'),
        );
        final xml = lockinfo.toXml();

        expect(xml, contains('<D:owner>user@domain.com <Test User></D:owner>'));
      });

      test('should generate minimal lock XML without owner', () {
        final lockinfo = Lockinfo(
          lockscope: Lockscope(exclusive: true),
          locktype: Locktype(),
        );
        final xml = lockinfo.toXml();

        expect(xml, isNot(contains('<D:owner>')));
        expect(xml, contains('<D:lockscope><D:exclusive/></D:lockscope>'));
        expect(xml, contains('<D:locktype><D:write/></D:locktype>'));
      });
    });

    group('Construction', () {
      test('should create with minimal parameters', () {
        final lockscope = Lockscope(exclusive: true);
        final locktype = Locktype();
        final lockinfo = Lockinfo(lockscope: lockscope, locktype: locktype);

        expect(lockinfo.lockscope, equals(lockscope));
        expect(lockinfo.locktype, equals(locktype));
        expect(lockinfo.owner, isNull);
      });

      test('should create with all parameters', () {
        final lockscope = Lockscope(exclusive: false);
        final locktype = Locktype();
        final owner = Owner(owner: 'test-owner');
        final lockinfo = Lockinfo(
          lockscope: lockscope,
          locktype: locktype,
          owner: owner,
        );

        expect(lockinfo.lockscope, equals(lockscope));
        expect(lockinfo.locktype, equals(locktype));
        expect(lockinfo.owner, equals(owner));
      });
    });
  });

  group('Lockscope', () {
    group('XML Generation', () {
      test('should generate exclusive lockscope XML', () {
        final lockscope = Lockscope(exclusive: true);
        final xml = lockscope.toXml();

        expect(xml, equals('<D:lockscope><D:exclusive/></D:lockscope>'));
      });

      test('should generate shared lockscope XML', () {
        final lockscope = Lockscope(exclusive: false);
        final xml = lockscope.toXml();

        expect(xml, equals('<D:lockscope><D:shared/></D:lockscope>'));
      });
    });

    group('Construction', () {
      test('should create exclusive lockscope', () {
        final lockscope = Lockscope(exclusive: true);
        expect(lockscope.exclusive, isTrue);
      });

      test('should create shared lockscope', () {
        final lockscope = Lockscope(exclusive: false);
        expect(lockscope.exclusive, isFalse);
      });
    });
  });

  group('Locktype', () {
    group('XML Generation', () {
      test('should generate write locktype XML', () {
        final locktype = Locktype();
        final xml = locktype.toXml();

        expect(xml, equals('<D:locktype><D:write/></D:locktype>'));
      });
    });

    group('Construction', () {
      test('should create locktype instance', () {
        final locktype = Locktype();
        expect(locktype, isNotNull);
      });
    });
  });

  group('Owner', () {
    group('XML Generation', () {
      test('should generate owner XML with text content', () {
        final owner = Owner(owner: 'john.doe@example.com');
        final xml = owner.toXml();

        expect(xml, equals('<D:owner>john.doe@example.com</D:owner>'));
      });

      test('should handle empty owner', () {
        final owner = Owner(owner: '');
        final xml = owner.toXml();

        expect(xml, equals('<D:owner></D:owner>'));
      });

      test('should handle owner with special characters', () {
        final owner = Owner(owner: '<user>test & "quoted"</user>');
        final xml = owner.toXml();

        expect(xml, equals('<D:owner><user>test & "quoted"</user></D:owner>'));
      });

      test('should handle owner with whitespace', () {
        final owner = Owner(owner: '  user with spaces  ');
        final xml = owner.toXml();

        expect(xml, equals('<D:owner>  user with spaces  </D:owner>'));
      });
    });

    group('Construction', () {
      test('should create owner with string', () {
        final owner = Owner(owner: 'test-user');
        expect(owner.owner, equals('test-user'));
      });

      test('should create owner with empty string', () {
        final owner = Owner(owner: '');
        expect(owner.owner, equals(''));
      });
    });
  });
}
