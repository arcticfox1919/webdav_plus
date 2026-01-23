/// WebDAV Standard Properties
///
/// This file contains classes representing standard WebDAV properties
/// as defined in RFC 4918 and related specifications. These properties
/// provide metadata about WebDAV resources including content information,
/// access control, locking, and resource organization.
library;

/// WebDAV Resourcetype Property
///
/// The resourcetype property specifies the nature of the resource.
/// It identifies whether a resource is a collection (container that can
/// contain other resources) or a non-collection resource (typically a file).
///
/// According to RFC 4918, the resourcetype property is a live property
/// that servers must support. For collections, it contains a collection
/// element. For non-collections, it is typically empty but may contain
/// custom type elements defined by the server or application.
///
/// XML Schema fragment:
/// ```xml
/// <complexType mixed="true">
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <choice minOccurs="0" maxOccurs="unbounded">
///         <element ref="{DAV:}collection"/>
///         <any namespace="##other"/>
///       </choice>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:resourcetype>
///   <D:collection/>
/// </D:resourcetype>
/// ```
class Resourcetype {
  final bool isCollection;
  final List<String> customTypes;

  const Resourcetype({this.isCollection = false, this.customTypes = const []});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:resourcetype>');

    if (isCollection) {
      buffer.writeln('  <D:collection/>');
    }

    for (final type in customTypes) {
      buffer.writeln('  <$type/>');
    }

    buffer.write('</D:resourcetype>');
    return buffer.toString();
  }
}

/// WebDAV Collection Element
///
/// The collection element indicates that the associated resource is a
/// collection (a resource that can contain other resources). This element
/// is typically found within a resourcetype property.
///
/// According to RFC 4918, a collection is a resource whose state consists
/// of at least a list of internal member URIs and a set of properties.
/// Collections can contain other collections, creating a hierarchical
/// namespace structure.
///
/// Example XML:
/// ```xml
/// <D:collection/>
/// ```
class Collection {
  const Collection();

  String toXml() => '<D:collection/>';
}

/// WebDAV Creationdate Property
///
/// The creationdate property reports the date and time when the resource
/// was created. This is a live property that contains the creation
/// timestamp in ISO 8601 format.
///
/// According to RFC 4918, servers should return the creationdate property
/// but are not required to support it. The date format should follow
/// the ISO 8601 standard with timezone information.
///
/// Example XML:
/// ```xml
/// <D:creationdate>2023-12-25T10:30:45Z</D:creationdate>
/// ```
class Creationdate {
  final DateTime date;

  const Creationdate({required this.date});

  String toXml() {
    return '<D:creationdate>${date.toIso8601String()}</D:creationdate>';
  }
}

/// WebDAV Displayname Property
///
/// The displayname property provides a human-readable name for the resource.
/// This name is intended for presentation to users and may differ from the
/// resource's URI segment name.
///
/// According to RFC 4918, the displayname property is typically used by
/// clients when presenting lists of resources to users. The value should
/// be suitable for display purposes and may contain any Unicode characters.
///
/// Example XML:
/// ```xml
/// <D:displayname>My Important Document</D:displayname>
/// ```
class Displayname {
  final String name;

  const Displayname({required this.name});

  String toXml() {
    return '<D:displayname>$name</D:displayname>';
  }
}

/// Represents a getcontentlanguage property
class Getcontentlanguage {
  final String language;

  const Getcontentlanguage({required this.language});

  String toXml() {
    return '<D:getcontentlanguage>$language</D:getcontentlanguage>';
  }
}

/// Represents a getcontentlength property
class Getcontentlength {
  final int length;

  const Getcontentlength({required this.length});

  String toXml() {
    return '<D:getcontentlength>$length</D:getcontentlength>';
  }
}

/// Represents a getcontenttype property
class Getcontenttype {
  final String contentType;

  const Getcontenttype({required this.contentType});

  String toXml() {
    return '<D:getcontenttype>$contentType</D:getcontenttype>';
  }
}

/// Represents a getetag property
class Getetag {
  final String etag;

  const Getetag({required this.etag});

  String toXml() {
    return '<D:getetag>$etag</D:getetag>';
  }
}

/// Represents a getlastmodified property
class Getlastmodified {
  final DateTime date;

  const Getlastmodified({required this.date});

  String toXml() {
    // RFC 2822 format for Last-Modified
    return '<D:getlastmodified>${date.toUtc()}</D:getlastmodified>';
  }
}

/// Represents a quota-available-bytes property
class QuotaAvailableBytes {
  final String bytes;

  const QuotaAvailableBytes({required this.bytes});

  String toXml() {
    return '<D:quota-available-bytes>$bytes</D:quota-available-bytes>';
  }
}

/// Represents a quota-used-bytes property
class QuotaUsedBytes {
  final String bytes;

  const QuotaUsedBytes({required this.bytes});

  String toXml() {
    return '<D:quota-used-bytes>$bytes</D:quota-used-bytes>';
  }
}

/// Represents source property
class Source {
  final List<Link> links;

  const Source({this.links = const []});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:source>');

    for (final link in links) {
      buffer.writeln(link.toXml());
    }

    buffer.write('</D:source>');
    return buffer.toString();
  }
}

/// Represents a link element
class Link {
  final String src;
  final String dst;

  const Link({required this.src, required this.dst});

  String toXml() {
    return '''  <D:link>
    <D:src>$src</D:src>
    <D:dst>$dst</D:dst>
  </D:link>''';
  }
}

/// Represents a supportedlock property
///
/// Lists the types of locks that are supported by a resource.
class Supportedlock {
  final List<Lockentry> lockentries;

  const Supportedlock({this.lockentries = const []});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:supportedlock>');

    for (final entry in lockentries) {
      buffer.writeln(entry.toXml());
    }

    buffer.write('</D:supportedlock>');
    return buffer.toString();
  }
}

/// Represents a lockentry element
class Lockentry {
  final String lockscope; // 'exclusive' or 'shared'
  final String locktype; // typically 'write'

  const Lockentry({required this.lockscope, required this.locktype});

  String toXml() {
    return '''  <D:lockentry>
    <D:lockscope>
      <D:$lockscope/>
    </D:lockscope>
    <D:locktype>
      <D:$locktype/>
    </D:locktype>
  </D:lockentry>''';
  }
}

/// Represents a lockdiscovery property
///
/// Contains information about locks currently held on a resource.
class Lockdiscovery {
  final List<ActivelockProperty> activelocks;

  const Lockdiscovery({this.activelocks = const []});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:lockdiscovery>');

    for (final lock in activelocks) {
      buffer.writeln(lock.toXml());
    }

    buffer.write('</D:lockdiscovery>');
    return buffer.toString();
  }
}

/// Represents an activelock element for property use
///
/// This is different from the Activelock in lock.dart which is for lock operations.
/// This one is used as a property value.
class ActivelockProperty {
  final String lockscope; // 'exclusive' or 'shared'
  final String locktype; // typically 'write'
  final String depth;
  final String? owner;
  final String? timeout;
  final String? locktoken;

  const ActivelockProperty({
    required this.lockscope,
    required this.locktype,
    required this.depth,
    this.owner,
    this.timeout,
    this.locktoken,
  });

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('  <D:activelock>');
    buffer.writeln('    <D:lockscope>');
    buffer.writeln('      <D:$lockscope/>');
    buffer.writeln('    </D:lockscope>');
    buffer.writeln('    <D:locktype>');
    buffer.writeln('      <D:$locktype/>');
    buffer.writeln('    </D:locktype>');
    buffer.writeln('    <D:depth>$depth</D:depth>');

    if (owner != null) {
      buffer.writeln('    <D:owner>$owner</D:owner>');
    }

    if (timeout != null) {
      buffer.writeln('    <D:timeout>$timeout</D:timeout>');
    }

    if (locktoken != null) {
      buffer.writeln('    <D:locktoken>');
      buffer.writeln('      <D:href>$locktoken</D:href>');
      buffer.writeln('    </D:locktoken>');
    }

    buffer.write('  </D:activelock>');
    return buffer.toString();
  }
}

/// WebDAV Principal Collection Set Property
///
/// The principal-collection-set property identifies the root collections
/// that contain the principals that are available on the server that
/// implements the resource. This property is part of the WebDAV Access
/// Control Protocol (RFC 3744).
///
/// According to RFC 3744, the value of this property is a set of URIs
/// that identify the root collections that contain all the principals
/// that are available on the server that implements the resource.
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <sequence>
///         <element ref="{DAV:}href" minOccurs="0"/>
///       </sequence>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:principal-collection-set>
///   <D:href>/principals/</D:href>
/// </D:principal-collection-set>
/// ```
class PrincipalCollectionSet {
  final String? href;

  const PrincipalCollectionSet({this.href});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:principal-collection-set>');
    if (href != null) {
      buffer.writeln('  <D:href>$href</D:href>');
    }
    buffer.write('</D:principal-collection-set>');
    return buffer.toString();
  }
}

/// WebDAV Principal URL Property
///
/// The principal-URL property identifies a principal that corresponds to
/// the authenticated user of the request. This property is part of the
/// WebDAV Access Control Protocol (RFC 3744).
///
/// According to RFC 3744, this property allows a client to determine
/// the principal resource that corresponds to the currently authenticated
/// user.
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <sequence>
///         <element ref="{DAV:}href" minOccurs="0"/>
///       </sequence>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:principal-URL>
///   <D:href>/principals/users/johndoe</D:href>
/// </D:principal-URL>
/// ```
class PrincipalURL {
  final String? href;

  const PrincipalURL({this.href});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:principal-URL>');
    if (href != null) {
      buffer.writeln('  <D:href>$href</D:href>');
    }
    buffer.write('</D:principal-URL>');
    return buffer.toString();
  }
}

/// WebDAV Principal Element
///
/// The principal element identifies a principal that may be used in an
/// ACE (Access Control Entry). This is part of the WebDAV Access Control
/// Protocol (RFC 3744).
///
/// According to RFC 3744, a principal is a distinct human or computational
/// actor that may be authenticated and associated with a set of privileges.
/// The principal element can contain various child elements including href,
/// all, authenticated, unauthenticated, property, and self.
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
///         <element ref="{DAV:}property"/>
///         <element ref="{DAV:}self"/>
///       </choice>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:principal>
///   <D:href>/principals/users/johndoe</D:href>
/// </D:principal>
/// ```
class PrincipalElement {
  final String? href;
  final bool all;
  final bool authenticated;
  final bool unauthenticated;
  final bool self;
  final List<String> properties;

  const PrincipalElement({
    this.href,
    this.all = false,
    this.authenticated = false,
    this.unauthenticated = false,
    this.self = false,
    this.properties = const [],
  });

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:principal>');

    if (href != null) {
      buffer.writeln('  <D:href>$href</D:href>');
    } else if (all) {
      buffer.writeln('  <D:all/>');
    } else if (authenticated) {
      buffer.writeln('  <D:authenticated/>');
    } else if (unauthenticated) {
      buffer.writeln('  <D:unauthenticated/>');
    } else if (self) {
      buffer.writeln('  <D:self/>');
    }

    for (final property in properties) {
      buffer.writeln('  <D:property>$property</D:property>');
    }

    buffer.write('</D:principal>');
    return buffer.toString();
  }
}
