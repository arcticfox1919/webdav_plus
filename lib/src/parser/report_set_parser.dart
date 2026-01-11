import 'package:xml/xml.dart' as xml;
import 'xml_helpers.dart' as xh;

/// Parse supported-report-set XML fragment into list of report names
List<String> parseSupportedReports(String xmlString) {
  try {
    final doc = xml.XmlDocument.parse(xmlString);
    final list = <String>[];
    final setEl =
        xh.firstDescendantByLocalName(doc.rootElement, 'supported-report-set');
    if (setEl == null) return list;

    final reportEls = xh.descendantsByLocalName(setEl, 'supported-report');
    for (final reportEl in reportEls) {
      final typeEl = xh.firstDescendantByLocalName(reportEl, 'report');
      if (typeEl == null) continue;
      final firstChild =
          typeEl.children.whereType<xml.XmlElement>().firstOrNull;
      if (firstChild != null) list.add(firstChild.name.local);
    }
    return list;
  } catch (_) {
    return [];
  }
}
