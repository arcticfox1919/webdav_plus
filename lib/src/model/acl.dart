import 'package:xml/xml.dart';
import '../parser/xml_helpers.dart' as xh;

/// Access Control List (ACL) element
///
/// The ACL element represents the access control list for a WebDAV resource.
/// It contains a collection of Access Control Entries (ACEs) that define
/// permissions for principals on the resource.
///
/// According to RFC 3744, the ACL element contains zero or more ACE elements,
/// each of which specifies access rights for a particular principal.
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <sequence>
///         <element ref="{DAV:}ace" maxOccurs="unbounded" minOccurs="0"/>
///       </sequence>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:acl xmlns:D="DAV:">
///   <D:ace>
///     <D:principal>
///       <D:href>http://www.example.com/acl/users/gstein</D:href>
///     </D:principal>
///     <D:grant>
///       <D:privilege><D:read/></D:privilege>
///     </D:grant>
///   </D:ace>
/// </D:acl>
/// ```
class Acl {
  final List<Ace> aces;

  const Acl({this.aces = const []});

  /// Parse ACL from XML string
  static Acl fromXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final root = document.rootElement;
    return fromXmlElement(root);
  }

  /// Parse ACL from XML element
  static Acl fromXmlElement(XmlElement aclElement) {
    final aces = <Ace>[];

    // Use local name matching for namespace-agnostic parsing
    final aceElements = xh.descendantsByLocalName(aclElement, 'ace');

    for (final aceElement in aceElements) {
      aces.add(Ace.fromXmlElement(aceElement));
    }

    return Acl(aces: aces);
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:acl xmlns:D="DAV:">');

    for (final ace in aces) {
      buffer.writeln(ace.toXml());
    }

    buffer.write('</D:acl>');
    return buffer.toString();
  }
}

/// Access Control Entry (ACE) element
///
/// An ACE represents a single access control entry that specifies the access
/// rights for a particular principal. Each ACE contains a principal, either
/// a grant or deny element, and optional protected and inherited elements.
///
/// According to RFC 3744, an ACE MUST contain exactly one principal element
/// and exactly one grant or deny element. The protected element indicates
/// that the ACE is protected and cannot be modified. The inherited element
/// indicates the URL of the resource from which this ACE was inherited.
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <sequence>
///         <element ref="{DAV:}principal"/>
///         <choice>
///           <element ref="{DAV:}grant"/>
///           <element ref="{DAV:}deny"/>
///         </choice>
///         <element ref="{DAV:}protected" minOccurs="0"/>
///         <element ref="{DAV:}inherited" minOccurs="0"/>
///       </sequence>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:ace xmlns:D="DAV:">
///   <D:principal>
///     <D:href>http://www.example.com/acl/users/gstein</D:href>
///   </D:principal>
///   <D:grant>
///     <D:privilege><D:read/></D:privilege>
///   </D:grant>
///   <D:protected/>
/// </D:ace>
/// ```
class Ace {
  final Principal principal;
  final Grant? grant;
  final Deny? deny;
  final bool isProtected;
  final String? inherited;

  const Ace({
    required this.principal,
    this.grant,
    this.deny,
    this.isProtected = false,
    this.inherited,
  });

  /// Parse ACE from XML element
  static Ace fromXmlElement(XmlElement aceElement) {
    // Parse principal
    final principalElement = xh.firstDescendantByLocalName(
      aceElement,
      'principal',
    );
    if (principalElement == null) {
      throw FormatException('ACE element missing principal');
    }
    final principal = Principal.fromXmlElement(principalElement);

    // Parse grant
    final grantElement = xh.firstDescendantByLocalName(aceElement, 'grant');
    final grant = grantElement != null
        ? Grant.fromXmlElement(grantElement)
        : null;

    // Parse deny
    final denyElement = xh.firstDescendantByLocalName(aceElement, 'deny');
    final deny = denyElement != null ? Deny.fromXmlElement(denyElement) : null;

    // Check protected
    final protectedElement = xh.firstDescendantByLocalName(
      aceElement,
      'protected',
    );
    final isProtected = protectedElement != null;

    // Parse inherited
    final inheritedElement = xh.firstDescendantByLocalName(
      aceElement,
      'inherited',
    );
    final inherited = inheritedElement?.innerText;

    return Ace(
      principal: principal,
      grant: grant,
      deny: deny,
      isProtected: isProtected,
      inherited: inherited,
    );
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('  <D:ace>');
    buffer.writeln(principal.toXml());

    if (grant != null) {
      buffer.writeln(grant!.toXml());
    } else if (deny != null) {
      buffer.writeln(deny!.toXml());
    }

    if (isProtected) {
      buffer.writeln('    <D:protected/>');
    }

    if (inherited != null) {
      buffer.writeln('    <D:inherited>');
      buffer.writeln('      <D:href>$inherited</D:href>');
      buffer.writeln('    </D:inherited>');
    }

    buffer.write('  </D:ace>');
    return buffer.toString();
  }
}

/// Principal element for Access Control
///
/// The principal element identifies the principal (user, group, or special entity)
/// to which the access control entry applies. A principal can be identified by:
/// - href: A URL that identifies a principal
/// - all: Matches all principals
/// - authenticated: Matches all authenticated principals
/// - unauthenticated: Matches all unauthenticated principals
/// - self: Matches the principal associated with the current request
/// - property: Matches principals identified by a property value
///
/// According to RFC 3744, exactly one of these identification methods must be used.
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <choice>
///         <element ref="{DAV:}href"/>
///         <element ref="{DAV:}all"/>
///         <element ref="{DAV:}authenticated"/>
///         <element ref="{DAV:}unauthenticated"/>
///         <element ref="{DAV:}self"/>
///         <element ref="{DAV:}property"/>
///       </choice>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:principal>
///   <D:href>http://www.example.com/acl/users/gstein</D:href>
/// </D:principal>
/// ```
class Principal {
  final String? href;
  final bool isAll;
  final bool isAuthenticated;
  final bool isUnauthenticated;
  final bool isSelf;
  final String? property;

  const Principal({
    this.href,
    this.isAll = false,
    this.isAuthenticated = false,
    this.isUnauthenticated = false,
    this.isSelf = false,
    this.property,
  });

  /// Parse Principal from XML element
  static Principal fromXmlElement(XmlElement principalElement) {
    // Check for href
    final hrefElement = xh.firstDescendantByLocalName(principalElement, 'href');
    final href = hrefElement?.innerText;

    // Check for special principal types
    final allElement = xh.firstDescendantByLocalName(principalElement, 'all');
    final isAll = allElement != null;

    final authenticatedElement = xh.firstDescendantByLocalName(
      principalElement,
      'authenticated',
    );
    final isAuthenticated = authenticatedElement != null;

    final unauthenticatedElement = xh.firstDescendantByLocalName(
      principalElement,
      'unauthenticated',
    );
    final isUnauthenticated = unauthenticatedElement != null;

    final selfElement = xh.firstDescendantByLocalName(principalElement, 'self');
    final isSelf = selfElement != null;

    // Check for property
    final propertyElement = xh.firstDescendantByLocalName(
      principalElement,
      'property',
    );
    final property = propertyElement?.innerText;

    return Principal(
      href: href,
      isAll: isAll,
      isAuthenticated: isAuthenticated,
      isUnauthenticated: isUnauthenticated,
      isSelf: isSelf,
      property: property,
    );
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('    <D:principal>');

    if (href != null) {
      buffer.writeln('      <D:href>$href</D:href>');
    } else if (isAll) {
      buffer.writeln('      <D:all/>');
    } else if (isAuthenticated) {
      buffer.writeln('      <D:authenticated/>');
    } else if (isUnauthenticated) {
      buffer.writeln('      <D:unauthenticated/>');
    } else if (isSelf) {
      buffer.writeln('      <D:self/>');
    } else if (property != null) {
      buffer.writeln('      <D:property>');
      buffer.writeln('        <$property/>');
      buffer.writeln('      </D:property>');
    }

    buffer.write('    </D:principal>');
    return buffer.toString();
  }
}

/// Grant element for Access Control Entry
///
/// The grant element specifies the privileges being granted to the principal.
/// It contains one or more privilege elements that define the specific
/// access rights being granted.
///
/// According to RFC 3744, the grant element contains a sequence of privilege
/// elements that specify the exact privileges being granted.
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <sequence>
///         <element ref="{DAV:}privilege" maxOccurs="unbounded"/>
///       </sequence>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:grant>
///   <D:privilege><D:read/></D:privilege>
///   <D:privilege><D:write/></D:privilege>
/// </D:grant>
/// ```
class Grant {
  final List<Privilege> privileges;

  const Grant({required this.privileges});

  /// Parse Grant from XML element
  static Grant fromXmlElement(XmlElement grantElement) {
    final privileges = <Privilege>[];

    // Use local name matching for namespace-agnostic parsing
    final privilegeElements = xh.descendantsByLocalName(
      grantElement,
      'privilege',
    );

    for (final privilegeElement in privilegeElements) {
      privileges.add(Privilege.fromXmlElement(privilegeElement));
    }

    return Grant(privileges: privileges);
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('    <D:grant>');

    for (final privilege in privileges) {
      buffer.writeln(privilege.toXml());
    }

    buffer.write('    </D:grant>');
    return buffer.toString();
  }
}

/// Deny element for Access Control Entry
///
/// The deny element specifies the privileges being denied to the principal.
/// It contains one or more privilege elements that define the specific
/// access rights being denied.
///
/// According to RFC 3744, the deny element has the same structure as the
/// grant element but explicitly denies the specified privileges instead
/// of granting them.
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <sequence>
///         <element ref="{DAV:}privilege" maxOccurs="unbounded"/>
///       </sequence>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:deny>
///   <D:privilege><D:write/></D:privilege>
/// </D:deny>
/// ```
class Deny {
  final List<Privilege> privileges;

  const Deny({required this.privileges});

  /// Parse Deny from XML element
  static Deny fromXmlElement(XmlElement denyElement) {
    final privileges = <Privilege>[];

    // Use local name matching for namespace-agnostic parsing
    final privilegeElements = xh.descendantsByLocalName(
      denyElement,
      'privilege',
    );

    for (final privilegeElement in privilegeElements) {
      privileges.add(Privilege.fromXmlElement(privilegeElement));
    }

    return Deny(privileges: privileges);
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('    <D:deny>');

    for (final privilege in privileges) {
      buffer.writeln(privilege.toXml());
    }

    buffer.write('    </D:deny>');
    return buffer.toString();
  }
}

/// Privilege element for Access Control
///
/// The privilege element identifies a particular privilege (permission) that
/// can be granted or denied to a principal. WebDAV defines a set of standard
/// privileges, and servers may define additional custom privileges.
///
/// According to RFC 3744, privileges are represented as empty XML elements
/// within a privilege container. The name of the element identifies the
/// specific privilege type.
///
/// Standard WebDAV privileges include:
/// - read: Permission to read resource content and properties
/// - write: Aggregate privilege that includes write-properties and write-content
/// - write-properties: Permission to modify properties
/// - write-content: Permission to modify resource content
/// - unlock: Permission to remove locks
/// - read-acl: Permission to read the access control list
/// - write-acl: Permission to modify the access control list
/// - bind: Permission to create new bindings to the collection
/// - unbind: Permission to remove bindings from the collection
/// - all: Aggregate privilege that includes all privileges
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <choice>
///         <element ref="{DAV:}read"/>
///         <element ref="{DAV:}write"/>
///         <element ref="{DAV:}write-properties"/>
///         <element ref="{DAV:}write-content"/>
///         <element ref="{DAV:}unlock"/>
///         <element ref="{DAV:}read-acl"/>
///         <element ref="{DAV:}write-acl"/>
///         <element ref="{DAV:}read-current-user-privilege-set"/>
///         <element ref="{DAV:}bind"/>
///         <element ref="{DAV:}unbind"/>
///         <element ref="{DAV:}all"/>
///       </choice>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:privilege>
///   <D:read/>
/// </D:privilege>
/// ```
class Privilege {
  final String name;

  const Privilege({required this.name});

  /// Parse Privilege from XML element
  static Privilege fromXmlElement(XmlElement privilegeElement) {
    // Find the first child element which represents the privilege name
    final privilegeChild = privilegeElement.children
        .whereType<XmlElement>()
        .firstOrNull;
    if (privilegeChild == null) {
      throw FormatException('Privilege element missing privilege type');
    }

    final name = privilegeChild.name.local;
    return Privilege(name: name);
  }

  String toXml() {
    return '''      <D:privilege>
        <D:$name/>
      </D:privilege>''';
  }

  // Standard WebDAV privileges
  static const Privilege read = Privilege(name: 'read');
  static const Privilege write = Privilege(name: 'write');
  static const Privilege writeProperties = Privilege(name: 'write-properties');
  static const Privilege writeContent = Privilege(name: 'write-content');
  static const Privilege unlock = Privilege(name: 'unlock');
  static const Privilege readAcl = Privilege(name: 'read-acl');
  static const Privilege readCurrentUserPrivilegeSet = Privilege(
    name: 'read-current-user-privilege-set',
  );
  static const Privilege writeAcl = Privilege(name: 'write-acl');
  static const Privilege bind = Privilege(name: 'bind');
  static const Privilege unbind = Privilege(name: 'unbind');
  static const Privilege all = Privilege(name: 'all');
}
