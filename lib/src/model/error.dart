import 'package:xml/xml.dart';

/// WebDAV Error Element
///
/// The error element provides detailed error information in WebDAV responses.
/// It contains one or more error condition elements that specify the exact
/// nature of the error that occurred during the processing of a request.
///
/// According to RFC 4918, the error element can contain any number of
/// XML elements that describe specific error conditions. These conditions
/// help clients understand why a request failed and potentially take
/// corrective action.
///
/// Common error conditions include:
/// - lock-token-submitted: A lock token was submitted but the resource is not locked
/// - no-conflicting-lock: Used with unsuccessful LOCK requests
/// - no-external-entities: External entities are not supported
/// - preserved-live-properties: Live properties must be preserved
/// - propfind-finite-depth: PROPFIND with infinite depth is not allowed
/// - cannot-modify-protected-property: Protected properties cannot be modified
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
/// <D:error>
///   <D:lock-token-submitted>
///     <D:href>/locked-resource</D:href>
///   </D:lock-token-submitted>
/// </D:error>
/// ```
class Error {
  final List<String> conditions;
  final String? description;

  const Error({required this.conditions, this.description});

  /// Parse error from XML element
  static Error fromXmlElement(XmlElement errorElement) {
    final conditions = <String>[];
    String? description;

    for (final child in errorElement.children.whereType<XmlElement>()) {
      conditions.add(child.name.local);
      // Try to extract description text if present
      if (child.innerText.isNotEmpty) {
        description ??= child.innerText;
      }
    }

    return Error(conditions: conditions, description: description);
  }

  /// Parse multiple errors from XML response body
  static List<Error> parseErrors(String xmlResponse) {
    try {
      final document = XmlDocument.parse(xmlResponse);
      final errorElements = document.findAllElements('error');

      return errorElements
          .map((element) => Error.fromXmlElement(element))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Get the first/primary condition
  String? get condition => conditions.isNotEmpty ? conditions.first : null;

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('      <D:error>');

    for (final condition in conditions) {
      buffer.writeln('        <D:$condition/>');
    }

    buffer.write('      </D:error>');
    return buffer.toString();
  }

  /// Convert to template data for mustache rendering
  Map<String, dynamic> toTemplateData() {
    return {'conditions': conditions};
  }
}
