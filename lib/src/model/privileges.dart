/// WebDAV privilege and permission related classes
///
/// Contains classes representing various WebDAV privileges and permissions
/// as defined in RFC 3744 (WebDAV Access Control Protocol).

/// Represents a read privilege
class Read {
  const Read();

  String toXml() => '<D:read/>';
}

/// Represents a write privilege
class Write {
  const Write();

  String toXml() => '<D:write/>';
}

/// Represents a write-properties privilege
class WriteProperties {
  const WriteProperties();

  String toXml() => '<D:write-properties/>';
}

/// Represents a write-content privilege
class WriteContent {
  const WriteContent();

  String toXml() => '<D:write-content/>';
}

/// Represents an unlock privilege
class Unlock {
  const Unlock();

  String toXml() => '<D:unlock/>';
}

/// Represents a read-acl privilege
class ReadAcl {
  const ReadAcl();

  String toXml() => '<D:read-acl/>';
}

/// Represents a read-current-user-privilege-set privilege
class ReadCurrentUserPrivilegeSet {
  const ReadCurrentUserPrivilegeSet();

  String toXml() => '<D:read-current-user-privilege-set/>';
}

/// Represents a write-acl privilege
class WriteAcl {
  const WriteAcl();

  String toXml() => '<D:write-acl/>';
}

/// Represents a bind privilege
class Bind {
  const Bind();

  String toXml() => '<D:bind/>';
}

/// Represents an unbind privilege
class UnBind {
  const UnBind();

  String toXml() => '<D:unbind/>';
}

/// Represents an all privilege (aggregate of all other privileges)
class All {
  const All();

  String toXml() => '<D:all/>';
}

/// Represents an authenticated principal
class Authenticated {
  const Authenticated();

  String toXml() => '<D:authenticated/>';
}

/// Represents an unauthenticated principal
class Unauthenticated {
  const Unauthenticated();

  String toXml() => '<D:unauthenticated/>';
}

/// Represents a self principal
class Self {
  const Self();

  String toXml() => '<D:self/>';
}

/// Represents a protected ACE
class Protected {
  const Protected();

  String toXml() => '<D:protected/>';
}

/// Represents an inherited ACE
class Inherited {
  final String href;

  const Inherited({required this.href});

  String toXml() {
    return '<D:inherited><D:href>$href</D:href></D:inherited>';
  }
}
