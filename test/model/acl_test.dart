import 'package:test/test.dart';
import 'package:webdav_plus/src/model/acl.dart';

void main() {
  group('Acl', () {
    group('XML Generation', () {
      test('should generate empty ACL XML', () {
        final acl = Acl(aces: []);
        final xml = acl.toXml();

        expect(xml, contains('<D:acl xmlns:D="DAV:">'));
        expect(xml, contains('</D:acl>'));
        expect(xml, isNot(contains('<D:ace>')));
      });

      test('should generate ACL with single ACE', () {
        final ace = Ace(
          principal: Principal(href: 'https://example.com/users/john'),
          grant: Grant(privileges: [Privilege(name: 'read')]),
        );
        final acl = Acl(aces: [ace]);
        final xml = acl.toXml();

        expect(xml, contains('<D:acl xmlns:D="DAV:">'));
        expect(xml, contains('<D:ace>'));
        expect(xml, contains('<D:principal>'));
        expect(
          xml,
          contains('<D:href>https://example.com/users/john</D:href>'),
        );
        expect(xml, contains('<D:grant>'));
        expect(xml, contains('</D:ace>'));
        expect(xml, contains('</D:acl>'));
      });

      test('should generate ACL with multiple ACEs', () {
        final aces = [
          Ace(
            principal: Principal(href: 'https://example.com/users/john'),
            grant: Grant(privileges: [Privilege(name: 'read')]),
          ),
          Ace(
            principal: Principal(href: 'https://example.com/users/jane'),
            grant: Grant(privileges: [Privilege(name: 'write')]),
          ),
        ];
        final acl = Acl(aces: aces);
        final xml = acl.toXml();

        expect(xml.split('<D:ace>').length - 1, equals(2));
        expect(xml, contains('https://example.com/users/john'));
        expect(xml, contains('https://example.com/users/jane'));
      });
    });

    group('Construction', () {
      test('should create with empty ACEs list', () {
        final acl = Acl(aces: []);
        expect(acl.aces, isEmpty);
      });

      test('should create with ACEs list', () {
        final aces = [
          Ace(
            principal: Principal(href: 'test'),
            grant: Grant(privileges: []),
          ),
        ];
        final acl = Acl(aces: aces);
        expect(acl.aces, equals(aces));
      });
    });
  });

  group('Ace', () {
    group('XML Generation', () {
      test('should generate grant ACE XML', () {
        final ace = Ace(
          principal: Principal(href: 'https://example.com/users/test'),
          grant: Grant(
            privileges: [
              Privilege(name: 'read'),
              Privilege(name: 'write'),
            ],
          ),
        );
        final xml = ace.toXml();

        expect(xml, contains('<D:ace>'));
        expect(xml, contains('<D:principal>'));
        expect(
          xml,
          contains('<D:href>https://example.com/users/test</D:href>'),
        );
        expect(xml, contains('<D:grant>'));
        expect(xml, contains('<D:privilege>'));
        expect(xml, contains('<D:read/>'));
        expect(xml, contains('<D:write/>'));
        expect(xml, contains('</D:ace>'));
      });

      test('should generate deny ACE XML', () {
        final ace = Ace(
          principal: Principal(href: 'https://example.com/users/test'),
          deny: Deny(privileges: [Privilege(name: 'write')]),
        );
        final xml = ace.toXml();

        expect(xml, contains('<D:deny>'));
        expect(xml, contains('<D:privilege>'));
        expect(xml, contains('<D:write/>'));
        expect(xml, isNot(contains('<D:grant>')));
      });

      test('should include protected when specified', () {
        final ace = Ace(
          principal: Principal(href: 'test'),
          grant: Grant(privileges: []),
          isProtected: true,
        );
        final xml = ace.toXml();

        expect(xml, contains('<D:protected/>'));
      });

      test('should include inherited when specified', () {
        final ace = Ace(
          principal: Principal(href: 'test'),
          grant: Grant(privileges: []),
          inherited: 'https://example.com/parent',
        );
        final xml = ace.toXml();

        expect(xml, contains('<D:inherited>'));
        expect(xml, contains('<D:href>https://example.com/parent</D:href>'));
        expect(xml, contains('</D:inherited>'));
      });

      test('should generate complete ACE with all elements', () {
        final ace = Ace(
          principal: Principal(href: 'https://example.com/users/admin'),
          grant: Grant(
            privileges: [
              Privilege(name: 'read'),
              Privilege(name: 'write'),
              Privilege(name: 'bind'),
            ],
          ),
          isProtected: true,
          inherited: 'https://example.com/root',
        );
        final xml = ace.toXml();

        expect(
          xml,
          contains('<D:href>https://example.com/users/admin</D:href>'),
        );
        expect(xml, contains('<D:read/>'));
        expect(xml, contains('<D:write/>'));
        expect(xml, contains('<D:bind/>'));
        expect(xml, contains('<D:protected/>'));
        expect(xml, contains('<D:inherited>'));
        expect(xml, contains('<D:href>https://example.com/root</D:href>'));
      });
    });

    group('Construction', () {
      test('should create with grant', () {
        final principal = Principal(href: 'test');
        final grant = Grant(privileges: []);
        final ace = Ace(principal: principal, grant: grant);

        expect(ace.principal, equals(principal));
        expect(ace.grant, equals(grant));
        expect(ace.deny, isNull);
        expect(ace.isProtected, isFalse);
        expect(ace.inherited, isNull);
      });

      test('should create with deny', () {
        final principal = Principal(href: 'test');
        final deny = Deny(privileges: []);
        final ace = Ace(principal: principal, deny: deny);

        expect(ace.principal, equals(principal));
        expect(ace.grant, isNull);
        expect(ace.deny, equals(deny));
      });

      test('should create with all parameters', () {
        final principal = Principal(href: 'test');
        final grant = Grant(privileges: []);
        final ace = Ace(
          principal: principal,
          grant: grant,
          isProtected: true,
          inherited: 'test-inherited',
        );

        expect(ace.principal, equals(principal));
        expect(ace.grant, equals(grant));
        expect(ace.isProtected, isTrue);
        expect(ace.inherited, equals('test-inherited'));
      });
    });
  });

  group('Principal', () {
    group('XML Generation', () {
      test('should generate href principal XML', () {
        final principal = Principal(href: 'https://example.com/users/john');
        final xml = principal.toXml();

        expect(xml, contains('<D:principal>'));
        expect(
          xml,
          contains('<D:href>https://example.com/users/john</D:href>'),
        );
        expect(xml, contains('</D:principal>'));
      });

      test('should generate all principal XML', () {
        final principal = Principal(isAll: true);
        final xml = principal.toXml();

        expect(xml, contains('<D:all/>'));
        expect(xml, isNot(contains('<D:href>')));
      });

      test('should generate authenticated principal XML', () {
        final principal = Principal(isAuthenticated: true);
        final xml = principal.toXml();

        expect(xml, contains('<D:authenticated/>'));
      });

      test('should generate unauthenticated principal XML', () {
        final principal = Principal(isUnauthenticated: true);
        final xml = principal.toXml();

        expect(xml, contains('<D:unauthenticated/>'));
      });

      test('should generate self principal XML', () {
        final principal = Principal(isSelf: true);
        final xml = principal.toXml();

        expect(xml, contains('<D:self/>'));
      });

      test('should generate property principal XML', () {
        final principal = Principal(property: 'owner');
        final xml = principal.toXml();

        expect(xml, contains('<D:property>'));
        expect(xml, contains('<owner/>'));
        expect(xml, contains('</D:property>'));
      });
    });

    group('Construction', () {
      test('should create href principal', () {
        final principal = Principal(href: 'test-href');
        expect(principal.href, equals('test-href'));
        expect(principal.isAll, isFalse);
        expect(principal.isAuthenticated, isFalse);
        expect(principal.isUnauthenticated, isFalse);
        expect(principal.isSelf, isFalse);
        expect(principal.property, isNull);
      });

      test('should create special principals', () {
        expect(Principal(isAll: true).isAll, isTrue);
        expect(Principal(isAuthenticated: true).isAuthenticated, isTrue);
        expect(Principal(isUnauthenticated: true).isUnauthenticated, isTrue);
        expect(Principal(isSelf: true).isSelf, isTrue);
      });

      test('should create property principal', () {
        final principal = Principal(property: 'test-property');
        expect(principal.property, equals('test-property'));
      });
    });
  });

  group('Grant', () {
    group('XML Generation', () {
      test('should generate grant XML with single privilege', () {
        final grant = Grant(privileges: [Privilege(name: 'read')]);
        final xml = grant.toXml();

        expect(xml, contains('<D:grant>'));
        expect(xml, contains('<D:privilege>'));
        expect(xml, contains('<D:read/>'));
        expect(xml, contains('</D:grant>'));
      });

      test('should generate grant XML with multiple privileges', () {
        final grant = Grant(
          privileges: [
            Privilege(name: 'read'),
            Privilege(name: 'write'),
            Privilege(name: 'bind'),
          ],
        );
        final xml = grant.toXml();

        expect(xml, contains('<D:read/>'));
        expect(xml, contains('<D:write/>'));
        expect(xml, contains('<D:bind/>'));
      });

      test('should generate empty grant XML', () {
        final grant = Grant(privileges: []);
        final xml = grant.toXml();

        expect(xml, contains('<D:grant>'));
        expect(xml, contains('</D:grant>'));
        expect(xml, isNot(contains('<D:privilege>')));
      });
    });

    group('Construction', () {
      test('should create with privileges', () {
        final privileges = [Privilege(name: 'read'), Privilege(name: 'write')];
        final grant = Grant(privileges: privileges);
        expect(grant.privileges, equals(privileges));
      });

      test('should create with empty privileges', () {
        final grant = Grant(privileges: []);
        expect(grant.privileges, isEmpty);
      });
    });
  });

  group('Deny', () {
    group('XML Generation', () {
      test('should generate deny XML with privileges', () {
        final deny = Deny(
          privileges: [
            Privilege(name: 'write'),
            Privilege(name: 'unbind'),
          ],
        );
        final xml = deny.toXml();

        expect(xml, contains('<D:deny>'));
        expect(xml, contains('<D:write/>'));
        expect(xml, contains('<D:unbind/>'));
        expect(xml, contains('</D:deny>'));
      });
    });

    group('Construction', () {
      test('should create with privileges', () {
        final privileges = [Privilege(name: 'test')];
        final deny = Deny(privileges: privileges);
        expect(deny.privileges, equals(privileges));
      });
    });
  });

  group('Privilege', () {
    group('XML Generation', () {
      test('should generate standard privilege XML', () {
        final privilege = Privilege(name: 'read');
        final xml = privilege.toXml();

        expect(xml, contains('<D:privilege>'));
        expect(xml, contains('<D:read/>'));
        expect(xml, contains('</D:privilege>'));
      });

      test('should generate various privilege types', () {
        final privilegeTypes = ['read', 'write', 'bind', 'unbind', 'all'];

        for (final type in privilegeTypes) {
          final privilege = Privilege(name: type);
          final xml = privilege.toXml();
          expect(xml, contains('<D:$type/>'));
        }
      });

      test('should handle custom privilege types', () {
        final privilege = Privilege(name: 'custom-privilege');
        final xml = privilege.toXml();

        expect(xml, contains('<D:custom-privilege/>'));
      });

      test('should use predefined privilege constants', () {
        expect(Privilege.read.name, equals('read'));
        expect(Privilege.write.name, equals('write'));
        expect(Privilege.bind.name, equals('bind'));
        expect(Privilege.unbind.name, equals('unbind'));
        expect(Privilege.all.name, equals('all'));
      });
    });

    group('Construction', () {
      test('should create with privilege name', () {
        final privilege = Privilege(name: 'test');
        expect(privilege.name, equals('test'));
      });
    });
  });
}
