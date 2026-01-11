/// WebDAV Principal representing a user, group, or special entity in the WebDAV access control system.
///
/// A principal is an entity that can be granted or denied access to WebDAV resources.
/// This follows the WebDAV Access Control Protocol (RFC 3744) specifications.
class DavPrincipal {
  /// The URL that identifies this principal
  final String url;

  /// The display name of this principal (optional)
  final String? displayName;

  /// The type of principal (user, group, property, etc.)
  final PrincipalType type;

  /// Additional properties associated with this principal
  final Map<String, String> properties;

  const DavPrincipal({
    required this.url,
    this.displayName,
    this.type = PrincipalType.user,
    this.properties = const {},
  });

  /// Check if this is a user principal
  bool get isUser => type == PrincipalType.user;

  /// Check if this is a group principal
  bool get isGroup => type == PrincipalType.group;

  /// Check if this is a property principal
  bool get isProperty => type == PrincipalType.property;

  /// Check if this is a special principal (like 'all' or 'authenticated')
  bool get isSpecial => type == PrincipalType.special;

  /// Get the name from the URL (last path component)
  String get name {
    Uri uri = Uri.parse(url);
    String path = uri.path;
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    int lastSlash = path.lastIndexOf('/');
    if (lastSlash >= 0) {
      return path.substring(lastSlash + 1);
    }
    return path;
  }

  /// Get a custom property value
  String? getProperty(String name) {
    return properties[name];
  }

  /// Check if principal has a specific property
  bool hasProperty(String name) {
    return properties.containsKey(name);
  }

  @override
  String toString() {
    return 'DavPrincipal{url: $url, displayName: $displayName, type: $type}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DavPrincipal &&
        other.url == url &&
        other.displayName == displayName &&
        other.type == type &&
        _mapEquals(other.properties, properties);
  }

  /// Helper method to compare two maps
  bool _mapEquals(Map<String, String> map1, Map<String, String> map2) {
    if (map1.length != map2.length) return false;
    for (String key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(url, displayName, type, properties.hashCode);
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'displayName': displayName,
      'type': type.toString(),
      'properties': properties,
    };
  }

  /// Create from JSON representation
  factory DavPrincipal.fromJson(Map<String, dynamic> json) {
    return DavPrincipal(
      url: json['url'],
      displayName: json['displayName'],
      type: PrincipalType.values.firstWhere(
        (t) => t.toString() == json['type'],
        orElse: () => PrincipalType.user,
      ),
      properties: Map<String, String>.from(json['properties'] ?? {}),
    );
  }

  /// Create a copy of this principal with updated properties
  DavPrincipal copyWith({
    String? url,
    String? displayName,
    PrincipalType? type,
    Map<String, String>? properties,
  }) {
    return DavPrincipal(
      url: url ?? this.url,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      properties: properties ?? this.properties,
    );
  }
}

/// Enumeration of different types of WebDAV principals
enum PrincipalType {
  /// User principal representing an individual user
  user,

  /// Group principal representing a collection of users
  group,

  /// Property principal representing a property-based principal
  property,

  /// Special principal like 'all' or 'authenticated'
  special,
}
