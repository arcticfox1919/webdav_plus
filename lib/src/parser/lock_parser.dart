import 'package:xml/xml.dart' as xml;
import '../model/lock.dart' show Activelock;
import 'xml_helpers.dart' as xh;

/// Parse lockdiscovery XML fragment into list of Activelock
List<Activelock> parseActiveLocks(String xmlString) {
  try {
    final doc = xml.XmlDocument.parse(xmlString);
    final locks = <Activelock>[];
    final discoveryEl =
        xh.firstDescendantByLocalName(doc.rootElement, 'lockdiscovery');
    if (discoveryEl == null) return locks;

    final activeLockEls = xh.descendantsByLocalName(discoveryEl, 'activelock');
    for (final el in activeLockEls) {
      String scope = (xh.firstDescendantByLocalName(el, 'shared') != null)
          ? 'shared'
          : 'exclusive';
      String type = 'write';
      final depth = xh.textOfFirstDescendant(el, 'depth') ?? '0';
      final owner = xh.textOfFirstDescendant(el, 'owner');
      final timeout = xh.textOfFirstDescendant(el, 'timeout');
      final tokenHref = xh.textOfFirstDescendant(el, 'href');
      locks.add(Activelock(
        lockscope: scope,
        locktype: type,
        depth: depth,
        owner: owner,
        timeout: timeout,
        locktoken: tokenHref,
      ));
    }
    return locks;
  } catch (_) {
    return [];
  }
}
