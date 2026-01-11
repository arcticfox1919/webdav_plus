/// Describes a resource on a remote WebDAV server. This could be a directory or an actual file.
///
/// Provides comprehensive information about WebDAV resources including metadata,
/// properties, and resource type information following the WebDAV protocol specifications.
class DavResource {
  /// The default content-type if Getcontenttype is not set in
  /// the Multistatus response.
  static const String defaultContentType = "application/octet-stream";

  /// The default content-length if Getcontentlength is not set in
  /// the Multistatus response.
  static const int defaultContentLength = -1;

  /// content-type for Collection.
  static const String httpdUnixDirectoryContentType = "httpd/unix-directory";

  /// The default status code if status is not set in
  /// the Multistatus response.
  static const int defaultStatusCode = 200;

  /// Path component separator
  static const String separator = "/";

  final Uri href;
  final int statusCode;
  final DateTime? creation;
  final DateTime? modified;
  final String contentType;
  final String? etag;
  final String? displayName;
  final List<String> resourceTypes;
  final String? contentLanguage;
  final int contentLength;
  final Map<String, String> customProperties;
  final Map<String, dynamic> lockDiscovery;
  final Map<String, dynamic> supportedLock;

  DavResource({
    required this.href,
    this.statusCode = defaultStatusCode,
    this.creation,
    this.modified,
    this.contentType = defaultContentType,
    this.etag,
    this.displayName,
    this.resourceTypes = const [],
    this.contentLanguage,
    this.contentLength = defaultContentLength,
    this.customProperties = const {},
    this.lockDiscovery = const {},
    this.supportedLock = const {},
  });

  /// Check if this resource is a directory/collection
  bool get isDirectory {
    return resourceTypes.contains('collection') ||
        contentType == httpdUnixDirectoryContentType;
  }

  /// Check if this resource is a file
  bool get isFile {
    return !isDirectory;
  }

  /// Get the absolute URL of this resource
  String get absoluteUrl => href.toString();

  /// Get the path component of this resource
  String get path => href.path;

  /// Get the name of this resource (last path component)
  String get name {
    String path = href.path;
    if (path.endsWith(separator)) {
      path = path.substring(0, path.length - 1);
    }
    int lastSeparator = path.lastIndexOf(separator);
    if (lastSeparator >= 0) {
      return path.substring(lastSeparator + 1);
    }
    return path;
  }

  /// Get a custom property value
  String? getCustomProperty(String name) {
    return customProperties[name];
  }

  /// Check if resource has a specific custom property
  bool hasCustomProperty(String name) {
    return customProperties.containsKey(name);
  }

  /// Get all custom property names
  Set<String> getCustomPropertyNames() {
    return customProperties.keys.toSet();
  }

  /// Create a copy of this resource with updated properties
  DavResource copyWith({
    Uri? href,
    int? statusCode,
    DateTime? creation,
    DateTime? modified,
    String? contentType,
    String? etag,
    String? displayName,
    List<String>? resourceTypes,
    String? contentLanguage,
    int? contentLength,
    Map<String, String>? customProperties,
    Map<String, dynamic>? lockDiscovery,
    Map<String, dynamic>? supportedLock,
  }) {
    return DavResource(
      href: href ?? this.href,
      statusCode: statusCode ?? this.statusCode,
      creation: creation ?? this.creation,
      modified: modified ?? this.modified,
      contentType: contentType ?? this.contentType,
      etag: etag ?? this.etag,
      displayName: displayName ?? this.displayName,
      resourceTypes: resourceTypes ?? this.resourceTypes,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      contentLength: contentLength ?? this.contentLength,
      customProperties: customProperties ?? this.customProperties,
      lockDiscovery: lockDiscovery ?? this.lockDiscovery,
      supportedLock: supportedLock ?? this.supportedLock,
    );
  }

  @override
  String toString() {
    return 'DavResource{href: $href, name: $name, isDirectory: $isDirectory, '
        'contentType: $contentType, contentLength: $contentLength, '
        'modified: $modified}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DavResource && other.href == href;
  }

  @override
  int get hashCode => href.hashCode;

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'href': href.toString(),
      'statusCode': statusCode,
      'creation': creation?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'contentType': contentType,
      'etag': etag,
      'displayName': displayName,
      'resourceTypes': resourceTypes,
      'contentLanguage': contentLanguage,
      'contentLength': contentLength,
      'customProperties': customProperties,
      'lockDiscovery': lockDiscovery,
      'supportedLock': supportedLock,
    };
  }

  /// Create from JSON representation
  factory DavResource.fromJson(Map<String, dynamic> json) {
    return DavResource(
      href: Uri.parse(json['href']),
      statusCode: json['statusCode'] ?? defaultStatusCode,
      creation:
          json['creation'] != null ? DateTime.parse(json['creation']) : null,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
      contentType: json['contentType'] ?? defaultContentType,
      etag: json['etag'],
      displayName: json['displayName'],
      resourceTypes: List<String>.from(json['resourceTypes'] ?? []),
      contentLanguage: json['contentLanguage'],
      contentLength: json['contentLength'] ?? defaultContentLength,
      customProperties:
          Map<String, String>.from(json['customProperties'] ?? {}),
      lockDiscovery: Map<String, dynamic>.from(json['lockDiscovery'] ?? {}),
      supportedLock: Map<String, dynamic>.from(json['supportedLock'] ?? {}),
    );
  }
}
