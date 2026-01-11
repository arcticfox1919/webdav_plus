/// WebDAV Access Control Element (ACE) representing a single access control entry.
///
/// An ACE defines permissions for a specific principal (user or group) on a WebDAV resource.
/// This follows the WebDAV Access Control Protocol (RFC 3744) specifications.
class DavAce {
  /// The principal (user, group, or special principal like 'all') this ACE applies to
  final String principal;

  /// Whether this ACE grants or denies access
  final bool grant;

  /// Set of privileges (permissions) this ACE controls
  final Set<String> privileges;

  /// Whether this ACE is inherited from a parent resource
  final bool inherited;

  /// Whether this ACE is protected (cannot be modified)
  final bool protected;

  const DavAce({
    required this.principal,
    required this.grant,
    required this.privileges,
    this.inherited = false,
    this.protected = false,
  });

  /// Check if this ACE grants a specific privilege
  bool hasPrivilege(String privilege) {
    return privileges.contains(privilege);
  }

  /// Check if this ACE is a deny ACE
  bool get isDeny => !grant;

  /// Check if this ACE is a grant ACE
  bool get isGrant => grant;

  @override
  String toString() {
    String type = grant ? 'GRANT' : 'DENY';
    return 'DavAce{principal: $principal, type: $type, privileges: $privileges, '
        'inherited: $inherited, protected: $protected}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DavAce &&
        other.principal == principal &&
        other.grant == grant &&
        other.privileges.length == privileges.length &&
        other.privileges.containsAll(privileges) &&
        other.inherited == inherited &&
        other.protected == protected;
  }

  @override
  int get hashCode {
    return Object.hash(
        principal, grant, privileges.hashCode, inherited, protected);
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'principal': principal,
      'grant': grant,
      'privileges': privileges.toList(),
      'inherited': inherited,
      'protected': protected,
    };
  }

  /// Create from JSON representation
  factory DavAce.fromJson(Map<String, dynamic> json) {
    return DavAce(
      principal: json['principal'],
      grant: json['grant'],
      privileges: Set<String>.from(json['privileges'] ?? []),
      inherited: json['inherited'] ?? false,
      protected: json['protected'] ?? false,
    );
  }

  /// Create a copy of this ACE with updated properties
  DavAce copyWith({
    String? principal,
    bool? grant,
    Set<String>? privileges,
    bool? inherited,
    bool? protected,
  }) {
    return DavAce(
      principal: principal ?? this.principal,
      grant: grant ?? this.grant,
      privileges: privileges ?? this.privileges,
      inherited: inherited ?? this.inherited,
      protected: protected ?? this.protected,
    );
  }
}
