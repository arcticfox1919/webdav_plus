import 'propfind.dart'; // for Prop class

/// WebDAV PROPPATCH Property Update Request
///
/// The propertyupdate element is the root element of a PROPPATCH request
/// body. It contains instructions to modify properties on a WebDAV resource
/// through set and remove operations.
///
/// According to RFC 4918, a PROPPATCH request can contain multiple set
/// and remove operations that are processed atomically - either all
/// succeed or all fail. This ensures consistency when modifying multiple
/// properties simultaneously.
///
/// The propertyupdate element can contain:
/// - set elements: to create or modify property values
/// - remove elements: to delete properties
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <choice maxOccurs="unbounded">
///         <element ref="{DAV:}set"/>
///         <element ref="{DAV:}remove"/>
///       </choice>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <?xml version="1.0" encoding="utf-8"?>
/// <D:propertyupdate xmlns:D="DAV:">
///   <D:set>
///     <D:prop>
///       <D:displayname>New Name</D:displayname>
///     </D:prop>
///   </D:set>
/// </D:propertyupdate>
/// ```
class Propertyupdate {
  final SetElement? set;
  final Remove? remove;

  const Propertyupdate({this.set, this.remove});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.writeln('<D:propertyupdate xmlns:D="DAV:">');

    if (set != null) {
      buffer.writeln(set!.toXml());
    }
    if (remove != null) {
      buffer.writeln(remove!.toXml());
    }

    buffer.write('</D:propertyupdate>');
    return buffer.toString();
  }
}

/// PROPPATCH Set Element
///
/// The set element instructs the server to create or modify the properties
/// specified within its prop child element. If a property already exists,
/// its value is replaced. If it doesn't exist, it is created.
///
/// According to RFC 4918, the set element contains exactly one prop element
/// that specifies the properties and their new values.
///
/// Example XML:
/// ```xml
/// <D:set>
///   <D:prop>
///     <D:displayname>New Document Name</D:displayname>
///     <Z:author xmlns:Z="http://example.com/">John Doe</Z:author>
///   </D:prop>
/// </D:set>
/// ```
class SetElement {
  final Prop prop;

  const SetElement({required this.prop});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('  <D:set>');
    buffer.writeln(
      prop.toXml().split('\n').map((line) => '  $line').join('\n'),
    );
    buffer.write('  </D:set>');
    return buffer.toString();
  }
}

/// PROPPATCH Remove Element
///
/// The remove element instructs the server to delete the properties
/// specified within its prop child element. The property names are
/// listed without values since only the property removal is requested.
///
/// According to RFC 4918, the remove element contains exactly one prop
/// element that lists the properties to be deleted. If a property
/// doesn't exist, the server should not report an error.
///
/// Example XML:
/// ```xml
/// <D:remove>
///   <D:prop>
///     <D:author/>
///     <Z:customfield xmlns:Z="http://example.com/"/>
///   </D:prop>
/// </D:remove>
/// ```
class Remove {
  final Prop prop;

  const Remove({required this.prop});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('  <D:remove>');
    buffer.writeln(
      prop.toXml().split('\n').map((line) => '  $line').join('\n'),
    );
    buffer.write('  </D:remove>');
    return buffer.toString();
  }
}
