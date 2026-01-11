/// WebDAV SEARCH Request Element
///
/// The searchrequest element is used with the WebDAV SEARCH method to
/// perform searches on collections. It supports various query languages
/// including DAV basic search and SQL-like queries.
///
/// According to draft specifications, the SEARCH method allows clients
/// to submit queries against collections to find resources that match
/// specific criteria. The query language determines the format and
/// capabilities of the search.
///
/// Supported query languages:
/// - davbasic: DAV basic search with select, from, and where clauses
/// - sql: SQL-like queries (server-dependent implementation)
/// - Other custom query languages may be supported by specific servers
///
/// XML Schema fragment:
/// ```xml
/// <complexType>
///   <complexContent>
///     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
///       <choice>
///         <element ref="{DAV:}basicsearch"/>
///         <element ref="{DAV:}sql"/>
///         <any namespace="##other"/>
///       </choice>
///     </restriction>
///   </complexContent>
/// </complexType>
/// ```
///
/// Example XML:
/// ```xml
/// <?xml version="1.0" encoding="utf-8"?>
/// <D:searchrequest xmlns:D="DAV:">
///   <D:basicsearch>
///     <D:select>
///       <D:prop>
///         <D:displayname/>
///         <D:getcontenttype/>
///       </D:prop>
///     </D:select>
///     <D:from>
///       <D:scope>
///         <D:href>/collection</D:href>
///         <D:depth>infinity</D:depth>
///       </D:scope>
///     </D:from>
///     <D:where>
///       <D:contains>searchterm</D:contains>
///     </D:where>
///   </D:basicsearch>
/// </D:searchrequest>
/// ```
class SearchRequest {
  final String query;
  final String language;

  const SearchRequest({required this.query, required this.language});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.writeln('<D:searchrequest xmlns:D="DAV:">');

    if (language == 'davbasic') {
      buffer.writeln('  <D:basicsearch>');
      buffer.writeln('    <D:select>');
      buffer.writeln('      <D:allprop/>');
      buffer.writeln('    </D:select>');
      buffer.writeln('    <D:from>');
      buffer.writeln('      <D:scope>');
      buffer.writeln('        <D:href>/</D:href>');
      buffer.writeln('        <D:depth>infinity</D:depth>');
      buffer.writeln('      </D:scope>');
      buffer.writeln('    </D:from>');
      buffer.writeln('    <D:where>');
      buffer.writeln('      <D:contains>$query</D:contains>');
      buffer.writeln('    </D:where>');
      buffer.writeln('  </D:basicsearch>');
    } else {
      // For SQL or other languages
      buffer.writeln('  <D:sql>$query</D:sql>');
    }

    buffer.write('</D:searchrequest>');
    return buffer.toString();
  }
}
