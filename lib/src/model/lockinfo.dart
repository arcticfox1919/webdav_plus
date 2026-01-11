import 'package:xml/xml.dart';

/// WebDAV Lock Information Element
///
/// The lockinfo element is used in LOCK requests to specify the lock
/// characteristics including the lock scope, lock type, and optional
/// owner information. This element tells the server what type of lock
/// the client wants to create.
///
/// According to RFC 4918, a lockinfo element must contain:
/// - A lockscope element (exclusive or shared)
/// - A locktype element (typically write)
/// - An optional owner element with lock owner information
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <sequence>
///         <element ref="{DAV:}lockscope"/>
///         <element ref="{DAV:}locktype"/>
///         <element ref="{DAV:}owner" minOccurs="0"/>
///       </sequence>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <?xml version="1.0" encoding="utf-8"?>
/// <D:lockinfo xmlns:D="DAV:">
///   <D:lockscope>
///     <D:exclusive/>
///   </D:lockscope>
///   <D:locktype>
///     <D:write/>
///   </D:locktype>
///   <D:owner>John Doe</D:owner>
/// </D:lockinfo>
/// ```
class Lockinfo {
  final Lockscope lockscope;
  final Locktype locktype;
  final Owner? owner;

  const Lockinfo({required this.lockscope, required this.locktype, this.owner});

  /// Parse Lockinfo from XML string
  static Lockinfo fromXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final root = document.rootElement;
    return fromXmlElement(root);
  }

  /// Parse Lockinfo from XML element
  static Lockinfo fromXmlElement(XmlElement lockinfoElement) {
    // Parse lockscope
    var lockscopeElement = lockinfoElement
        .findAllElements('lockscope')
        .firstOrNull;
    if (lockscopeElement == null) {
      lockscopeElement = lockinfoElement
          .findAllElements('D:lockscope')
          .firstOrNull;
    }
    if (lockscopeElement == null) {
      throw FormatException('Lockinfo element missing lockscope');
    }
    final lockscope = Lockscope.fromXmlElement(lockscopeElement);

    // Parse locktype
    var locktypeElement = lockinfoElement
        .findAllElements('locktype')
        .firstOrNull;
    if (locktypeElement == null) {
      locktypeElement = lockinfoElement
          .findAllElements('D:locktype')
          .firstOrNull;
    }
    if (locktypeElement == null) {
      throw FormatException('Lockinfo element missing locktype');
    }
    final locktype = Locktype.fromXmlElement(locktypeElement);

    // Parse owner (optional)
    var ownerElement = lockinfoElement.findAllElements('owner').firstOrNull;
    if (ownerElement == null) {
      ownerElement = lockinfoElement.findAllElements('D:owner').firstOrNull;
    }
    final owner = ownerElement != null
        ? Owner.fromXmlElement(ownerElement)
        : null;

    return Lockinfo(lockscope: lockscope, locktype: locktype, owner: owner);
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.writeln('<D:lockinfo xmlns:D="DAV:">');
    buffer.writeln('  ${lockscope.toXml()}');
    buffer.writeln('  <D:locktype><D:write/></D:locktype>');

    if (owner != null) {
      buffer.writeln('  ${owner!.toXml()}');
    }

    buffer.write('</D:lockinfo>');
    return buffer.toString();
  }
}

/// WebDAV Lock Scope Element
///
/// The lockscope element indicates the scope of the lock - whether it is
/// an exclusive lock (only one principal may hold the lock) or a shared
/// lock (multiple principals may hold the lock simultaneously).
///
/// According to RFC 4918, the lockscope element must contain exactly one
/// of the following elements:
/// - exclusive: Only one principal may hold the lock
/// - shared: Multiple principals may hold the lock simultaneously
///
/// Most WebDAV implementations primarily support exclusive locks.
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <choice>
///         <element ref="{DAV:}exclusive"/>
///         <element ref="{DAV:}shared"/>
///       </choice>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:lockscope>
///   <D:exclusive/>
/// </D:lockscope>
/// ```
class Lockscope {
  final bool exclusive;

  const Lockscope({required this.exclusive});

  /// Parse Lockscope from XML element
  static Lockscope fromXmlElement(XmlElement lockscopeElement) {
    // Check for exclusive element
    var exclusiveElement = lockscopeElement
        .findAllElements('exclusive')
        .firstOrNull;
    if (exclusiveElement == null) {
      exclusiveElement = lockscopeElement
          .findAllElements('D:exclusive')
          .firstOrNull;
    }
    final exclusive = exclusiveElement != null;

    return Lockscope(exclusive: exclusive);
  }

  String toXml() {
    return '<D:lockscope><D:${exclusive ? 'exclusive' : 'shared'}/></D:lockscope>';
  }
}

/// WebDAV Lock Type Element
///
/// The locktype element specifies the type of lock being requested.
/// According to RFC 4918, the WebDAV specification currently defines
/// only the "write" lock type, which prevents modifications to the
/// locked resource.
///
/// The write lock type prevents other principals from:
/// - Modifying the resource content
/// - Modifying the resource properties
/// - Moving or deleting the resource
/// - Creating new resources in a locked collection
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <choice>
///         <element ref="{DAV:}write"/>
///       </choice>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:locktype>
///   <D:write/>
/// </D:locktype>
/// ```
class Locktype {
  const Locktype();

  /// Parse Locktype from XML element
  static Locktype fromXmlElement(XmlElement locktypeElement) {
    // Currently only 'write' locktype is supported in WebDAV
    return const Locktype();
  }

  String toXml() {
    return '<D:locktype><D:write/></D:locktype>';
  }
}

/// WebDAV Lock Owner Element
///
/// The owner element provides information about the principal that owns
/// the lock. This is optional information that can be used to identify
/// who created the lock, and may be displayed to other users attempting
/// to access the locked resource.
///
/// According to RFC 4918, the owner element can contain any content,
/// including text, XML elements, or other data that identifies the lock
/// owner. The content is not processed by the server but may be returned
/// to clients requesting lock information.
///
/// Common patterns include:
/// - Plain text with the user's name
/// - Email addresses
/// - URLs identifying the user
/// - Structured XML with user information
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <sequence>
///         <any maxOccurs="unbounded" minOccurs="0"/>
///       </sequence>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:owner>John Doe (john@example.com)</D:owner>
/// ```
class Owner {
  final String owner;

  const Owner({required this.owner});

  /// Parse Owner from XML element
  static Owner fromXmlElement(XmlElement ownerElement) {
    final owner = ownerElement.innerText.trim();
    return Owner(owner: owner);
  }

  String toXml() {
    return '<D:owner>$owner</D:owner>';
  }
}
