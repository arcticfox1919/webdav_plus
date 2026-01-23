import 'package:xml/xml.dart';

/// WebDAV PROPFIND Request Element
///
/// The PROPFIND method and its request body are used to retrieve properties
/// defined on resources identified by the Request-URI. The PROPFIND request
/// may contain one of three types of requests:
///
/// 1. allprop: Returns all properties defined on the resource
/// 2. propname: Returns only the names of properties defined on the resource
/// 3. prop: Returns specific properties identified in the request
///
/// According to RFC 4918, exactly one of these request types must be specified.
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <choice>
///         <element ref="{DAV:}allprop"/>
///         <element ref="{DAV:}propname"/>
///         <element ref="{DAV:}prop"/>
///       </choice>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <?xml version="1.0" encoding="utf-8"?>
/// <D:propfind xmlns:D="DAV:">
///   <D:allprop/>
/// </D:propfind>
/// ```
class Propfind {
  final Allprop? allprop;
  final Propname? propname;
  final Prop? prop;

  const Propfind({this.allprop, this.propname, this.prop});

  /// Generate XML representation
  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.writeln('<D:propfind xmlns:D="DAV:">');

    if (allprop != null) {
      buffer.writeln('  <D:allprop/>');
    } else if (propname != null) {
      buffer.writeln('  <D:propname/>');
    } else if (prop != null) {
      buffer.writeln(
        prop!.toXml().split('\n').map((line) => '  $line').join('\n'),
      );
    }

    buffer.write('</D:propfind>');
    return buffer.toString();
  }
}

/// PROPFIND Allprop Element
///
/// The allprop element specifies that all properties defined on the resource
/// should be returned. When used, the server will return all live and dead
/// properties defined on the resource.
///
/// According to RFC 4918, this is an empty element that instructs the server
/// to return all properties that the requesting principal has permission to read.
///
/// Example XML:
/// ```xml
/// <D:allprop/>
/// ```
class Allprop {
  const Allprop();
}

/// PROPFIND Propname Element
///
/// The propname element specifies that only the names of properties defined
/// on the resource should be returned, without their values. This is useful
/// for discovering what properties exist on a resource.
///
/// According to RFC 4918, this is an empty element that instructs the server
/// to return only the property names (not values) for all properties that
/// the requesting principal has permission to read.
///
/// Example XML:
/// ```xml
/// <D:propname/>
/// ```
class Propname {
  const Propname();
}

/// PROPFIND Prop Element
///
/// The prop element contains a list of specific property names that should
/// be retrieved. Only the properties listed within this element will be
/// returned by the server.
///
/// According to RFC 4918, the prop element contains empty XML elements
/// whose names correspond to the property names being requested. The server
/// will return values for these properties if they exist and the requesting
/// principal has permission to read them.
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
/// <D:prop>
///   <D:getcontentlength/>
///   <D:getlastmodified/>
///   <D:resourcetype/>
/// </D:prop>
/// ```
class Prop {
  final Set<String> properties;
  final Map<String, String> customProperties;

  const Prop({
    this.properties = const <String>{},
    this.customProperties = const {},
  });

  /// Parse prop from XML element
  static Prop fromXmlElement(XmlElement propElement) {
    final properties = <String>{};
    final customProperties = <String, String>{};

    for (final child in propElement.children.whereType<XmlElement>()) {
      final localName = child.name.local;
      final namespace = child.name.namespaceUri;
      final value = child.innerText.trim();

      if (namespace == 'DAV:' || namespace == null) {
        // Standard WebDAV property
        properties.add(localName);
        if (localName == 'resourcetype') {
          final hasCollection = child
              .descendants
              .whereType<XmlElement>()
              .any((node) => node.name.local == 'collection');
          if (hasCollection) {
            customProperties[localName] = 'collection';
          }
        } else if (value.isNotEmpty) {
          customProperties[localName] = value;
        }
      } else {
        // Custom property with namespace
        customProperties[localName] = value;
      }
    }

    return Prop(properties: properties, customProperties: customProperties);
  }

  /// Generate XML representation
  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:prop>');

    // Add standard properties
    for (final prop in properties) {
      buffer.writeln('  <D:$prop/>');
    }

    // Add custom properties with values
    for (final entry in customProperties.entries) {
      if (entry.value.isNotEmpty) {
        buffer.writeln(
          '  <S:${entry.key} xmlns:S="SAR:">${entry.value}</S:${entry.key}>',
        );
      } else {
        buffer.writeln('  <S:${entry.key} xmlns:S="SAR:"/>');
      }
    }

    buffer.write('</D:prop>');
    return buffer.toString();
  }
}
