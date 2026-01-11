import 'package:xml/xml.dart' as xml;

/// Returns the first descendant element by local name (ignores namespace/prefix)
xml.XmlElement? firstDescendantByLocalName(xml.XmlNode node, String localName) {
  for (final el in node.descendants.whereType<xml.XmlElement>()) {
    if (el.name.local == localName) return el;
  }
  return null;
}

/// Returns all descendant elements by local name (ignores namespace/prefix)
Iterable<xml.XmlElement> descendantsByLocalName(
  xml.XmlNode node,
  String localName,
) {
  return node.descendants
      .whereType<xml.XmlElement>()
      .where((e) => e.name.local == localName);
}

/// Returns the innerText of the first descendant element by local name
String? textOfFirstDescendant(xml.XmlNode node, String localName) {
  final el = firstDescendantByLocalName(node, localName);
  return el?.innerText.trim();
}
