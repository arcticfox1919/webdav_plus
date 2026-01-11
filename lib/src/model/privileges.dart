/// WebDAV privilege and permission related classes
///
/// Contains classes representing various WebDAV privileges and permissions
/// as defined in RFC 3744 (WebDAV Access Control Protocol).

/// Represents a read privilege
class ReadPrivilege {
  const ReadPrivilege();

  String toXml() => '<D:read/>';
}

/// Represents a write privilege
class WritePrivilege {
  const WritePrivilege();

  String toXml() => '<D:write/>';
}

/// Represents a write-properties privilege
class WritePropertiesPrivilege {
  const WritePropertiesPrivilege();

  String toXml() => '<D:write-properties/>';
}

/// Represents a write-content privilege
class WriteContentPrivilege {
  const WriteContentPrivilege();

  String toXml() => '<D:write-content/>';
}

/// Represents an unlock privilege
class UnlockPrivilege {
  const UnlockPrivilege();

  String toXml() => '<D:unlock/>';
}

/// Represents a read-acl privilege
class ReadAclPrivilege {
  const ReadAclPrivilege();

  String toXml() => '<D:read-acl/>';
}

/// Represents a read-current-user-privilege-set privilege
class ReadCurrentUserPrivilegeSetPrivilege {
  const ReadCurrentUserPrivilegeSetPrivilege();

  String toXml() => '<D:read-current-user-privilege-set/>';
}

/// Represents a write-acl privilege
class WriteAclPrivilege {
  const WriteAclPrivilege();

  String toXml() => '<D:write-acl/>';
}

/// Represents a bind privilege
class BindPrivilege {
  const BindPrivilege();

  String toXml() => '<D:bind/>';
}

/// Represents an unbind privilege
class UnbindPrivilege {
  const UnbindPrivilege();

  String toXml() => '<D:unbind/>';
}

/// Represents an all privilege (aggregate of all other privileges)
class AllPrivilege {
  const AllPrivilege();

  String toXml() => '<D:all/>';
}

/// Represents an authenticated principal
class AuthenticatedPrincipal {
  const AuthenticatedPrincipal();

  String toXml() => '<D:authenticated/>';
}

/// Represents an unauthenticated principal
class UnauthenticatedPrincipal {
  const UnauthenticatedPrincipal();

  String toXml() => '<D:unauthenticated/>';
}

/// Represents a self principal
class SelfPrincipal {
  const SelfPrincipal();

  String toXml() => '<D:self/>';
}

/// Represents a protected ACE marker
class ProtectedAce {
  const ProtectedAce();

  String toXml() => '<D:protected/>';
}

/// Represents an inherited ACE marker
class InheritedAce {
  final String href;

  const InheritedAce({required this.href});

  String toXml() {
    return '<D:inherited><D:href>$href</D:href></D:inherited>';
  }
}
