/// WebDAV Quota information representing disk usage and quota limits for a WebDAV resource.
///
/// This class provides information about storage quotas and usage following the
/// WebDAV quota specifications (RFC 4331).
class DavQuota {
  /// The number of bytes available for use in the quota
  final int? quotaAvailableBytes;

  /// The number of bytes used in the quota
  final int? quotaUsedBytes;

  /// The total quota size in bytes (calculated from available + used)
  final int? quotaTotalBytes;

  /// The resource URL this quota information applies to
  final String? resourceUrl;

  /// Additional quota-related properties
  final Map<String, String> properties;

  const DavQuota({
    this.quotaAvailableBytes,
    this.quotaUsedBytes,
    this.quotaTotalBytes,
    this.resourceUrl,
    this.properties = const {},
  });

  /// Get the total quota size (used + available)
  int? get totalQuota {
    if (quotaTotalBytes != null) return quotaTotalBytes;
    if (quotaUsedBytes != null && quotaAvailableBytes != null) {
      return quotaUsedBytes! + quotaAvailableBytes!;
    }
    return null;
  }

  /// Get the percentage of quota used (0.0 to 1.0)
  double? get usagePercentage {
    final total = totalQuota;
    if (total == null || total == 0 || quotaUsedBytes == null) return null;
    return quotaUsedBytes! / total;
  }

  /// Get the percentage of quota used as an integer (0 to 100)
  int? get usagePercentageInt {
    final percentage = usagePercentage;
    if (percentage == null) return null;
    return (percentage * 100).round();
  }

  /// Check if quota is available (has any quota information)
  bool get hasQuotaInfo {
    return quotaAvailableBytes != null ||
        quotaUsedBytes != null ||
        quotaTotalBytes != null;
  }

  /// Check if quota is nearly full (over 90% usage)
  bool get isNearlyFull {
    final percentage = usagePercentage;
    return percentage != null && percentage > 0.9;
  }

  /// Check if quota is full (100% usage or no available bytes)
  bool get isFull {
    return quotaAvailableBytes == 0 ||
        (usagePercentage != null && usagePercentage! >= 1.0);
  }

  /// Get a human-readable description of the quota usage
  String get usageDescription {
    if (!hasQuotaInfo) return 'No quota information available';

    final used = quotaUsedBytes;
    final available = quotaAvailableBytes;
    final total = totalQuota;

    if (used != null && total != null) {
      return '${_formatBytes(used)} of ${_formatBytes(total)} used';
    } else if (used != null && available != null) {
      return '${_formatBytes(used)} used, ${_formatBytes(available)} available';
    } else if (used != null) {
      return '${_formatBytes(used)} used';
    } else if (available != null) {
      return '${_formatBytes(available)} available';
    }

    return 'Quota information incomplete';
  }

  /// Format bytes in a human-readable format
  String _formatBytes(int bytes) {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;
    const int tb = gb * 1024;

    if (bytes >= tb) {
      return '${(bytes / tb).toStringAsFixed(1)} TB';
    } else if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(1)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    } else {
      return '$bytes bytes';
    }
  }

  /// Get a custom property value
  String? getProperty(String name) {
    return properties[name];
  }

  /// Check if quota has a specific property
  bool hasProperty(String name) {
    return properties.containsKey(name);
  }

  @override
  String toString() {
    return 'DavQuota{resourceUrl: $resourceUrl, used: $quotaUsedBytes, '
        'available: $quotaAvailableBytes, total: $totalQuota}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DavQuota &&
        other.quotaAvailableBytes == quotaAvailableBytes &&
        other.quotaUsedBytes == quotaUsedBytes &&
        other.quotaTotalBytes == quotaTotalBytes &&
        other.resourceUrl == resourceUrl &&
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
    return Object.hash(quotaAvailableBytes, quotaUsedBytes, quotaTotalBytes,
        resourceUrl, properties.hashCode);
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'quotaAvailableBytes': quotaAvailableBytes,
      'quotaUsedBytes': quotaUsedBytes,
      'quotaTotalBytes': quotaTotalBytes,
      'resourceUrl': resourceUrl,
      'properties': properties,
    };
  }

  /// Create from JSON representation
  factory DavQuota.fromJson(Map<String, dynamic> json) {
    return DavQuota(
      quotaAvailableBytes: json['quotaAvailableBytes'],
      quotaUsedBytes: json['quotaUsedBytes'],
      quotaTotalBytes: json['quotaTotalBytes'],
      resourceUrl: json['resourceUrl'],
      properties: Map<String, String>.from(json['properties'] ?? {}),
    );
  }

  /// Create a copy of this quota with updated properties
  DavQuota copyWith({
    int? quotaAvailableBytes,
    int? quotaUsedBytes,
    int? quotaTotalBytes,
    String? resourceUrl,
    Map<String, String>? properties,
  }) {
    return DavQuota(
      quotaAvailableBytes: quotaAvailableBytes ?? this.quotaAvailableBytes,
      quotaUsedBytes: quotaUsedBytes ?? this.quotaUsedBytes,
      quotaTotalBytes: quotaTotalBytes ?? this.quotaTotalBytes,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      properties: properties ?? this.properties,
    );
  }
}
