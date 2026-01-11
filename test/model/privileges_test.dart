import 'package:test/test.dart';
import 'package:webdav_plus/src/model/privileges.dart';

void main() {
  group('Read', () {
    group('XML Generation', () {
      test('should generate read privilege XML', () {
        const read = Read();
        final xml = read.toXml();

        expect(xml, equals('<D:read/>'));
      });
    });

    group('Construction', () {
      test('should create read privilege', () {
        const read = Read();
        expect(read, isA<Read>());
      });
    });
  });

  group('Write', () {
    group('XML Generation', () {
      test('should generate write privilege XML', () {
        const write = Write();
        final xml = write.toXml();

        expect(xml, equals('<D:write/>'));
      });
    });

    group('Construction', () {
      test('should create write privilege', () {
        const write = Write();
        expect(write, isA<Write>());
      });
    });
  });

  group('WriteProperties', () {
    group('XML Generation', () {
      test('should generate write-properties privilege XML', () {
        const writeProperties = WriteProperties();
        final xml = writeProperties.toXml();

        expect(xml, equals('<D:write-properties/>'));
      });
    });

    group('Construction', () {
      test('should create write-properties privilege', () {
        const writeProperties = WriteProperties();
        expect(writeProperties, isA<WriteProperties>());
      });
    });
  });

  group('WriteContent', () {
    group('XML Generation', () {
      test('should generate write-content privilege XML', () {
        const writeContent = WriteContent();
        final xml = writeContent.toXml();

        expect(xml, equals('<D:write-content/>'));
      });
    });

    group('Construction', () {
      test('should create write-content privilege', () {
        const writeContent = WriteContent();
        expect(writeContent, isA<WriteContent>());
      });
    });
  });

  group('Unlock', () {
    group('XML Generation', () {
      test('should generate unlock privilege XML', () {
        const unlock = Unlock();
        final xml = unlock.toXml();

        expect(xml, equals('<D:unlock/>'));
      });
    });

    group('Construction', () {
      test('should create unlock privilege', () {
        const unlock = Unlock();
        expect(unlock, isA<Unlock>());
      });
    });
  });

  group('ReadAcl', () {
    group('XML Generation', () {
      test('should generate read-acl privilege XML', () {
        const readAcl = ReadAcl();
        final xml = readAcl.toXml();

        expect(xml, equals('<D:read-acl/>'));
      });
    });

    group('Construction', () {
      test('should create read-acl privilege', () {
        const readAcl = ReadAcl();
        expect(readAcl, isA<ReadAcl>());
      });
    });
  });

  group('ReadCurrentUserPrivilegeSet', () {
    group('XML Generation', () {
      test('should generate read-current-user-privilege-set privilege XML', () {
        const readCurrentUserPrivilegeSet = ReadCurrentUserPrivilegeSet();
        final xml = readCurrentUserPrivilegeSet.toXml();

        expect(xml, equals('<D:read-current-user-privilege-set/>'));
      });
    });

    group('Construction', () {
      test('should create read-current-user-privilege-set privilege', () {
        const readCurrentUserPrivilegeSet = ReadCurrentUserPrivilegeSet();
        expect(readCurrentUserPrivilegeSet, isA<ReadCurrentUserPrivilegeSet>());
      });
    });
  });

  group('WriteAcl', () {
    group('XML Generation', () {
      test('should generate write-acl privilege XML', () {
        const writeAcl = WriteAcl();
        final xml = writeAcl.toXml();

        expect(xml, equals('<D:write-acl/>'));
      });
    });

    group('Construction', () {
      test('should create write-acl privilege', () {
        const writeAcl = WriteAcl();
        expect(writeAcl, isA<WriteAcl>());
      });
    });
  });

  group('Bind', () {
    group('XML Generation', () {
      test('should generate bind privilege XML', () {
        const bind = Bind();
        final xml = bind.toXml();

        expect(xml, equals('<D:bind/>'));
      });
    });

    group('Construction', () {
      test('should create bind privilege', () {
        const bind = Bind();
        expect(bind, isA<Bind>());
      });
    });
  });

  group('UnBind', () {
    group('XML Generation', () {
      test('should generate unbind privilege XML', () {
        const unbind = UnBind();
        final xml = unbind.toXml();

        expect(xml, equals('<D:unbind/>'));
      });
    });

    group('Construction', () {
      test('should create unbind privilege', () {
        const unbind = UnBind();
        expect(unbind, isA<UnBind>());
      });
    });
  });

  group('All', () {
    group('XML Generation', () {
      test('should generate all privilege XML', () {
        const all = All();
        final xml = all.toXml();

        expect(xml, equals('<D:all/>'));
      });
    });

    group('Construction', () {
      test('should create all privilege', () {
        const all = All();
        expect(all, isA<All>());
      });
    });
  });

  group('Authenticated', () {
    group('XML Generation', () {
      test('should generate authenticated principal XML', () {
        const authenticated = Authenticated();
        final xml = authenticated.toXml();

        expect(xml, equals('<D:authenticated/>'));
      });
    });

    group('Construction', () {
      test('should create authenticated principal', () {
        const authenticated = Authenticated();
        expect(authenticated, isA<Authenticated>());
      });
    });
  });

  group('Unauthenticated', () {
    group('XML Generation', () {
      test('should generate unauthenticated principal XML', () {
        const unauthenticated = Unauthenticated();
        final xml = unauthenticated.toXml();

        expect(xml, equals('<D:unauthenticated/>'));
      });
    });

    group('Construction', () {
      test('should create unauthenticated principal', () {
        const unauthenticated = Unauthenticated();
        expect(unauthenticated, isA<Unauthenticated>());
      });
    });
  });

  group('Self', () {
    group('XML Generation', () {
      test('should generate self principal XML', () {
        const self = Self();
        final xml = self.toXml();

        expect(xml, equals('<D:self/>'));
      });
    });

    group('Construction', () {
      test('should create self principal', () {
        const self = Self();
        expect(self, isA<Self>());
      });
    });
  });

  group('Protected', () {
    group('XML Generation', () {
      test('should generate protected ACE XML', () {
        const protected = Protected();
        final xml = protected.toXml();

        expect(xml, equals('<D:protected/>'));
      });
    });

    group('Construction', () {
      test('should create protected ACE', () {
        const protected = Protected();
        expect(protected, isA<Protected>());
      });
    });
  });

  group('Inherited', () {
    group('XML Generation', () {
      test('should generate inherited ACE XML', () {
        const inherited = Inherited(href: 'http://example.com/parent');
        final xml = inherited.toXml();

        expect(
          xml,
          equals(
            '<D:inherited><D:href>http://example.com/parent</D:href></D:inherited>',
          ),
        );
      });

      test('should generate inherited ACE XML with different href', () {
        const inherited = Inherited(href: '/parent/resource');
        final xml = inherited.toXml();

        expect(
          xml,
          equals(
            '<D:inherited><D:href>/parent/resource</D:href></D:inherited>',
          ),
        );
      });

      test('should handle empty href', () {
        const inherited = Inherited(href: '');
        final xml = inherited.toXml();

        expect(xml, equals('<D:inherited><D:href></D:href></D:inherited>'));
      });

      test('should handle complex href values', () {
        const inherited = Inherited(
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
        const inherited = Inherited(href: 'test-href');
        expect(inherited, isA<Inherited>());
        expect(inherited.href, equals('test-href'));
      });
    });
  });

  group('Privilege Constants', () {
    group('Standard WebDAV Privileges', () {
      test('should provide read privilege constant', () {
        const read = Read();
        expect(read.toXml(), equals('<D:read/>'));
      });

      test('should provide write privilege constant', () {
        const write = Write();
        expect(write.toXml(), equals('<D:write/>'));
      });

      test('should provide all standard privileges', () {
        const privileges = <dynamic>[
          Read(),
          Write(),
          WriteProperties(),
          WriteContent(),
          Unlock(),
          ReadAcl(),
          ReadCurrentUserPrivilegeSet(),
          WriteAcl(),
          Bind(),
          UnBind(),
          All(),
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
          Authenticated(),
          Unauthenticated(),
          Self(),
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
        const protected = Protected();
        expect(protected.toXml(), equals('<D:protected/>'));
      });

      test('should provide inherited attribute with href', () {
        const inherited = Inherited(href: '/parent');
        expect(inherited.toXml(), contains('<D:inherited>'));
        expect(inherited.toXml(), contains('<D:href>/parent</D:href>'));
      });
    });
  });

  group('Privilege Combinations', () {
    group('Common Privilege Sets', () {
      test('should combine read privileges', () {
        const privileges = <dynamic>[
          Read(),
          ReadAcl(),
          ReadCurrentUserPrivilegeSet(),
        ];
        final xmlList = privileges.map((p) => p.toXml()).toList();

        expect(xmlList, contains('<D:read/>'));
        expect(xmlList, contains('<D:read-acl/>'));
        expect(xmlList, contains('<D:read-current-user-privilege-set/>'));
      });

      test('should combine write privileges', () {
        const privileges = <dynamic>[
          Write(),
          WriteProperties(),
          WriteContent(),
          WriteAcl(),
        ];
        final xmlList = privileges.map((p) => p.toXml()).toList();

        expect(xmlList, contains('<D:write/>'));
        expect(xmlList, contains('<D:write-properties/>'));
        expect(xmlList, contains('<D:write-content/>'));
        expect(xmlList, contains('<D:write-acl/>'));
      });

      test('should combine binding privileges', () {
        const privileges = <dynamic>[Bind(), UnBind()];
        final xmlList = privileges.map((p) => p.toXml()).toList();

        expect(xmlList, contains('<D:bind/>'));
        expect(xmlList, contains('<D:unbind/>'));
      });

      test('should represent all privileges', () {
        const all = All();
        expect(all.toXml(), equals('<D:all/>'));
      });
    });

    group('Principal Combinations', () {
      test('should represent different principal types', () {
        const principals = <dynamic>[
          Authenticated(),
          Unauthenticated(),
          Self(),
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
          Read(),
          Write(),
          WriteProperties(),
          WriteContent(),
          Unlock(),
          ReadAcl(),
          ReadCurrentUserPrivilegeSet(),
          WriteAcl(),
          Bind(),
          UnBind(),
          All(),
        ];

        for (final privilege in simplePrivileges) {
          final xml = privilege.toXml();
          expect(xml, matches(r'^<D:[a-z\-]+/>$'));
        }
      });

      test('should generate self-closing XML tags for principals', () {
        const principals = <dynamic>[
          Authenticated(),
          Unauthenticated(),
          Self(),
          Protected(),
        ];

        for (final principal in principals) {
          final xml = principal.toXml();
          expect(xml, matches(r'^<D:[a-z\-]+/>$'));
        }
      });

      test('should generate proper XML structure for inherited', () {
        const inherited = Inherited(href: '/test');
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
          Read(),
          Write(),
          WriteProperties(),
          WriteContent(),
          Unlock(),
          ReadAcl(),
          ReadCurrentUserPrivilegeSet(),
          WriteAcl(),
          Bind(),
          UnBind(),
          All(),
          Authenticated(),
          Unauthenticated(),
          Self(),
          Protected(),
        ];

        for (final item in items) {
          final xml = item.toXml();
          expect(xml, startsWith('<D:'));
        }
      });

      test('should use DAV namespace prefix for inherited href', () {
        const inherited = Inherited(href: '/test');
        final xml = inherited.toXml();

        expect(xml, contains('<D:inherited>'));
        expect(xml, contains('<D:href>'));
      });
    });
  });
}
