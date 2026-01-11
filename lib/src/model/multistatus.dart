import 'package:xml/xml.dart';
import 'response.dart';

/// WebDAV Multistatus Response
///
/// The multistatus response element contains information about multiple
/// resources. It is used as the root element for responses to PROPFIND,
/// PROPPATCH, COPY, MOVE, LOCK, and other WebDAV methods that can operate
/// on multiple resources or return information about multiple resources.
///
/// According to RFC 4918, a multistatus response contains a sequence of
/// response elements, each providing information about a specific resource,
/// and an optional responsedescription element providing additional
/// information about the overall operation.
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <sequence>
///         <element ref="{DAV:}response" maxOccurs="unbounded"/>
///         <element ref="{DAV:}responsedescription" minOccurs="0"/>
///         <element ref="{DAV:}sync-token" minOccurs="0"/>
///       </sequence>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <?xml version="1.0" encoding="utf-8"?>
/// <D:multistatus xmlns:D="DAV:">
///   <D:response>
///     <D:href>/path/to/resource</D:href>
///     <D:propstat>
///       <D:prop>
///         <D:getcontentlength>1024</D:getcontentlength>
///       </D:prop>
///       <D:status>HTTP/1.1 200 OK</D:status>
///     </D:propstat>
///   </D:response>
///   <D:responsedescription>Success</D:responsedescription>
/// </D:multistatus>
/// ```
class Multistatus {
  final List<Response> responses;
  final String? responsedescription;

  const Multistatus({required this.responses, this.responsedescription});

  /// Parse multistatus from XML string
  static Multistatus fromXml(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);
    final multistatusElement = document.rootElement;

    if (multistatusElement.name.local != 'multistatus') {
      throw FormatException(
        'Expected multistatus element, got ${multistatusElement.name.local}',
      );
    }

    final responses = <Response>[];

    // Look for response elements with DAV: namespace or any namespace
    var responseElements = multistatusElement.findAllElements('response');
    if (responseElements.isEmpty) {
      responseElements = multistatusElement.findAllElements('D:response');
    }

    for (final responseElement in responseElements) {
      responses.add(Response.fromXmlElement(responseElement));
    }

    // Look for responsedescription element
    var responsedescriptionElement = multistatusElement
        .findAllElements('responsedescription')
        .firstOrNull;
    responsedescriptionElement ??= multistatusElement
        .findAllElements('D:responsedescription')
        .firstOrNull;
    final responsedescription = responsedescriptionElement?.innerText;

    return Multistatus(
      responses: responses,
      responsedescription: responsedescription,
    );
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.writeln('<D:multistatus xmlns:D="DAV:">');

    for (final response in responses) {
      buffer.writeln(
        response.toXml().split('\n').map((line) => '  $line').join('\n'),
      );
    }

    if (responsedescription != null) {
      buffer.writeln(
        '  <D:responsedescription>$responsedescription</D:responsedescription>',
      );
    }

    buffer.write('</D:multistatus>');
    return buffer.toString();
  }
}
