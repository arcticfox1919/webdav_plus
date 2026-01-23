/// Represents lock-related elements for WebDAV locking support
library;

/// Represents an activelock element from a lockdiscovery response
///
/// Contains information about an active lock on a resource.
class Activelock {
  final String lockscope; // 'exclusive' or 'shared'
  final String locktype; // typically 'write'
  final String depth;
  final String? owner;
  final String? timeout;
  final String? locktoken;

  const Activelock({
    required this.lockscope,
    required this.locktype,
    required this.depth,
    this.owner,
    this.timeout,
    this.locktoken,
  });

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('  <D:activelock>');
    buffer.writeln('    <D:lockscope>');
    buffer.writeln('      <D:$lockscope/>');
    buffer.writeln('    </D:lockscope>');
    buffer.writeln('    <D:locktype>');
    buffer.writeln('      <D:$locktype/>');
    buffer.writeln('    </D:locktype>');
    buffer.writeln('    <D:depth>$depth</D:depth>');

    if (owner != null) {
      buffer.writeln('    <D:owner>$owner</D:owner>');
    }

    if (timeout != null) {
      buffer.writeln('    <D:timeout>$timeout</D:timeout>');
    }

    if (locktoken != null) {
      buffer.writeln('    <D:locktoken>');
      buffer.writeln('      <D:href>$locktoken</D:href>');
      buffer.writeln('    </D:locktoken>');
    }

    buffer.write('  </D:activelock>');
    return buffer.toString();
  }
}

/// Represents a lockdiscovery property
///
/// Contains information about locks currently active on a resource.
class Lockdiscovery {
  final List<Activelock> activelocks;

  const Lockdiscovery({this.activelocks = const []});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:lockdiscovery>');

    for (final activelock in activelocks) {
      buffer.writeln(activelock.toXml());
    }

    buffer.write('</D:lockdiscovery>');
    return buffer.toString();
  }
}

/// Represents a lockentry element
///
/// Describes a type of lock that can be applied to a resource.
class Lockentry {
  final String lockscope; // 'exclusive' or 'shared'
  final String locktype; // typically 'write'

  const Lockentry({required this.lockscope, required this.locktype});

  String toXml() {
    return '''  <D:lockentry>
    <D:lockscope>
      <D:$lockscope/>
    </D:lockscope>
    <D:locktype>
      <D:$locktype/>
    </D:locktype>
  </D:lockentry>''';
  }
}

/// Represents a supportedlock property
///
/// Lists the types of locks supported by a resource.
class Supportedlock {
  final List<Lockentry> lockentries;

  const Supportedlock({this.lockentries = const []});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:supportedlock>');

    for (final lockentry in lockentries) {
      buffer.writeln(lockentry.toXml());
    }

    buffer.write('</D:supportedlock>');
    return buffer.toString();
  }
}
