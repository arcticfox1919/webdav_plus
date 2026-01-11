import 'package:xml/xml.dart';
import 'propfind.dart'; // for Prop class
import 'error.dart';

/// Represents a propstat element
///
/// Contains property information along with status for those properties.
/// Used in multistatus responses to group properties by their status.
///
/// Example XML:
/// ```xml
/// <D:propstat>
///   <D:prop>
///     <D:getcontentlength>1024</D:getcontentlength>
///     <D:getlastmodified>Mon, 12 Jan 1998 09:25:56 GMT</D:getlastmodified>
///   </D:prop>
///   <D:status>HTTP/1.1 200 OK</D:status>
/// </D:propstat>
/// ```
class Propstat {
  final Prop prop;
  final String status;
  final Error? error;
  final String? responsedescription;

  const Propstat({
    required this.prop,
    required this.status,
    this.error,
    this.responsedescription,
  });

  /// Parse propstat from XML element
  static Propstat fromXmlElement(XmlElement propstatElement) {
    var propElement = propstatElement.findAllElements('prop').firstOrNull;
    if (propElement == null) {
      propElement = propstatElement.findAllElements('D:prop').firstOrNull;
    }
    if (propElement == null) {
      throw FormatException('Propstat element missing prop');
    }
    final prop = Prop.fromXmlElement(propElement);

    var statusElement = propstatElement.findAllElements('status').firstOrNull;
    if (statusElement == null) {
      statusElement = propstatElement.findAllElements('D:status').firstOrNull;
    }
    if (statusElement == null) {
      throw FormatException('Propstat element missing status');
    }
    final status = statusElement.innerText;

    var errorElement = propstatElement.findAllElements('error').firstOrNull;
    if (errorElement == null) {
      errorElement = propstatElement.findAllElements('D:error').firstOrNull;
    }
    final error = errorElement != null
        ? Error.fromXmlElement(errorElement)
        : null;

    var responsedescriptionElement = propstatElement
        .findAllElements('responsedescription')
        .firstOrNull;
    if (responsedescriptionElement == null) {
      responsedescriptionElement = propstatElement
          .findAllElements('D:responsedescription')
          .firstOrNull;
    }
    final responsedescription = responsedescriptionElement?.innerText;

    return Propstat(
      prop: prop,
      status: status,
      error: error,
      responsedescription: responsedescription,
    );
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('    <D:propstat>');
    buffer.writeln(
      prop.toXml().split('\n').map((line) => '  $line').join('\n'),
    );
    buffer.writeln('      <D:status>$status</D:status>');

    if (error != null) {
      buffer.writeln(
        error!.toXml().split('\n').map((line) => '  $line').join('\n'),
      );
    }

    if (responsedescription != null) {
      buffer.writeln(
        '      <D:responsedescription>$responsedescription</D:responsedescription>',
      );
    }

    buffer.write('    </D:propstat>');
    return buffer.toString();
  }
}
