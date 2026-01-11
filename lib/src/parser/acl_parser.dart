import 'package:xml/xml.dart' as xml;
import '../dav_acl.dart';
import '../dav_ace.dart';
import 'xml_helpers.dart' as xh;

/// Parse ACL (DAV:acl) property XML fragment into DavAcl
DavAcl parseAclFromMultistatusXml(String xmlString, String resourceUrl) {
  try {
    final doc = xml.XmlDocument.parse(xmlString);
    final multistatus = doc.rootElement;
    final responseEl = xh.firstDescendantByLocalName(multistatus, 'response');
    if (responseEl == null) return DavAcl(aces: [], resourceUrl: resourceUrl);

    final propEls = xh.descendantsByLocalName(responseEl, 'prop');
    xml.XmlElement? aclEl;
    for (final propEl in propEls) {
      aclEl = xh.firstDescendantByLocalName(propEl, 'acl');
      if (aclEl != null) break;
    }
    if (aclEl == null) return DavAcl(aces: [], resourceUrl: resourceUrl);

    final aces = <DavAce>[];
    final aceEls = xh.descendantsByLocalName(aclEl, 'ace');
    for (final aceEl in aceEls) {
      String principal = 'unknown';
      final principalEl = xh.firstDescendantByLocalName(aceEl, 'principal');
      if (principalEl != null) {
        final href = xh.textOfFirstDescendant(principalEl, 'href');
        if (href != null && href.isNotEmpty) {
          principal = href;
        } else {
          if (principalEl.findElements('all').isNotEmpty ||
              principalEl.findElements('D:all').isNotEmpty) {
            principal = 'DAV:all';
          } else if (principalEl.findElements('authenticated').isNotEmpty ||
              principalEl.findElements('D:authenticated').isNotEmpty) {
            principal = 'DAV:authenticated';
          } else if (principalEl.findElements('unauthenticated').isNotEmpty ||
              principalEl.findElements('D:unauthenticated').isNotEmpty) {
            principal = 'DAV:unauthenticated';
          } else if (principalEl.findElements('self').isNotEmpty ||
              principalEl.findElements('D:self').isNotEmpty) {
            principal = 'DAV:self';
          }
        }
      }

      bool isGrant = false;
      final grantEl = xh.firstDescendantByLocalName(aceEl, 'grant');
      final denyEl = xh.firstDescendantByLocalName(aceEl, 'deny');
      isGrant = grantEl != null && denyEl == null;
      final privileges = <String>{};
      final container = grantEl ?? denyEl;
      if (container != null) {
        final privilegeEls = xh.descendantsByLocalName(container, 'privilege');
        for (final pEl in privilegeEls) {
          final child = pEl.children.whereType<xml.XmlElement>().firstOrNull;
          if (child != null) privileges.add(child.name.local);
        }
      }

      final isProtected = aceEl.findElements('protected').isNotEmpty ||
          aceEl.findElements('D:protected').isNotEmpty;
      final isInherited = aceEl.findElements('inherited').isNotEmpty ||
          aceEl.findElements('D:inherited').isNotEmpty;

      aces.add(DavAce(
        principal: principal,
        grant: isGrant,
        privileges: privileges,
        inherited: isInherited,
        protected: isProtected,
      ));
    }

    return DavAcl(aces: aces, resourceUrl: resourceUrl);
  } catch (_) {
    return DavAcl(aces: [], resourceUrl: resourceUrl);
  }
}
