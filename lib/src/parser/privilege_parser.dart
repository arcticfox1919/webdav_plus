import 'package:xml/xml.dart' as xml;
import 'xml_helpers.dart' as xh;

/// Parse current-user-privilege-set XML fragment into list of privilege names
List<String> parsePrivileges(String xmlString) {
  try {
    final doc = xml.XmlDocument.parse(xmlString);
    final result = <String>[];
    final setEl = xh.firstDescendantByLocalName(
        doc.rootElement, 'current-user-privilege-set');
    if (setEl == null) return result;
    final privEls = xh.descendantsByLocalName(setEl, 'privilege');
    for (final p in privEls) {
      final child = p.children.whereType<xml.XmlElement>().firstOrNull;
      if (child != null) result.add(child.name.local);
    }
    return result;
  } catch (_) {
    return [];
  }
}
