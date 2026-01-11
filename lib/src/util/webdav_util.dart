import 'dart:convert';
import 'package:xml/xml.dart' as xml;
import '../parser/xml_helpers.dart' as xh;

/// Utility class for WebDAV operations, date parsing, XML handling, and other common tasks.
///
/// This class provides helper methods following the WebDAV protocol specifications
/// and replicates the functionality of the Java WebDAV utilities.
class WebDAVUtil {
  /// Default namespace prefix
  static const String customNamespacePrefix = "S";

  /// Default namespace URI
  static const String customNamespaceUri = "SAR:";

  /// Default namespace prefix
  static const String defaultNamespacePrefix = "D";

  /// Default namespace URI
  static const String defaultNamespaceUri = "DAV:";

  /// Standard UTF-8 encoding
  static Encoding get standardUtf8 => utf8;

  /// Date formats supported for parsing WebDAV dates
  static const List<String> supportedDateFormats = [
    "yyyy-MM-ddTHH:mm:ssZ",
    "EEE, dd MMM yyyy HH:mm:ss zzz",
    "yyyy-MM-ddTHH:mm:ss.SSSZ",
    "yyyy-MM-ddTHH:mm:sszzz",
    "EEE MMM dd HH:mm:ss zzz yyyy",
    "EEEEEE, dd-MMM-yy HH:mm:ss zzz",
    "EEE MMMM d HH:mm:ss yyyy",
  ];

  /// Parse a date string from WebDAV response using multiple formats
  static DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    // Try ISO 8601 format first (most common)
    try {
      return DateTime.parse(value);
    } catch (e) {
      // Ignore and try other formats
    }

    // Try RFC 2822 format
    try {
      return DateTime.parse(value.replaceAll('GMT', 'Z'));
    } catch (e) {
      // Ignore and continue
    }

    // If all parsing fails, return null
    return null;
  }

  /// Format a DateTime for WebDAV requests (ISO 8601 format)
  static String formatDate(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  /// Escape XML content
  static String escapeXml(String content) {
    return content
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Unescape XML content
  static String unescapeXml(String content) {
    return content
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  /// Check if a URL is absolute
  static bool isAbsoluteUrl(String url) {
    return Uri.tryParse(url)?.isAbsolute ?? false;
  }

  /// Join URL paths properly
  static String joinPaths(String base, String path) {
    if (base.isEmpty) return path;
    if (path.isEmpty) return base;

    bool baseEndsWithSlash = base.endsWith('/');
    bool pathStartsWithSlash = path.startsWith('/');

    if (baseEndsWithSlash && pathStartsWithSlash) {
      return base + path.substring(1);
    } else if (!baseEndsWithSlash && !pathStartsWithSlash) {
      return '$base/$path';
    } else {
      return base + path;
    }
  }

  /// Normalize a URL path by removing redundant slashes and path elements
  static String normalizePath(String path) {
    if (path.isEmpty) return '/';

    List<String> segments = path.split('/').where((s) => s.isNotEmpty).toList();
    List<String> normalized = [];

    for (String segment in segments) {
      if (segment == '.') {
        // Current directory, skip
        continue;
      } else if (segment == '..') {
        // Parent directory
        if (normalized.isNotEmpty) {
          normalized.removeLast();
        }
      } else {
        normalized.add(segment);
      }
    }

    String result = '/' + normalized.join('/');
    if (path.endsWith('/') && !result.endsWith('/') && result != '/') {
      result += '/';
    }

    return result;
  }

  /// Encode a URL component
  static String encodeUrlComponent(String component) {
    return Uri.encodeComponent(component);
  }

  /// Decode a URL component
  static String decodeUrlComponent(String component) {
    return Uri.decodeComponent(component);
  }

  /// Get the parent path of a given path
  static String getParentPath(String path) {
    if (path == '/' || path.isEmpty) {
      return '/';
    }

    String normalized = path;
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    int lastSlash = normalized.lastIndexOf('/');
    if (lastSlash <= 0) {
      return '/';
    }

    return normalized.substring(0, lastSlash + 1);
  }

  /// Get the file name from a path
  static String getFileName(String path) {
    if (path.isEmpty || path == '/') {
      return '';
    }

    String normalized = path;
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    int lastSlash = normalized.lastIndexOf('/');
    if (lastSlash < 0) {
      return normalized;
    }

    return normalized.substring(lastSlash + 1);
  }

  /// Check if a path represents a collection (directory)
  static bool isCollection(String path) {
    return path.endsWith('/');
  }

  /// Ensure a collection path ends with a slash
  static String ensureCollectionPath(String path) {
    if (path.isEmpty) return '/';
    return path.endsWith('/') ? path : '$path/';
  }

  /// Remove trailing slash from a path (except for root)
  static String removeTrailingSlash(String path) {
    if (path.length <= 1) return path;
    return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
  }

  /// Generate a basic authentication header value
  static String basicAuth(String username, String password) {
    String credentials = '$username:$password';
    String encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }

  /// Parse HTTP status line
  static int parseStatusCode(String statusLine) {
    List<String> parts = statusLine.split(' ');
    if (parts.length >= 2) {
      try {
        return int.parse(parts[1]);
      } catch (e) {
        return 500; // Internal server error as fallback
      }
    }
    return 500;
  }

  /// Check if HTTP status code indicates success
  static bool isSuccessStatus(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Check if HTTP status code indicates client error
  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  /// Check if HTTP status code indicates server error
  static bool isServerError(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  /// Get MIME type from file extension
  static String getMimeType(String filename) {
    String extension = filename.split('.').last.toLowerCase();

    switch (extension) {
      case 'txt':
        return 'text/plain';
      case 'html':
      case 'htm':
        return 'text/html';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      case 'pdf':
        return 'application/pdf';
      case 'zip':
        return 'application/zip';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'mp3':
        return 'audio/mpeg';
      case 'mp4':
        return 'video/mp4';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'application/octet-stream';
    }
  }

  /// Generate a lock token
  static String generateLockToken() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int random = (DateTime.now().microsecondsSinceEpoch % 1000000);
    return 'opaquelocktoken:$timestamp-$random';
  }

  /// Parse a lock token from lock discovery XML using proper XML parsing
  static String? parseLockToken(String lockDiscoveryXml) {
    try {
      final doc = xml.XmlDocument.parse(lockDiscoveryXml);
      // Use local name matching for namespace-agnostic parsing
      final lockTokenEl = xh.firstDescendantByLocalName(doc, 'locktoken');
      if (lockTokenEl == null) return null;
      final hrefEl = xh.firstDescendantByLocalName(lockTokenEl, 'href');
      return hrefEl?.innerText;
    } catch (_) {
      return null;
    }
  }

  /// Convert depth value to string for HTTP header
  static String depthToString(int depth) {
    switch (depth) {
      case 0:
        return '0';
      case 1:
        return '1';
      case -1:
        return 'infinity';
      default:
        return '1';
    }
  }

  /// Parse depth value from string
  static int parseDepth(String depthStr) {
    switch (depthStr.toLowerCase()) {
      case '0':
        return 0;
      case '1':
        return 1;
      case 'infinity':
        return -1;
      default:
        return 1;
    }
  }

  /// Build a minimal PROPFIND allprop body
  static String buildAllPropfindXml() {
    return '<?xml version="1.0" encoding="utf-8"?>\n'
        '<D:propfind xmlns:D="DAV:">\n'
        '  <D:allprop/>\n'
        '</D:propfind>';
  }

  /// Build a PROPFIND prop body for a set of DAV properties (no values)
  static String buildPropfindXml(
    Set<String> davProps, {
    Map<String, String>? customProps,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.writeln('<D:propfind xmlns:D="DAV:">');
    buffer.writeln('  <D:prop>');
    for (final p in davProps) {
      buffer.writeln('    <D:$p/>');
    }
    if (customProps != null && customProps.isNotEmpty) {
      for (final entry in customProps.entries) {
        final k = entry.key;
        final v = entry.value;
        if (v.isEmpty) {
          buffer.writeln('    <S:$k xmlns:S="SAR:"/>');
        } else {
          buffer.writeln('    <S:$k xmlns:S="SAR:">$v</S:$k>');
        }
      }
    }
    buffer.writeln('  </D:prop>');
    buffer.write('</D:propfind>');
    return buffer.toString();
  }

  /// Build a PROPPATCH body from add/remove properties
  static String buildProppatchXml({
    Map<String, String>? addProps,
    List<String>? removeProps,
  }) {
    final addMap = addProps ?? const <String, String>{};
    final removeList = removeProps ?? const <String>[];

    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.writeln('<D:propertyupdate xmlns:D="DAV:">');
    if (addMap.isNotEmpty) {
      buffer.writeln('  <D:set>');
      buffer.writeln('    <D:prop>');
      for (final entry in addMap.entries) {
        buffer.writeln(
          '      <S:${entry.key} xmlns:S="SAR:">${entry.value}</S:${entry.key}>',
        );
      }
      buffer.writeln('    </D:prop>');
      buffer.writeln('  </D:set>');
    }
    if (removeList.isNotEmpty) {
      buffer.writeln('  <D:remove>');
      buffer.writeln('    <D:prop>');
      for (final name in removeList) {
        buffer.writeln('      <S:$name xmlns:S="SAR:"/>');
      }
      buffer.writeln('    </D:prop>');
      buffer.writeln('  </D:remove>');
    }
    buffer.write('</D:propertyupdate>');
    return buffer.toString();
  }
}
