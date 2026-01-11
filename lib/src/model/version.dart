/// WebDAV versioning protocol support (RFC 3253)
///
/// Contains classes for WebDAV versioning operations including
/// version control, check-in/check-out, and baseline management.

/// Represents a version-control request element
///
/// Used to put a resource under version control.
///
/// Example XML:
/// ```xml
/// <D:version-control xmlns:D="DAV:">
///   <D:version>
///     <D:href>/versions/1.0</D:href>
///   </D:version>
/// </D:version-control>
/// ```
class VersionControl {
  final String? version;

  const VersionControl({this.version});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:version-control xmlns:D="DAV:">');
    if (version != null) {
      buffer.writeln('  <D:version>');
      buffer.writeln('    <D:href>$version</D:href>');
      buffer.writeln('  </D:version>');
    }
    buffer.write('</D:version-control>');
    return buffer.toString();
  }
}

/// Represents a checkout request element
///
/// Used to checkout a resource for editing.
///
/// Example XML:
/// ```xml
/// <D:checkout xmlns:D="DAV:">
///   <D:activity-set>
///     <D:href>/activities/fix-123</D:href>
///   </D:activity-set>
/// </D:checkout>
/// ```
class Checkout {
  final String? activitySet;

  const Checkout({this.activitySet});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:checkout xmlns:D="DAV:">');
    if (activitySet != null) {
      buffer.writeln('  <D:activity-set>');
      buffer.writeln('    <D:href>$activitySet</D:href>');
      buffer.writeln('  </D:activity-set>');
    }
    buffer.write('</D:checkout>');
    return buffer.toString();
  }
}

/// Represents a checkin request element
///
/// Used to checkin a checked-out resource.
///
/// Example XML:
/// ```xml
/// <D:checkin xmlns:D="DAV:">
///   <D:keep-checked-out/>
/// </D:checkin>
/// ```
class Checkin {
  final bool keepCheckedOut;

  const Checkin({this.keepCheckedOut = false});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:checkin xmlns:D="DAV:">');
    if (keepCheckedOut) {
      buffer.writeln('  <D:keep-checked-out/>');
    }
    buffer.write('</D:checkin>');
    return buffer.toString();
  }
}

/// Represents an uncheckout request element
///
/// Used to cancel a checkout operation.
///
/// Example XML:
/// ```xml
/// <D:uncheckout xmlns:D="DAV:"/>
/// ```
class Uncheckout {
  const Uncheckout();

  String toXml() {
    return '<D:uncheckout xmlns:D="DAV:"/>';
  }
}

/// Represents a baseline-control request element
///
/// Used to put a collection under baseline control.
///
/// Example XML:
/// ```xml
/// <D:baseline-control xmlns:D="DAV:">
///   <D:baseline>
///     <D:href>/baselines/1.0</D:href>
///   </D:baseline>
/// </D:baseline-control>
/// ```
class BaselineControl {
  final String? baseline;

  const BaselineControl({this.baseline});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:baseline-control xmlns:D="DAV:">');
    if (baseline != null) {
      buffer.writeln('  <D:baseline>');
      buffer.writeln('    <D:href>$baseline</D:href>');
      buffer.writeln('  </D:baseline>');
    }
    buffer.write('</D:baseline-control>');
    return buffer.toString();
  }
}

/// Represents a mkbaseline request element
///
/// Used to create a new baseline.
///
/// Example XML:
/// ```xml
/// <D:mkbaseline xmlns:D="DAV:"/>
/// ```
class MkBaseline {
  const MkBaseline();

  String toXml() {
    return '<D:mkbaseline xmlns:D="DAV:"/>';
  }
}

/// Represents version information
class VersionInfo {
  final String href;
  final String? comment;
  final String? creatorDisplayName;
  final DateTime? creationDate;

  const VersionInfo({
    required this.href,
    this.comment,
    this.creatorDisplayName,
    this.creationDate,
  });
}

/// Represents baseline information
class BaselineInfo {
  final String href;
  final String? comment;
  final DateTime? creationDate;
  final List<String> versionSet;

  const BaselineInfo({
    required this.href,
    this.comment,
    this.creationDate,
    this.versionSet = const [],
  });
}

/// Represents an activity for grouping related changes
class Activity {
  final String href;
  final String? displayName;
  final String? comment;

  const Activity({required this.href, this.displayName, this.comment});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:activity xmlns:D="DAV:">');
    buffer.writeln('  <D:href>$href</D:href>');
    if (displayName != null) {
      buffer.writeln('  <D:displayname>$displayName</D:displayname>');
    }
    if (comment != null) {
      buffer.writeln('  <D:comment>$comment</D:comment>');
    }
    buffer.write('</D:activity>');
    return buffer.toString();
  }
}

/// Represents a version-tree report request element
///
/// Used to retrieve version tree information for a version-controlled resource.
///
/// Example XML:
/// ```xml
/// <D:version-tree xmlns:D="DAV:">
///   <D:prop>
///     <D:version-name/>
///     <D:creator-displayname/>
///     <D:successor-set/>
///     <D:predecessor-set/>
///   </D:prop>
/// </D:version-tree>
/// ```
class VersionTree {
  final List<String> properties;

  const VersionTree({this.properties = const []});

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<D:version-tree xmlns:D="DAV:">');
    if (properties.isNotEmpty) {
      buffer.writeln('  <D:prop>');
      for (final prop in properties) {
        buffer.writeln('    <D:$prop/>');
      }
      buffer.writeln('  </D:prop>');
    }
    buffer.write('</D:version-tree>');
    return buffer.toString();
  }
}
