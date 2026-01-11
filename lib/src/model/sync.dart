/// Represents a WebDAV synchronization collection request.
///
/// Used for WebDAV synchronization protocol to efficiently synchronize
/// collections by requesting only changes since a particular sync token.
///
/// Example XML:
/// ```xml
/// <D:sync-collection xmlns:D="DAV:">
///   <D:sync-token>http://example.com/ns/sync/1234</D:sync-token>
///   <D:sync-level>1</D:sync-level>
///   <D:prop>
///     <D:getetag/>
///     <D:getcontentlength/>
///   </D:prop>
/// </D:sync-collection>
/// ```
class SyncCollection {
  final String syncToken;
  final String syncLevel;
  final int? limit;
  final List<String> properties;

  const SyncCollection({
    required this.syncToken,
    required this.syncLevel,
    this.limit,
    this.properties = const [],
  });

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.writeln('<D:sync-collection xmlns:D="DAV:">');
    buffer.writeln('  <D:sync-token>$syncToken</D:sync-token>');
    buffer.writeln('  <D:sync-level>$syncLevel</D:sync-level>');

    if (limit != null) {
      buffer.writeln('  <D:limit>');
      buffer.writeln('    <D:nresults>$limit</D:nresults>');
      buffer.writeln('  </D:limit>');
    }

    if (properties.isNotEmpty) {
      buffer.writeln('  <D:prop>');
      for (final prop in properties) {
        buffer.writeln('    <D:$prop/>');
      }
      buffer.writeln('  </D:prop>');
    }

    buffer.write('</D:sync-collection>');
    return buffer.toString();
  }
}

/// Represents a sync token for WebDAV synchronization
class SyncToken {
  final String token;

  const SyncToken({required this.token});

  String toXml() {
    return '<D:sync-token>$token</D:sync-token>';
  }
}

/// Represents a sync level for WebDAV synchronization
class SyncLevel {
  final String level;

  const SyncLevel({required this.level});

  String toXml() {
    return '<D:sync-level>$level</D:sync-level>';
  }
}

/// Represents a limit element for constraining results
class Limit {
  final int nresults;

  const Limit({required this.nresults});

  String toXml() {
    return '''<D:limit>
  <D:nresults>$nresults</D:nresults>
</D:limit>''';
  }
}
