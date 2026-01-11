/// WebDAV Report Interface
///
/// Base interface for WebDAV REPORT method operations
abstract interface class WebDAVReport<T> {
  /// Generate the XML content for the report request
  String toXml();

  /// Generate the request body for the report
  String generateRequestBody() => toXml();

  /// Parse response and return result
  T parseResponse(String responseXml);

  /// Get the depth header value for this report
  String? getDepth() => null;

  /// Get additional headers for this report
  Map<String, String> getHeaders() => {};
}
