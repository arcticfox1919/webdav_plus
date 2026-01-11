import 'package:xml/xml.dart';
import 'propfind.dart'; // for Prop class
import 'error.dart';
import '../parser/xml_helpers.dart' as xh;

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
    // Use xml_helpers to find elements by local name (ignores namespace prefix)
    final propElement = xh.firstDescendantByLocalName(propstatElement, 'prop');
    if (propElement == null) {
      throw FormatException('Propstat element missing prop');
    }
    final prop = Prop.fromXmlElement(propElement);

    final statusElement = xh.firstDescendantByLocalName(
      propstatElement,
      'status',
    );
    if (statusElement == null) {
      throw FormatException('Propstat element missing status');
    }
    final status = statusElement.innerText;

    final errorElement = xh.firstDescendantByLocalName(
      propstatElement,
      'error',
    );
    final error = errorElement != null
        ? Error.fromXmlElement(errorElement)
        : null;

    final responsedescriptionElement = xh.firstDescendantByLocalName(
      propstatElement,
      'responsedescription',
    );
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
