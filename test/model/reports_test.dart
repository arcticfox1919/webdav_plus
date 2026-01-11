import 'package:test/test.dart';
import 'package:webdav_plus/src/model/reports.dart';

void main() {
  group('Report', () {
    test('should create with report name', () {
      const report = Report(reportName: 'version-tree');

      expect(report.reportName, equals('version-tree'));
      expect(report.attributes, isEmpty);
    });

    test('should create with attributes', () {
      const attributes = {'xmlns': 'DAV:', 'depth': 'infinity'};
      const report = Report(
        reportName: 'custom-report',
        attributes: attributes,
      );

      expect(report.reportName, equals('custom-report'));
      expect(report.attributes, equals(attributes));
    });

    test('should generate correct XML without attributes', () {
      const report = Report(reportName: 'version-tree');
      final xml = report.toXml();

      expect(xml, contains('<D:report>'));
      expect(xml, contains('<D:version-tree/>'));
      expect(xml, contains('</D:report>'));
    });

    test('should generate correct XML with attributes', () {
      const report = Report(
        reportName: 'custom-report',
        attributes: {'xmlns': 'DAV:', 'depth': 'infinity'},
      );
      final xml = report.toXml();

      expect(xml, contains('<D:report>'));
      expect(xml, contains('<D:custom-report'));
      expect(xml, contains('xmlns="DAV:"'));
      expect(xml, contains('depth="infinity"'));
      expect(xml, contains('/>'));
      expect(xml, contains('</D:report>'));
    });

    test('should handle single attribute', () {
      const report = Report(
        reportName: 'test-report',
        attributes: {'type': 'simple'},
      );
      final xml = report.toXml();

      expect(xml, contains('<D:test-report type="simple"/>'));
    });
  });

  group('SupportedReport', () {
    test('should create with report', () {
      const report = Report(reportName: 'version-tree');
      const supportedReport = SupportedReport(report: report);

      expect(supportedReport.report, equals(report));
    });

    test('should generate correct XML', () {
      const report = Report(reportName: 'version-tree');
      const supportedReport = SupportedReport(report: report);
      final xml = supportedReport.toXml();

      expect(xml, contains('<D:supported-report>'));
      expect(xml, contains('<D:report>'));
      expect(xml, contains('<D:version-tree/>'));
      expect(xml, contains('</D:report>'));
      expect(xml, contains('</D:supported-report>'));
    });

    test('should generate correct XML with report attributes', () {
      const report = Report(
        reportName: 'custom-report',
        attributes: {'type': 'extended'},
      );
      const supportedReport = SupportedReport(report: report);
      final xml = supportedReport.toXml();

      expect(xml, contains('<D:supported-report>'));
      expect(xml, contains('<D:custom-report type="extended"/>'));
      expect(xml, contains('</D:supported-report>'));
    });
  });

  group('SupportedReportSet', () {
    test('should create with empty reports', () {
      const reportSet = SupportedReportSet();

      expect(reportSet.supportedReports, isEmpty);
    });

    test('should create with reports', () {
      const reports = [
        SupportedReport(report: Report(reportName: 'version-tree')),
        SupportedReport(report: Report(reportName: 'expand-property')),
      ];
      const reportSet = SupportedReportSet(supportedReports: reports);

      expect(reportSet.supportedReports, equals(reports));
    });

    test('should generate correct XML for empty report set', () {
      const reportSet = SupportedReportSet();
      final xml = reportSet.toXml();

      expect(xml, contains('<D:supported-report-set>'));
      expect(xml, contains('</D:supported-report-set>'));
    });

    test('should generate correct XML with single report', () {
      const reportSet = SupportedReportSet(
        supportedReports: [
          SupportedReport(report: Report(reportName: 'version-tree')),
        ],
      );
      final xml = reportSet.toXml();

      expect(xml, contains('<D:supported-report-set>'));
      expect(xml, contains('<D:supported-report>'));
      expect(xml, contains('<D:report>'));
      expect(xml, contains('<D:version-tree/>'));
      expect(xml, contains('</D:report>'));
      expect(xml, contains('</D:supported-report>'));
      expect(xml, contains('</D:supported-report-set>'));
    });

    test('should generate correct XML with multiple reports', () {
      const reportSet = SupportedReportSet(
        supportedReports: [
          SupportedReport(report: Report(reportName: 'version-tree')),
          SupportedReport(report: Report(reportName: 'expand-property')),
          SupportedReport(
            report: Report(
              reportName: 'custom-report',
              attributes: {'type': 'test'},
            ),
          ),
        ],
      );
      final xml = reportSet.toXml();

      expect(xml, contains('<D:supported-report-set>'));
      expect(xml, contains('<D:version-tree/>'));
      expect(xml, contains('<D:expand-property/>'));
      expect(xml, contains('<D:custom-report type="test"/>'));
      expect(xml, contains('</D:supported-report-set>'));
    });
  });

  group('VersionTree', () {
    test('should create version tree', () {
      const versionTree = VersionTree();

      expect(versionTree, isNotNull);
    });

    test('should generate correct XML', () {
      const versionTree = VersionTree();
      final xml = versionTree.toXml();

      expect(xml, equals('<D:version-tree/>'));
    });
  });

  group('ExpandProperty', () {
    test('should create with empty properties', () {
      const expandProperty = ExpandProperty();

      expect(expandProperty.properties, isEmpty);
    });

    test('should create with properties', () {
      const properties = ['displayname', 'getcontentlength', 'resourcetype'];
      const expandProperty = ExpandProperty(properties: properties);

      expect(expandProperty.properties, equals(properties));
    });

    test('should generate correct XML for empty properties', () {
      const expandProperty = ExpandProperty();
      final xml = expandProperty.toXml();

      expect(xml, contains('<D:expand-property>'));
      expect(xml, contains('</D:expand-property>'));
    });

    test('should generate correct XML with single property', () {
      const expandProperty = ExpandProperty(properties: ['displayname']);
      final xml = expandProperty.toXml();

      expect(xml, contains('<D:expand-property>'));
      expect(xml, contains('<D:property name="displayname"/>'));
      expect(xml, contains('</D:expand-property>'));
    });

    test('should generate correct XML with multiple properties', () {
      const expandProperty = ExpandProperty(
        properties: ['displayname', 'getcontentlength', 'resourcetype'],
      );
      final xml = expandProperty.toXml();

      expect(xml, contains('<D:expand-property>'));
      expect(xml, contains('<D:property name="displayname"/>'));
      expect(xml, contains('<D:property name="getcontentlength"/>'));
      expect(xml, contains('<D:property name="resourcetype"/>'));
      expect(xml, contains('</D:expand-property>'));
    });

    test('should handle special characters in property names', () {
      const expandProperty = ExpandProperty(
        properties: ['custom:property', 'namespace:element'],
      );
      final xml = expandProperty.toXml();

      expect(xml, contains('<D:property name="custom:property"/>'));
      expect(xml, contains('<D:property name="namespace:element"/>'));
    });
  });
}
