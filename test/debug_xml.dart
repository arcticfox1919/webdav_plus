import 'package:xml/xml.dart';
import 'package:webdav_plus/src/model/multistatus.dart';

void main() {
  const multistatusXml = '''<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/test/file.txt</D:href>
    <D:propstat>
      <D:prop>
        <D:getcontentlength>1024</D:getcontentlength>
        <D:getcontenttype>text/plain</D:getcontenttype>
        <D:getlastmodified>Mon, 12 Jan 1998 09:25:56 GMT</D:getlastmodified>
      </D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
</D:multistatus>''';

  print('Parsing XML...');
  final document = XmlDocument.parse(multistatusXml);
  final root = document.rootElement;

  print('Root element name: ${root.name}');
  print('Root element children count: ${root.children.length}');

  // Test findAllElements vs findElements
  final responseElementsAll = root.findAllElements('response');
  final responseElementsFind = root.findElements('response');

  print('findAllElements("response") count: ${responseElementsAll.length}');
  print('findElements("response") count: ${responseElementsFind.length}');

  if (responseElementsAll.isNotEmpty) {
    print('First response element name: ${responseElementsAll.first.name}');
    print(
      'First response element namespace: ${responseElementsAll.first.name.namespaceUri}',
    );
  }

  // Try with qualified name
  final responseElementsQualified = root.findAllElements('D:response');
  print(
    'findAllElements("D:response") count: ${responseElementsQualified.length}',
  );

  try {
    final multistatus = Multistatus.fromXml(multistatusXml);
    print('Multistatus responses count: ${multistatus.responses.length}');
  } catch (e) {
    print('Error parsing: $e');
  }
}
