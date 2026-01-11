import 'package:test/test.dart';
import 'package:webdav_plus/src/model/privileges.dart';

void main() {
  group('ReadPrivilege', () {
    group('XML Generation', () {
      test('should generate read privilege XML', () {
        const read = ReadPrivilege();
        final xml = read.toXml();

        expect(xml, equals('<D:read/>'));
      });
    });

    group('Construction', () {
      test('should create read privilege', () {
        const read = ReadPrivilege();
        expect(read, isA<ReadPrivilege>());
      });
    });
  });

  group('WritePrivilege', () {
    group('XML Generation', () {
      test('should generate write privilege XML', () {
        const write = WritePrivilege();
        final xml = write.toXml();

        expect(xml, equals('<D:write/>'));
      });
    });

    group('Construction', () {
      test('should create write privilege', () {
        const write = WritePrivilege();
        expect(write, isA<WritePrivilege>());
      });
    });
  });

  group('WritePropertiesPrivilege', () {
    group('XML Generation', () {
      test('should generate write-properties privilege XML', () {
        const writeProperties = WritePropertiesPrivilege();
        final xml = writeProperties.toXml();

        expect(xml, equals('<D:write-properties/>'));
      });
    });

    group('Construction', () {
      test('should create write-properties privilege', () {
        const writeProperties = WritePropertiesPrivilege();
        expect(writeProperties, isA<WritePropertiesPrivilege>());
      });
    });
  });

  group('WriteContentPrivilege', () {
    group('XML Generation', () {
      test('should generate write-content privilege XML', () {
        const writeContent = WriteContentPrivilege();
        final xml = writeContent.toXml();

        expect(xml, equals('<D:write-content/>'));
      });
    });

    group('Construction', () {
      test('should create write-content privilege', () {
        const writeContent = WriteContentPrivilege();
        expect(writeContent, isA<WriteContentPrivilege>());
      });
    });
  });

  group('UnlockPrivilege', () {
    group('XML Generation', () {
      test('should generate unlock privilege XML', () {
        const unlock = UnlockPrivilege();
        final xml = unlock.toXml();

        expect(xml, equals('<D:unlock/>'));
      });
    });

    group('Construction', () {
      test('should create unlock privilege', () {
        const unlock = UnlockPrivilege();
        expect(unlock, isA<UnlockPrivilege>());
      });
    });
  });

  group('ReadAclPrivilege', () {
    group('XML Generation', () {
      test('should generate read-acl privilege XML', () {
        const readAcl = ReadAclPrivilege();
        final xml = readAcl.toXml();

        expect(xml, equals('<D:read-acl/>'));
      });
    });

    group('Construction', () {
      test('should create read-acl privilege', () {
        const readAcl = ReadAclPrivilege();
        expect(readAcl, isA<ReadAclPrivilege>());
      });
    });
  });

  group('ReadCurrentUserPrivilegeSetPrivilege', () {
    group('XML Generation', () {
      test('should generate read-current-user-privilege-set privilege XML', () {
        const readCurrentUserPrivilegeSet =
            ReadCurrentUserPrivilegeSetPrivilege();
        final xml = readCurrentUserPrivilegeSet.toXml();

        expect(xml, equals('<D:read-current-user-privilege-set/>'));
      });
    });

    group('Construction', () {
      test('should create read-current-user-privilege-set privilege', () {
        const readCurrentUserPrivilegeSet =
            ReadCurrentUserPrivilegeSetPrivilege();
        expect(
          readCurrentUserPrivilegeSet,
          isA<ReadCurrentUserPrivilegeSetPrivilege>(),
        );
      });
    });
  });

  group('WriteAclPrivilege', () {
    group('XML Generation', () {
      test('should generate write-acl privilege XML', () {
        const writeAcl = WriteAclPrivilege();
        final xml = writeAcl.toXml();

        expect(xml, equals('<D:write-acl/>'));
      });
    });

    group('Construction', () {
      test('should create write-acl privilege', () {
        const writeAcl = WriteAclPrivilege();
        expect(writeAcl, isA<WriteAclPrivilege>());
      });
    });
  });

  group('BindPrivilege', () {
    group('XML Generation', () {
      test('should generate bind privilege XML', () {
        const bind = BindPrivilege();
        final xml = bind.toXml();

        expect(xml, equals('<D:bind/>'));
      });
    });

    group('Construction', () {
      test('should create bind privilege', () {
        const bind = BindPrivilege();
        expect(bind, isA<BindPrivilege>());
      });
    });
  });

  group('UnbindPrivilege', () {
    group('XML Generation', () {
      test('should generate unbind privilege XML', () {
        const unbind = UnbindPrivilege();
        final xml = unbind.toXml();

        expect(xml, equals('<D:unbind/>'));
      });
    });

    group('Construction', () {
      test('should create unbind privilege', () {
        const unbind = UnbindPrivilege();
        expect(unbind, isA<UnbindPrivilege>());
      });
    });
  });

  group('AllPrivilege', () {
    group('XML Generation', () {
      test('should generate all privilege XML', () {
        const all = AllPrivilege();
        final xml = all.toXml();

        expect(xml, equals('<D:all/>'));
      });
    });

    group('Construction', () {
      test('should create all privilege', () {
        const all = AllPrivilege();
        expect(all, isA<AllPrivilege>());
      });
    });
  });

  group('AuthenticatedPrincipal', () {
    group('XML Generation', () {
      test('should generate authenticated principal XML', () {
        const authenticated = AuthenticatedPrincipal();
        final xml = authenticated.toXml();

        expect(xml, equals('<D:authenticated/>'));
      });
    });

    group('Construction', () {
      test('should create authenticated principal', () {
        const authenticated = AuthenticatedPrincipal();
        expect(authenticated, isA<AuthenticatedPrincipal>());
      });
    });
  });

  group('UnauthenticatedPrincipal', () {
    group('XML Generation', () {
      test('should generate unauthenticated principal XML', () {
        const unauthenticated = UnauthenticatedPrincipal();
        final xml = unauthenticated.toXml();

        expect(xml, equals('<D:unauthenticated/>'));
      });
    });

    group('Construction', () {
      test('should create unauthenticated principal', () {
        const unauthenticated = UnauthenticatedPrincipal();
        expect(unauthenticated, isA<UnauthenticatedPrincipal>());
      });
    });
  });

  group('SelfPrincipal', () {
    group('XML Generation', () {
      test('should generate self principal XML', () {
        const self = SelfPrincipal();
        final xml = self.toXml();

        expect(xml, equals('<D:self/>'));
      });
    });

    group('Construction', () {
      test('should create self principal', () {
        const self = SelfPrincipal();
        expect(self, isA<SelfPrincipal>());
      });
    });
  });

  group('ProtectedAce', () {
    group('XML Generation', () {
      test('should generate protected ACE XML', () {
        const protected = ProtectedAce();
        final xml = protected.toXml();

        expect(xml, equals('<D:protected/>'));
      });
    });

    group('Construction', () {
      test('should create protected ACE', () {
        const protected = ProtectedAce();
        expect(protected, isA<ProtectedAce>());
      });
    });
  });

  group('InheritedAce', () {
    group('XML Generation', () {
      test('should generate inherited ACE XML', () {
        const inherited = InheritedAce(href: 'http://example.com/parent');
        final xml = inherited.toXml();

        expect(
          xml,
          equals(
            '<D:inherited><D:href>http://example.com/parent</D:href></D:inherited>',
          ),
        );
      });

      test('should generate inherited ACE XML with different href', () {
        const inherited = InheritedAce(href: '/parent/resource');
        final xml = inherited.toXml();

        expect(
          xml,
          equals(
            '<D:inherited><D:href>/parent/resource</D:href></D:inherited>',
          ),
        );
      });

      test('should handle empty href', () {
        const inherited = InheritedAce(href: '');
        final xml = inherited.toXml();

        expect(xml, equals('<D:inherited><D:href></D:href></D:inherited>'));
      });

      test('should handle complex href values', () {
        const inherited = InheritedAce(
          href: 'https://example.com/path/to/parent?query=value#fragment',
        );
        final xml = inherited.toXml();

        expect(
          xml,
          contains(
            '<D:href>https://example.com/path/to/parent?query=value#fragment</D:href>',
          ),
        );
      });
    });

    group('Construction', () {
      test('should create inherited ACE with href', () {
        const inherited = InheritedAce(href: 'test-href');
        expect(inherited, isA<InheritedAce>());
        expect(inherited.href, equals('test-href'));
      });
    });
  });

  group('Privilege Constants', () {
    group('Standard WebDAV Privileges', () {
      test('should provide read privilege constant', () {
        const read = ReadPrivilege();
        expect(read.toXml(), equals('<D:read/>'));
      });

      test('should provide write privilege constant', () {
        const write = WritePrivilege();
        expect(write.toXml(), equals('<D:write/>'));
      });

      test('should provide all standard privileges', () {
        const privileges = <dynamic>[
          ReadPrivilege(),
          WritePrivilege(),
          WritePropertiesPrivilege(),
          WriteContentPrivilege(),
          UnlockPrivilege(),
          ReadAclPrivilege(),
          ReadCurrentUserPrivilegeSetPrivilege(),
          WriteAclPrivilege(),
          BindPrivilege(),
          UnbindPrivilege(),
          AllPrivilege(),
        ];

        for (final privilege in privileges) {
          final xml = privilege.toXml();
          expect(xml, startsWith('<D:'));
          expect(xml, endsWith('/>'));
        }
      });
    });

    group('Principal Types', () {
      test('should provide all principal types', () {
        const principals = <dynamic>[
          AuthenticatedPrincipal(),
          UnauthenticatedPrincipal(),
          SelfPrincipal(),
        ];

        for (final principal in principals) {
          final xml = principal.toXml();
          expect(xml, startsWith('<D:'));
          expect(xml, endsWith('/>'));
        }
      });
    });

    group('ACE Attributes', () {
      test('should provide protected attribute', () {
        const protected = ProtectedAce();
        expect(protected.toXml(), equals('<D:protected/>'));
      });

      test('should provide inherited attribute with href', () {
        const inherited = InheritedAce(href: '/parent');
        expect(inherited.toXml(), contains('<D:inherited>'));
        expect(inherited.toXml(), contains('<D:href>/parent</D:href>'));
      });
    });
  });

  group('Privilege Combinations', () {
    group('Common Privilege Sets', () {
      test('should combine read privileges', () {
        const privileges = <dynamic>[
          ReadPrivilege(),
          ReadAclPrivilege(),
          ReadCurrentUserPrivilegeSetPrivilege(),
        ];
        final xmlList = privileges.map((p) => p.toXml()).toList();

        expect(xmlList, contains('<D:read/>'));
        expect(xmlList, contains('<D:read-acl/>'));
        expect(xmlList, contains('<D:read-current-user-privilege-set/>'));
      });

      test('should combine write privileges', () {
        const privileges = <dynamic>[
          WritePrivilege(),
          WritePropertiesPrivilege(),
          WriteContentPrivilege(),
          WriteAclPrivilege(),
        ];
        final xmlList = privileges.map((p) => p.toXml()).toList();

        expect(xmlList, contains('<D:write/>'));
        expect(xmlList, contains('<D:write-properties/>'));
        expect(xmlList, contains('<D:write-content/>'));
        expect(xmlList, contains('<D:write-acl/>'));
      });

      test('should combine binding privileges', () {
        const privileges = <dynamic>[BindPrivilege(), UnbindPrivilege()];
        final xmlList = privileges.map((p) => p.toXml()).toList();

        expect(xmlList, contains('<D:bind/>'));
        expect(xmlList, contains('<D:unbind/>'));
      });

      test('should represent all privileges', () {
        const all = AllPrivilege();
        expect(all.toXml(), equals('<D:all/>'));
      });
    });

    group('Principal Combinations', () {
      test('should represent different principal types', () {
        const principals = <dynamic>[
          AuthenticatedPrincipal(),
          UnauthenticatedPrincipal(),
          SelfPrincipal(),
        ];
        final xmlList = principals.map((p) => p.toXml()).toList();

        expect(xmlList, hasLength(3));
        expect(xmlList, contains('<D:authenticated/>'));
        expect(xmlList, contains('<D:unauthenticated/>'));
        expect(xmlList, contains('<D:self/>'));
      });
    });
  });

  group('XML Format Compliance', () {
    group('Self-Closing Tags', () {
      test('should generate self-closing XML tags for simple privileges', () {
        const simplePrivileges = <dynamic>[
          ReadPrivilege(),
          WritePrivilege(),
          WritePropertiesPrivilege(),
          WriteContentPrivilege(),
          UnlockPrivilege(),
          ReadAclPrivilege(),
          ReadCurrentUserPrivilegeSetPrivilege(),
          WriteAclPrivilege(),
          BindPrivilege(),
          UnbindPrivilege(),
          AllPrivilege(),
        ];

        for (final privilege in simplePrivileges) {
          final xml = privilege.toXml();
          expect(xml, matches(r'^<D:[a-z\-]+/>$'));
        }
      });

      test('should generate self-closing XML tags for principals', () {
        const principals = <dynamic>[
          AuthenticatedPrincipal(),
          UnauthenticatedPrincipal(),
          SelfPrincipal(),
          ProtectedAce(),
        ];

        for (final principal in principals) {
          final xml = principal.toXml();
          expect(xml, matches(r'^<D:[a-z\-]+/>$'));
        }
      });

      test('should generate proper XML structure for inherited', () {
        const inherited = InheritedAce(href: '/test');
        final xml = inherited.toXml();

        expect(
          xml,
          matches(r'^<D:inherited><D:href>.*</D:href></D:inherited>$'),
        );
      });
    });

    group('Namespace Prefix', () {
      test('should use DAV namespace prefix consistently', () {
        const items = <dynamic>[
          ReadPrivilege(),
          WritePrivilege(),
          WritePropertiesPrivilege(),
          WriteContentPrivilege(),
          UnlockPrivilege(),
          ReadAclPrivilege(),
          ReadCurrentUserPrivilegeSetPrivilege(),
          WriteAclPrivilege(),
          BindPrivilege(),
          UnbindPrivilege(),
          AllPrivilege(),
          AuthenticatedPrincipal(),
          UnauthenticatedPrincipal(),
          SelfPrincipal(),
          ProtectedAce(),
        ];

        for (final item in items) {
          final xml = item.toXml();
          expect(xml, startsWith('<D:'));
        }
      });

      test('should use DAV namespace prefix for inherited href', () {
        const inherited = InheritedAce(href: '/test');
        final xml = inherited.toXml();

        expect(xml, contains('<D:inherited>'));
        expect(xml, contains('<D:href>'));
      });
    });
  });
}
