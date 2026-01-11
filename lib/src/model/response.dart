import 'package:xml/xml.dart';
import 'propstat.dart';
import 'error.dart';

/// WebDAV Response Element
///
/// The response element represents information about a single resource
/// within a multistatus response. Each response contains the resource's
/// URI and either a status code (for simple responses) or one or more
/// propstat elements (for property-related responses).
///
/// According to RFC 4918, a response element must contain:
/// - One or more href elements identifying the resource
/// - Either a status element OR one or more propstat elements
/// - Optional error, responsedescription, and location elements
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <sequence>
///         <element ref="{DAV:}href" maxOccurs="unbounded"/>
///         <choice>
///           <sequence>
///             <element ref="{DAV:}status"/>
///           </sequence>
///           <element ref="{DAV:}propstat" maxOccurs="unbounded"/>
///         </choice>
///         <element ref="{DAV:}error" minOccurs="0"/>
///         <element ref="{DAV:}responsedescription" minOccurs="0"/>
///         <element ref="{DAV:}location" minOccurs="0"/>
///       </sequence>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <D:response>
///   <D:href>/path/to/resource</D:href>
///   <D:propstat>
///     <D:prop>
///       <D:getcontentlength>1024</D:getcontentlength>
///     </D:prop>
///     <D:status>HTTP/1.1 200 OK</D:status>
///   </D:propstat>
/// </D:response>
/// ```
class Response {
  final String href;
  final List<Propstat> propstats;
  final String? status;
  final Error? error;
  final String? responsedescription;
  final String? location;

  const Response({
    required this.href,
    this.propstats = const [],
    this.status,
    this.error,
    this.responsedescription,
    this.location,
  });

  /// Parse response from XML element
  static Response fromXmlElement(XmlElement responseElement) {
    // Try both qualified and unqualified names
    var hrefElement = responseElement.findAllElements('href').firstOrNull;
    if (hrefElement == null) {
      hrefElement = responseElement.findAllElements('D:href').firstOrNull;
    }
    if (hrefElement == null) {
      throw FormatException('Response element missing href');
    }
    final href = hrefElement.innerText;

    final propstats = <Propstat>[];
    var propstatElements = responseElement.findAllElements('propstat');
    if (propstatElements.isEmpty) {
      propstatElements = responseElement.findAllElements('D:propstat');
    }
    for (final propstatElement in propstatElements) {
      propstats.add(Propstat.fromXmlElement(propstatElement));
    }

    var statusElement = responseElement.findAllElements('status').firstOrNull;
    if (statusElement == null) {
      statusElement = responseElement.findAllElements('D:status').firstOrNull;
    }
    final status = statusElement?.innerText;

    var errorElement = responseElement.findAllElements('error').firstOrNull;
    if (errorElement == null) {
      errorElement = responseElement.findAllElements('D:error').firstOrNull;
    }
    final error = errorElement != null
        ? Error.fromXmlElement(errorElement)
        : null;

    var responsedescriptionElement = responseElement
        .findAllElements('responsedescription')
        .firstOrNull;
    if (responsedescriptionElement == null) {
      responsedescriptionElement = responseElement
          .findAllElements('D:responsedescription')
          .firstOrNull;
    }
    final responsedescription = responsedescriptionElement?.innerText;

    var locationElement = responseElement
        .findAllElements('location')
        .firstOrNull;
    if (locationElement == null) {
      locationElement = responseElement
          .findAllElements('D:location')
          .firstOrNull;
    }
    final location =
        locationElement?.findAllElements('href').firstOrNull?.innerText ??
        locationElement?.findAllElements('D:href').firstOrNull?.innerText;

    return Response(
      href: href,
      propstats: propstats,
      status: status,
      error: error,
      responsedescription: responsedescription,
      location: location,
    );
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('  <D:response>');
    buffer.writeln('    <D:href>$href</D:href>');

    if (status != null) {
      buffer.writeln('    <D:status>$status</D:status>');
    } else {
      for (final propstat in propstats) {
        buffer.writeln(propstat.toXml());
      }
    }

    if (error != null) {
      buffer.writeln(error!.toXml());
    }

    if (responsedescription != null) {
      buffer.writeln(
        '    <D:responsedescription>$responsedescription</D:responsedescription>',
      );
    }

    if (location != null) {
      buffer.writeln('    <D:location>');
      buffer.writeln('      <D:href>$location</D:href>');
      buffer.writeln('    </D:location>');
    }

    buffer.write('  </D:response>');
    return buffer.toString();
  }
}
