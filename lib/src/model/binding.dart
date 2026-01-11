/// WebDAV binding protocol support
///
/// Contains classes for WebDAV binding operations (BIND, UNBIND)
/// as defined in RFC 5842.

/// Represents a BIND request
///
/// Used to create a new binding (alternate path) to an existing resource.
///
/// Example XML:
/// ```xml
/// <D:bind xmlns:D="DAV:">
///   <D:segment>newname.txt</D:segment>
///   <D:href>/path/to/existing/resource.txt</D:href>
/// </D:bind>
/// ```
class Bind {
  final String segment;
  final String href;

  const Bind({required this.segment, required this.href});

  String toXml() {
    return '''<D:bind xmlns:D="DAV:">
  <D:segment>$segment</D:segment>
  <D:href>$href</D:href>
</D:bind>''';
  }
}

/// Represents an UNBIND request
///
/// Used to remove a binding (alternate path) to a resource.
///
/// Example XML:
/// ```xml
/// <D:unbind xmlns:D="DAV:">
///   <D:segment>oldname.txt</D:segment>
/// </D:unbind>
/// ```
class UnBind {
  final String segment;

  const UnBind({required this.segment});

  String toXml() {
    return '''<D:unbind xmlns:D="DAV:">
  <D:segment>$segment</D:segment>
</D:unbind>''';
  }
}

/// Represents a segment element
class Segment {
  final String value;

  const Segment({required this.value});

  String toXml() {
    return '<D:segment>$value</D:segment>';
  }
}
