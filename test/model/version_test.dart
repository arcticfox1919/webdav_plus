import 'package:test/test.dart';
import '../../lib/src/model/version.dart';

void main() {
  group('VersionControl Tests', () {
    test('should generate XML without version', () {
      final versionControl = VersionControl();
      final xml = versionControl.toXml();

      expect(xml, contains('<D:version-control xmlns:D="DAV:">'));
      expect(xml, contains('</D:version-control>'));
      expect(xml, isNot(contains('<D:version>')));
    });

    test('should generate XML with version', () {
      final versionControl = VersionControl(version: '/versions/1.0');
      final xml = versionControl.toXml();

      expect(xml, contains('<D:version-control xmlns:D="DAV:">'));
      expect(xml, contains('<D:version>'));
      expect(xml, contains('<D:href>/versions/1.0</D:href>'));
      expect(xml, contains('</D:version>'));
      expect(xml, contains('</D:version-control>'));
    });

    test('should handle null version gracefully', () {
      final versionControl = VersionControl(version: null);
      final xml = versionControl.toXml();

      expect(xml, contains('<D:version-control xmlns:D="DAV:">'));
      expect(xml, contains('</D:version-control>'));
      expect(xml, isNot(contains('<D:version>')));
    });
  });

  group('Checkout Tests', () {
    test('should generate XML without activity set', () {
      final checkout = Checkout();
      final xml = checkout.toXml();

      expect(xml, contains('<D:checkout xmlns:D="DAV:">'));
      expect(xml, contains('</D:checkout>'));
      expect(xml, isNot(contains('<D:activity-set>')));
    });

    test('should generate XML with activity set', () {
      final checkout = Checkout(activitySet: '/activities/fix-123');
      final xml = checkout.toXml();

      expect(xml, contains('<D:checkout xmlns:D="DAV:">'));
      expect(xml, contains('<D:activity-set>'));
      expect(xml, contains('<D:href>/activities/fix-123</D:href>'));
      expect(xml, contains('</D:activity-set>'));
      expect(xml, contains('</D:checkout>'));
    });

    test('should handle null activity set gracefully', () {
      final checkout = Checkout(activitySet: null);
      final xml = checkout.toXml();

      expect(xml, contains('<D:checkout xmlns:D="DAV:">'));
      expect(xml, contains('</D:checkout>'));
      expect(xml, isNot(contains('<D:activity-set>')));
    });
  });

  group('Checkin Tests', () {
    test('should generate XML without keep-checked-out by default', () {
      final checkin = Checkin();
      final xml = checkin.toXml();

      expect(xml, contains('<D:checkin xmlns:D="DAV:">'));
      expect(xml, contains('</D:checkin>'));
      expect(xml, isNot(contains('<D:keep-checked-out/>')));
    });

    test('should generate XML without keep-checked-out when false', () {
      final checkin = Checkin(keepCheckedOut: false);
      final xml = checkin.toXml();

      expect(xml, contains('<D:checkin xmlns:D="DAV:">'));
      expect(xml, contains('</D:checkin>'));
      expect(xml, isNot(contains('<D:keep-checked-out/>')));
    });

    test('should generate XML with keep-checked-out when true', () {
      final checkin = Checkin(keepCheckedOut: true);
      final xml = checkin.toXml();

      expect(xml, contains('<D:checkin xmlns:D="DAV:">'));
      expect(xml, contains('<D:keep-checked-out/>'));
      expect(xml, contains('</D:checkin>'));
    });
  });

  group('Uncheckout Tests', () {
    test('should generate simple XML', () {
      final uncheckout = Uncheckout();
      final xml = uncheckout.toXml();

      expect(xml, equals('<D:uncheckout xmlns:D="DAV:"/>'));
    });

    test('should be consistent across instances', () {
      final uncheckout1 = Uncheckout();
      final uncheckout2 = Uncheckout();

      expect(uncheckout1.toXml(), equals(uncheckout2.toXml()));
    });
  });

  group('BaselineControl Tests', () {
    test('should generate XML without baseline', () {
      final baselineControl = BaselineControl();
      final xml = baselineControl.toXml();

      expect(xml, contains('<D:baseline-control xmlns:D="DAV:">'));
      expect(xml, contains('</D:baseline-control>'));
      expect(xml, isNot(contains('<D:baseline>')));
    });

    test('should generate XML with baseline', () {
      final baselineControl = BaselineControl(baseline: '/baselines/1.0');
      final xml = baselineControl.toXml();

      expect(xml, contains('<D:baseline-control xmlns:D="DAV:">'));
      expect(xml, contains('<D:baseline>'));
      expect(xml, contains('<D:href>/baselines/1.0</D:href>'));
      expect(xml, contains('</D:baseline>'));
      expect(xml, contains('</D:baseline-control>'));
    });

    test('should handle null baseline gracefully', () {
      final baselineControl = BaselineControl(baseline: null);
      final xml = baselineControl.toXml();

      expect(xml, contains('<D:baseline-control xmlns:D="DAV:">'));
      expect(xml, contains('</D:baseline-control>'));
      expect(xml, isNot(contains('<D:baseline>')));
    });
  });

  group('MkBaseline Tests', () {
    test('should generate simple XML', () {
      final mkBaseline = MkBaseline();
      final xml = mkBaseline.toXml();

      expect(xml, equals('<D:mkbaseline xmlns:D="DAV:"/>'));
    });

    test('should be consistent across instances', () {
      final mkBaseline1 = MkBaseline();
      final mkBaseline2 = MkBaseline();

      expect(mkBaseline1.toXml(), equals(mkBaseline2.toXml()));
    });
  });

  group('VersionInfo Tests', () {
    test('should create with required href', () {
      final versionInfo = VersionInfo(href: '/versions/1.0');

      expect(versionInfo.href, equals('/versions/1.0'));
      expect(versionInfo.comment, isNull);
      expect(versionInfo.creatorDisplayName, isNull);
      expect(versionInfo.creationDate, isNull);
    });

    test('should create with all properties', () {
      final creationDate = DateTime(2023, 1, 1, 10, 30);
      final versionInfo = VersionInfo(
        href: '/versions/2.0',
        comment: 'Added new features',
        creatorDisplayName: 'John Doe',
        creationDate: creationDate,
      );

      expect(versionInfo.href, equals('/versions/2.0'));
      expect(versionInfo.comment, equals('Added new features'));
      expect(versionInfo.creatorDisplayName, equals('John Doe'));
      expect(versionInfo.creationDate, equals(creationDate));
    });

    test('should handle optional properties as null', () {
      final versionInfo = VersionInfo(
        href: '/versions/3.0',
        comment: null,
        creatorDisplayName: null,
        creationDate: null,
      );

      expect(versionInfo.href, equals('/versions/3.0'));
      expect(versionInfo.comment, isNull);
      expect(versionInfo.creatorDisplayName, isNull);
      expect(versionInfo.creationDate, isNull);
    });
  });

  group('BaselineInfo Tests', () {
    test('should create with required href', () {
      final baselineInfo = BaselineInfo(href: '/baselines/1.0');

      expect(baselineInfo.href, equals('/baselines/1.0'));
      expect(baselineInfo.comment, isNull);
      expect(baselineInfo.creationDate, isNull);
      expect(baselineInfo.versionSet, isEmpty);
    });

    test('should create with all properties', () {
      final creationDate = DateTime(2023, 2, 1, 14, 45);
      final versionSet = ['/versions/1.0', '/versions/1.1', '/versions/1.2'];
      final baselineInfo = BaselineInfo(
        href: '/baselines/2.0',
        comment: 'Stable release baseline',
        creationDate: creationDate,
        versionSet: versionSet,
      );

      expect(baselineInfo.href, equals('/baselines/2.0'));
      expect(baselineInfo.comment, equals('Stable release baseline'));
      expect(baselineInfo.creationDate, equals(creationDate));
      expect(baselineInfo.versionSet, equals(versionSet));
    });

    test('should handle empty version set by default', () {
      final baselineInfo = BaselineInfo(href: '/baselines/3.0');

      expect(baselineInfo.versionSet, isEmpty);
      expect(baselineInfo.versionSet, isA<List<String>>());
    });

    test('should handle version set with multiple entries', () {
      final versionSet = ['/v1', '/v2', '/v3', '/v4'];
      final baselineInfo = BaselineInfo(
        href: '/baselines/4.0',
        versionSet: versionSet,
      );

      expect(baselineInfo.versionSet, hasLength(4));
      expect(baselineInfo.versionSet, contains('/v1'));
      expect(baselineInfo.versionSet, contains('/v4'));
    });
  });

  group('Activity Tests', () {
    test('should create with required href', () {
      final activity = Activity(href: '/activities/feature-123');

      expect(activity.href, equals('/activities/feature-123'));
      expect(activity.displayName, isNull);
      expect(activity.comment, isNull);
    });

    test('should generate XML with href only', () {
      final activity = Activity(href: '/activities/feature-456');
      final xml = activity.toXml();

      expect(xml, contains('<D:activity xmlns:D="DAV:">'));
      expect(xml, contains('<D:href>/activities/feature-456</D:href>'));
      expect(xml, contains('</D:activity>'));
      expect(xml, isNot(contains('<D:displayname>')));
      expect(xml, isNot(contains('<D:comment>')));
    });

    test('should generate XML with all properties', () {
      final activity = Activity(
        href: '/activities/bugfix-789',
        displayName: 'Bug Fix #789',
        comment: 'Fixes critical security issue',
      );
      final xml = activity.toXml();

      expect(xml, contains('<D:activity xmlns:D="DAV:">'));
      expect(xml, contains('<D:href>/activities/bugfix-789</D:href>'));
      expect(xml, contains('<D:displayname>Bug Fix #789</D:displayname>'));
      expect(
        xml,
        contains('<D:comment>Fixes critical security issue</D:comment>'),
      );
      expect(xml, contains('</D:activity>'));
    });

    test('should generate XML with partial properties', () {
      final activity = Activity(
        href: '/activities/refactor-001',
        displayName: 'Code Refactoring',
      );
      final xml = activity.toXml();

      expect(xml, contains('<D:activity xmlns:D="DAV:">'));
      expect(xml, contains('<D:href>/activities/refactor-001</D:href>'));
      expect(xml, contains('<D:displayname>Code Refactoring</D:displayname>'));
      expect(xml, contains('</D:activity>'));
      expect(xml, isNot(contains('<D:comment>')));
    });
  });

  group('VersionTree Tests', () {
    test('should create with empty properties by default', () {
      final versionTree = VersionTree();

      expect(versionTree.properties, isEmpty);
    });

    test('should generate XML without properties', () {
      final versionTree = VersionTree();
      final xml = versionTree.toXml();

      expect(xml, contains('<D:version-tree xmlns:D="DAV:">'));
      expect(xml, contains('</D:version-tree>'));
      expect(xml, isNot(contains('<D:prop>')));
    });

    test('should generate XML with single property', () {
      final versionTree = VersionTree(properties: ['version-name']);
      final xml = versionTree.toXml();

      expect(xml, contains('<D:version-tree xmlns:D="DAV:">'));
      expect(xml, contains('<D:prop>'));
      expect(xml, contains('<D:version-name/>'));
      expect(xml, contains('</D:prop>'));
      expect(xml, contains('</D:version-tree>'));
    });

    test('should generate XML with multiple properties', () {
      final versionTree = VersionTree(
        properties: [
          'version-name',
          'creator-displayname',
          'successor-set',
          'predecessor-set',
        ],
      );
      final xml = versionTree.toXml();

      expect(xml, contains('<D:version-tree xmlns:D="DAV:">'));
      expect(xml, contains('<D:prop>'));
      expect(xml, contains('<D:version-name/>'));
      expect(xml, contains('<D:creator-displayname/>'));
      expect(xml, contains('<D:successor-set/>'));
      expect(xml, contains('<D:predecessor-set/>'));
      expect(xml, contains('</D:prop>'));
      expect(xml, contains('</D:version-tree>'));
    });

    test('should handle custom properties', () {
      final versionTree = VersionTree(
        properties: ['custom-property-1', 'custom-property-2'],
      );
      final xml = versionTree.toXml();

      expect(xml, contains('<D:custom-property-1/>'));
      expect(xml, contains('<D:custom-property-2/>'));
    });

    test('should maintain property order', () {
      final properties = ['z-prop', 'a-prop', 'm-prop'];
      final versionTree = VersionTree(properties: properties);
      final xml = versionTree.toXml();

      final zIndex = xml.indexOf('<D:z-prop/>');
      final aIndex = xml.indexOf('<D:a-prop/>');
      final mIndex = xml.indexOf('<D:m-prop/>');

      expect(zIndex, lessThan(aIndex));
      expect(aIndex, lessThan(mIndex));
    });
  });

  group('XML Generation Integration Tests', () {
    test('should generate proper WebDAV XML structure', () {
      final versionControl = VersionControl(version: '/versions/1.0');
      final xml = versionControl.toXml();

      expect(xml, startsWith('<D:version-control xmlns:D="DAV:">'));
      expect(xml, endsWith('</D:version-control>'));
      expect(xml, isNot(contains('null')));
    });

    test('should handle special characters in URLs', () {
      final activity = Activity(
        href: '/activities/fix-&-improve',
        displayName: 'Fix & Improve',
        comment: 'Handle <special> characters',
      );
      final xml = activity.toXml();

      expect(xml, contains('/activities/fix-&-improve'));
      expect(xml, contains('Fix & Improve'));
      expect(xml, contains('Handle <special> characters'));
    });

    test('should generate compact XML for simple elements', () {
      final uncheckout = Uncheckout();
      final mkBaseline = MkBaseline();

      expect(uncheckout.toXml(), equals('<D:uncheckout xmlns:D="DAV:"/>'));
      expect(mkBaseline.toXml(), equals('<D:mkbaseline xmlns:D="DAV:"/>'));
    });
  });
}
