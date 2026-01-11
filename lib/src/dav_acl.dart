import 'dav_ace.dart';

/// WebDAV Access Control List (ACL) representing the complete access control configuration
/// for a WebDAV resource.
///
/// An ACL contains a list of Access Control Elements (ACEs) that define the permissions
/// for different principals on a WebDAV resource. This follows the WebDAV Access Control
/// Protocol (RFC 3744) specifications.
class DavAcl {
  /// List of Access Control Elements that make up this ACL
  final List<DavAce> aces;

  /// The resource URL this ACL applies to
  final String? resourceUrl;

  const DavAcl({
    required this.aces,
    this.resourceUrl,
  });

  /// Get all ACEs for a specific principal
  List<DavAce> getAcesForPrincipal(String principal) {
    return aces.where((ace) => ace.principal == principal).toList();
  }

  /// Get all grant ACEs
  List<DavAce> get grantAces {
    return aces.where((ace) => ace.isGrant).toList();
  }

  /// Get all deny ACEs
  List<DavAce> get denyAces {
    return aces.where((ace) => ace.isDeny).toList();
  }

  /// Get all inherited ACEs
  List<DavAce> get inheritedAces {
    return aces.where((ace) => ace.inherited).toList();
  }

  /// Get all protected ACEs
  List<DavAce> get protectedAces {
    return aces.where((ace) => ace.protected).toList();
  }

  /// Check if a principal has a specific privilege
  bool hasPrivilege(String principal, String privilege) {
    // Check for deny ACEs first (they take precedence)
    bool hasDeny = aces.any((ace) =>
        ace.principal == principal &&
        ace.isDeny &&
        ace.hasPrivilege(privilege));

    if (hasDeny) return false;

    // Check for grant ACEs
    bool hasGrant = aces.any((ace) =>
        ace.principal == principal &&
        ace.isGrant &&
        ace.hasPrivilege(privilege));

    return hasGrant;
  }

  /// Get all unique principals in this ACL
  Set<String> get principals {
    return aces.map((ace) => ace.principal).toSet();
  }

  /// Get all unique privileges in this ACL
  Set<String> get allPrivileges {
    return aces.expand((ace) => ace.privileges).toSet();
  }

  /// Check if the ACL is empty
  bool get isEmpty => aces.isEmpty;

  /// Check if the ACL is not empty
  bool get isNotEmpty => aces.isNotEmpty;

  /// Get the number of ACEs in this ACL
  int get length => aces.length;

  @override
  String toString() {
    return 'DavAcl{resourceUrl: $resourceUrl, aces: ${aces.length} entries}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DavAcl &&
        other.resourceUrl == resourceUrl &&
        other.aces.length == aces.length &&
        _listEquals(other.aces, aces);
  }

  /// Helper method to compare two lists of ACEs
  bool _listEquals(List<DavAce> list1, List<DavAce> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(resourceUrl, aces.hashCode);
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'resourceUrl': resourceUrl,
      'aces': aces.map((ace) => ace.toJson()).toList(),
    };
  }

  /// Create from JSON representation
  factory DavAcl.fromJson(Map<String, dynamic> json) {
    return DavAcl(
      resourceUrl: json['resourceUrl'],
      aces: (json['aces'] as List?)
              ?.map((aceJson) => DavAce.fromJson(aceJson))
              .toList() ??
          [],
    );
  }

  /// Create a copy of this ACL with updated properties
  DavAcl copyWith({
    List<DavAce>? aces,
    String? resourceUrl,
  }) {
    return DavAcl(
      aces: aces ?? this.aces,
      resourceUrl: resourceUrl ?? this.resourceUrl,
    );
  }

  /// Create a new ACL with an additional ACE
  DavAcl addAce(DavAce ace) {
    return DavAcl(
      aces: [...aces, ace],
      resourceUrl: resourceUrl,
    );
  }

  /// Create a new ACL with an ACE removed
  DavAcl removeAce(DavAce ace) {
    return DavAcl(
      aces: aces.where((a) => a != ace).toList(),
      resourceUrl: resourceUrl,
    );
  }

  /// Create a new ACL with ACEs replaced
  DavAcl replaceAces(List<DavAce> newAces) {
    return DavAcl(
      aces: newAces,
      resourceUrl: resourceUrl,
    );
  }
}
