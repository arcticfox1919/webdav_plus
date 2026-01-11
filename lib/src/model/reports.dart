/// WebDAV reports and report-related elements
///
/// Contains classes for WebDAV reporting functionality including
/// supported report sets and custom report definitions.

/// Represents a supported report set property
///
/// Lists the reports that are supported by a resource.
///
/// Example XML:
/// ```xml
/// <D:supported-report-set>
///   <D:supported-report>
///     <D:report>
///       <D:version-tree/>
///     </D:report>
///   </D:supported-report>
/// </D:supported-report-set>
/// ```
class SupportedReportSet {
  final List<SupportedReport> supportedReports;

  const SupportedReportSet({this.supportedReports = const []});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:supported-report-set>');

    for (final report in supportedReports) {
      buffer.writeln(report.toXml());
    }

    buffer.write('</D:supported-report-set>');
    return buffer.toString();
  }
}

/// Represents a single supported report
class SupportedReport {
  final Report report;

  const SupportedReport({required this.report});

  String toXml() {
    return '''  <D:supported-report>
${report.toXml()}
  </D:supported-report>''';
  }
}

/// Represents a report element
class Report {
  final String reportName;
  final Map<String, String> attributes;

  const Report({required this.reportName, this.attributes = const {}});

  String toXml() {
    final attrs = attributes.entries
        .map((e) => '${e.key}="${e.value}"')
        .join(' ');
    final attrString = attrs.isNotEmpty ? ' $attrs' : '';

    return '''    <D:report>
      <D:$reportName$attrString/>
    </D:report>''';
  }
}

/// Represents version tree report
class VersionTree {
  const VersionTree();

  String toXml() => '<D:version-tree/>';
}

/// Represents expand property report
class ExpandProperty {
  final List<String> properties;

  const ExpandProperty({this.properties = const []});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:expand-property>');

    for (final prop in properties) {
      buffer.writeln('  <D:property name="$prop"/>');
    }

    buffer.write('</D:expand-property>');
    return buffer.toString();
  }
}
