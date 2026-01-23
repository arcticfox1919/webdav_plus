import 'dart:io';
import 'dart:typed_data';
import 'dart:convert' show utf8;
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../webdav_client.dart';
import '../dav_resource.dart';
import '../dav_ace.dart';
import '../dav_acl.dart';
import '../dav_principal.dart';
import '../dav_quota.dart';
import '../webdav_exception.dart';
import '../util/webdav_util.dart';
import '../report/webdav_report.dart';
import '../model/propfind.dart';
import '../auth/authentication_handler.dart';
import '../model/multistatus.dart';
import '../model/search.dart';
import '../model/proppatch.dart';
import '../model/lockinfo.dart';
import '../model/acl.dart';
import '../model/sync.dart';
import '../model/binding.dart' as binding;
import '../model/lock.dart';
import '../model/version.dart';
import '../parser/multistatus_parser.dart' as ms_parser;
import '../parser/acl_parser.dart' as acl_parser;
import '../parser/lock_parser.dart' as lock_parser;
import '../parser/privilege_parser.dart' as priv_parser;
import '../parser/report_set_parser.dart' as report_parser;
import '../parser/xml_helpers.dart' as xh;

/// HTTP-based implementation of the WebDAV client.
///
/// Uses Dart http package to communicate with WebDAV servers.
/// Provides complete WebDAV protocol support following RFC 4918 and related specifications.
class HttpWebdavClient implements WebdavClient {
  late http.Client _client;
  String? _username;
  String? _password;
  String? _domain;
  String? _workstation;
  AuthenticationHandler? _authHandler;
  bool _preemptiveAuth = false;
  bool _compressionEnabled = false;
  Map<String, String> _defaultHeaders = {};
  bool _ignoreCookies = false;
  String? _baseUrl;

  @override
  String? get baseUrl => _baseUrl;

  @override
  void setBaseUrl(String baseUrl) {
    // Remove trailing slash for consistent URL joining
    _baseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  /// Resolve a URL against the base URL
  ///
  /// If the URL is absolute (starts with http:// or https://), it is returned as-is.
  /// Otherwise, it is joined with the base URL.
  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (_baseUrl == null) {
      return url;
    }
    // Ensure path starts with /
    final path = url.startsWith('/') ? url : '/$url';
    return '$_baseUrl$path';
  }

  /// Create a new HttpWebdavClient instance with default HTTP client
  HttpWebdavClient({String? baseUrl}) {
    _client = http.Client();
    _setupDefaultHeaders();
    if (baseUrl != null) {
      setBaseUrl(baseUrl);
    }
  }

  /// Create client with authentication credentials
  HttpWebdavClient.withCredentials(
    String username,
    String password, {
    String? baseUrl,
    bool isPreemptive = false,
  }) {
    _client = http.Client();
    _setupDefaultHeaders();
    if (baseUrl != null) {
      setBaseUrl(baseUrl);
    }
    setCredentials(username, password, isPreemptive: isPreemptive);
  }

  /// Create client with compression support
  HttpWebdavClient.withCompression({String? baseUrl}) {
    _client = http.Client();
    _setupDefaultHeaders();
    if (baseUrl != null) {
      setBaseUrl(baseUrl);
    }
    enableCompression();
  }

  /// Create fully configured client
  HttpWebdavClient.configured({
    String? baseUrl,
    String? username,
    String? password,
    bool isPreemptive = false,
    bool compression = false,
  }) {
    _client = http.Client();
    _setupDefaultHeaders();
    if (baseUrl != null) {
      setBaseUrl(baseUrl);
    }
    if (username != null && password != null) {
      setCredentials(username, password, isPreemptive: isPreemptive);
    }
    if (compression) {
      enableCompression();
    }
  }

  /// Create a new HttpWebdavClient instance with custom HTTP client
  HttpWebdavClient.withClient(http.Client client) {
    _client = client;
    _setupDefaultHeaders();
  }

  void _setupDefaultHeaders() {
    _defaultHeaders = {'User-Agent': 'WebdavPlus-Dart/1.0.0', 'Accept': '*/*'};
  }

  @override
  void setCredentials(
    String username,
    String password, {
    bool isPreemptive = false,
  }) {
    _username = username;
    _password = password;
    _preemptiveAuth = isPreemptive;
  }

  @override
  void setCredentialsWithDomain(
    String username,
    String password,
    String domain,
    String workstation, {
    bool isPreemptive = false,
  }) {
    // Clear any existing custom auth handler
    _authHandler = null;

    // Set up Basic authentication with domain support
    _authHandler = BasicAuthenticationHandler(
      username: username,
      password: password,
      domain: domain,
      workstation: workstation,
    );
    _preemptiveAuth = isPreemptive;

    // Also store credentials for backward compatibility
    _username = username;
    _password = password;
    _domain = domain;
    _workstation = workstation;
  }

  @override
  void setAuthenticationHandler(
    AuthenticationHandler handler, {
    bool isPreemptive = false,
  }) {
    _authHandler = handler;
    _preemptiveAuth = isPreemptive;

    // Clear basic credentials since we're using custom handler
    _username = null;
    _password = null;
    _domain = null;
    _workstation = null;
  }

  @override
  void clearAuthentication() {
    _authHandler = null;
    _username = null;
    _password = null;
    _domain = null;
    _workstation = null;
    _preemptiveAuth = false;
  }

  @override
  Future<List<DavResource>> list(String url) {
    return listWithDepth(url, 1);
  }

  @override
  Future<List<DavResource>> listWithDepth(String url, int depth) {
    return listWithAllProp(url, depth, true);
  }

  @override
  Future<List<DavResource>> listWithProps(
    String url,
    int depth,
    Set<String> props,
  ) {
    final propsWithResourceType = <String>{...props, 'resourcetype'};
    Propfind propfind = Propfind(prop: Prop(properties: propsWithResourceType));
    return _propfind(url, depth, propfind);
  }

  @override
  Future<List<DavResource>> listWithAllProp(
    String url,
    int depth,
    bool allProp,
  ) {
    Propfind propfind;
    if (allProp) {
      propfind = Propfind(allprop: Allprop());
    } else {
      propfind = Propfind(
        prop: Prop(
          properties: {
            'getcontentlength',
            'getlastmodified',
            'creationdate',
            'displayname',
            'getcontenttype',
            'resourcetype',
            'getetag',
            // Include lockdiscovery to align with Java's default non-allprop behavior
            'lockdiscovery',
          },
        ),
      );
    }
    return _propfind(url, depth, propfind);
  }

  @override
  Future<List<DavResource>> propfind(String url, int depth, Set<String> props) {
    return listWithProps(url, depth, props);
  }

  Future<List<DavResource>> _propfind(
    String url,
    int depth,
    Propfind propfind,
  ) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = WebDAVUtil.depthToString(depth);

      String body = propfind.toXml();

      http.Response response = await _makeRequest(
        'PROPFIND',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        return ms_parser.parseMultistatusResources(xmlString);
      } else {
        throw WebDAVException.fromResponse(
          'PROPFIND failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during PROPFIND', cause: e);
    }
  }

  @override
  Future<List<DavResource>> versionsList(String url) {
    return versionsListWithDepth(url, 1);
  }

  @override
  Future<List<DavResource>> versionsListWithDepth(String url, int depth) {
    return versionsListWithProps(url, depth, {
      'version-name',
      'creator-displayname',
      'creation-date',
      'successor-set',
      'predecessor-set',
    });
  }

  @override
  Future<List<DavResource>> versionsListWithProps(
    String url,
    int depth,
    Set<String> props,
  ) async {
    try {
      final versionTree = VersionTree(properties: props.toList());
      return await report(url, depth, _VersionTreeReport(versionTree, this));
    } catch (e) {
      throw WebDAVException('Failed to get versions list: $e');
    }
  }

  @override
  Future<T> report<T>(String url, int depth, WebDAVReport<T> report) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      String? depthHeader = report.getDepth();
      if (depthHeader != null) {
        headers['Depth'] = depthHeader;
      } else {
        headers['Depth'] = WebDAVUtil.depthToString(depth);
      }

      headers.addAll(report.getHeaders());

      String body = report.generateRequestBody();

      http.Response response = await _makeRequest(
        'REPORT',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        return report.parseResponse(xmlString);
      } else {
        throw WebDAVException.fromResponse(
          'REPORT failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during REPORT', cause: e);
    }
  }

  /// Perform WebDAV sync-collection report (RFC 6578)
  /// Used for efficient collection synchronization by fetching only changes
  /// since a specific sync token
  @override
  Future<List<DavResource>> syncCollection(
    String url,
    String syncToken, {
    int depth = 1,
    List<String>? properties,
    int? limit,
  }) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = WebDAVUtil.depthToString(depth);

      // Build sync-collection request
      final sync = SyncCollection(
        syncToken: syncToken,
        syncLevel: depth.toString(),
        properties:
            properties ?? ['getetag', 'getcontentlength', 'getlastmodified'],
        limit: limit,
      );

      String body = sync.toXml();

      http.Response response = await _makeRequest(
        'REPORT',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        return ms_parser.parseMultistatusResources(xmlString);
      } else {
        throw WebDAVException.fromResponse(
          'SYNC-COLLECTION failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Network error during SYNC-COLLECTION',
        cause: e,
      );
    }
  }

  /// Create a binding (RFC 5842) - creates a new name for an existing resource
  /// This allows multiple names (URIs) to refer to the same resource
  @override
  Future<void> bind(String sourceUrl, String targetUrl, bool overwrite) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Overwrite'] = overwrite ? 'T' : 'F';

      // Build bind request
      final bind = binding.Bind(
        href: sourceUrl,
        segment: Uri.parse(targetUrl).pathSegments.last,
      );

      String body = bind.toXml();

      http.Response response = await _makeRequest(
        'BIND',
        targetUrl,
        headers: headers,
        body: body,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException.fromResponse(
          'BIND failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during BIND', cause: e);
    }
  }

  /// Unbind a resource (RFC 5842) - removes a binding to a resource
  /// This removes one name for a resource but doesn't delete the resource
  /// unless it was the last binding
  @override
  Future<void> unbind(String url, String segment) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      // Build unbind request
      final unbind = binding.UnBind(segment: segment);
      String body = unbind.toXml();

      http.Response response = await _makeRequest(
        'UNBIND',
        url,
        headers: headers,
        body: body,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException.fromResponse(
          'UNBIND failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during UNBIND', cause: e);
    }
  }

  /// Get supported reports for a WebDAV resource
  /// Returns a list of supported report types that can be executed on the resource
  Future<List<String>> getSupportedReports(String url) async {
    try {
      // Use PROPFIND to request supported-report-set property
      final propfind = Propfind(
        prop: Prop(properties: {'supported-report-set'}),
      );

      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = '0';

      String body = propfind.toXml();

      http.Response response = await _makeRequest(
        'PROPFIND',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        final multistatus = Multistatus.fromXml(xmlString);
        if (multistatus.responses.isNotEmpty) {
          final firstResponse = multistatus.responses.first;
          for (final propstat in firstResponse.propstats) {
            if (propstat.status.contains('200')) {
              final supportedReportSet =
                  propstat.prop.customProperties['supported-report-set'];
              if (supportedReportSet != null) {
                return report_parser.parseSupportedReports(supportedReportSet);
              }
            }
          }
        }
        return [];
      } else {
        throw WebDAVException.fromResponse(
          'Failed to get supported reports',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Network error during supported reports discovery',
        cause: e,
      );
    }
  }

  // Deprecated: replaced by parser/report_set_parser.dart

  /// Get current user's privileges on a WebDAV resource
  /// Returns a list of privileges that the current user has on the specified resource
  @override
  Future<List<String>> getCurrentUserPrivileges(String url) async {
    try {
      // Use PROPFIND to request current-user-privilege-set property
      final propfind = Propfind(
        prop: Prop(properties: {'current-user-privilege-set'}),
      );

      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = '0';

      String body = propfind.toXml();

      http.Response response = await _makeRequest(
        'PROPFIND',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        final multistatus = Multistatus.fromXml(xmlString);
        if (multistatus.responses.isNotEmpty) {
          final firstResponse = multistatus.responses.first;
          for (final propstat in firstResponse.propstats) {
            if (propstat.status.contains('200')) {
              final privilegeSet =
                  propstat.prop.customProperties['current-user-privilege-set'];
              if (privilegeSet != null) {
                return priv_parser.parsePrivileges(privilegeSet);
              }
            }
          }
        }
        return [];
      } else {
        throw WebDAVException.fromResponse(
          'Failed to get current user privileges',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Network error during privilege discovery',
        cause: e,
      );
    }
  }

  // Deprecated: replaced by parser/privilege_parser.dart

  /// Check if current user has specific privilege on resource
  /// Uses type-safe privilege checking with privileges.dart model classes
  @override
  Future<bool> hasPrivilege(String url, String privilegeName) async {
    final userPrivileges = await getCurrentUserPrivileges(url);
    return userPrivileges.contains(privilegeName) ||
        userPrivileges.contains('all');
  }

  /// Validate privileges before performing operations
  /// Returns privilege validation results using privileges.dart constants
  @override
  Future<Map<String, bool>> validatePrivileges(
    String url,
    List<String> requiredPrivileges,
  ) async {
    final userPrivileges = await getCurrentUserPrivileges(url);
    final results = <String, bool>{};

    for (final privilege in requiredPrivileges) {
      results[privilege] =
          userPrivileges.contains(privilege) || userPrivileges.contains('all');
    }

    return results;
  }

  @override
  Future<List<DavResource>> search(
    String url,
    String language,
    String query,
  ) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      SearchRequest searchRequest = SearchRequest(
        query: query,
        language: language,
      );
      String body = searchRequest.toXml();

      http.Response response = await _makeRequest(
        'SEARCH',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        return ms_parser.parseMultistatusResources(xmlString);
      } else {
        throw WebDAVException(
          'SEARCH failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during SEARCH', cause: e);
    }
  }

  @override
  Future<List<DavResource>> patch(String url, Map<String, String> addProps) {
    return patchWithRemove(url, addProps, []);
  }

  @override
  Future<List<DavResource>> patchWithRemove(
    String url,
    Map<String, String> addProps,
    List<String> removeProps,
  ) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      Propertyupdate propertyupdate = Propertyupdate(
        set: addProps.isNotEmpty
            ? SetElement(prop: Prop(customProperties: addProps))
            : null,
        remove: removeProps.isNotEmpty
            ? Remove(prop: Prop(properties: removeProps.toSet()))
            : null,
      );

      String body = propertyupdate.toXml();

      http.Response response = await _makeRequest(
        'PROPPATCH',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        return ms_parser.parseMultistatusResources(xmlString);
      } else {
        throw WebDAVException(
          'PROPPATCH failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during PROPPATCH', cause: e);
    }
  }

  @override
  Future<List<DavResource>> patchWithHeaders(
    String url,
    Map<String, String> addProps,
    List<String> removeProps,
    Map<String, String> headers,
  ) async {
    try {
      Map<String, String> requestHeaders = _buildHeaders();
      requestHeaders['Content-Type'] = 'application/xml; charset=utf-8';
      requestHeaders.addAll(headers);

      Propertyupdate propertyupdate = Propertyupdate(
        set: addProps.isNotEmpty
            ? SetElement(prop: Prop(customProperties: addProps))
            : null,
        remove: removeProps.isNotEmpty
            ? Remove(prop: Prop(properties: removeProps.toSet()))
            : null,
      );

      String body = propertyupdate.toXml();

      http.Response response = await _makeRequest(
        'PROPPATCH',
        url,
        headers: requestHeaders,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        return ms_parser.parseMultistatusResources(xmlString);
      } else {
        throw WebDAVException(
          'PROPPATCH failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during PROPPATCH', cause: e);
    }
  }

  @override
  Future<Uint8List> get(String url) {
    return getWithHeaders(url, {});
  }

  @override
  Future<Uint8List> getVersion(String url, String version) {
    return _getSpecificVersion(url, version);
  }

  @override
  Future<Uint8List> getWithHeaders(
    String url,
    Map<String, String> headers,
  ) async {
    try {
      Map<String, String> requestHeaders = _buildHeaders();
      requestHeaders.addAll(headers);

      http.Response response = await _makeRequest(
        'GET',
        url,
        headers: requestHeaders,
      );

      if (WebDAVUtil.isSuccessStatus(response.statusCode)) {
        return _decodeBodyBytesIfCompressed(response);
      } else {
        throw WebDAVException(
          'GET failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during GET', cause: e);
    }
  }

  @override
  Future<void> put(String url, Uint8List data) {
    return putWithContentType(
      url,
      data,
      WebDAVUtil.getMimeType(WebDAVUtil.getFileName(url)),
    );
  }

  @override
  Future<void> putWithContentType(
    String url,
    Uint8List data,
    String contentType,
  ) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = contentType;
      headers['Content-Length'] = data.length.toString();

      http.Response response = await _makeRequest(
        'PUT',
        url,
        headers: headers,
        bodyBytes: data,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'PUT failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during PUT', cause: e);
    }
  }

  @override
  Future<void> putFile(String url, File localFile, String contentType) {
    return putFileWithExpect(url, localFile, contentType, false);
  }

  @override
  Future<void> putFileWithExpect(
    String url,
    File localFile,
    String contentType,
    bool expectContinue,
  ) {
    return putFileWithLock(url, localFile, contentType, expectContinue, '');
  }

  @override
  Future<void> putFileWithLock(
    String url,
    File localFile,
    String contentType,
    bool expectContinue,
    String lockToken,
  ) async {
    try {
      Uint8List data = await localFile.readAsBytes();

      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = contentType;
      headers['Content-Length'] = data.length.toString();

      if (expectContinue) {
        headers['Expect'] = '100-continue';
      }

      if (lockToken.isNotEmpty) {
        headers['If'] = '(<$lockToken>)';
      }

      http.Response response = await _makeRequest(
        'PUT',
        url,
        headers: headers,
        bodyBytes: data,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'PUT failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during PUT', cause: e);
    }
  }

  @override
  Future<void> putWithHeaders(
    String url,
    Uint8List data,
    Map<String, String> headers,
  ) async {
    try {
      Map<String, String> requestHeaders = _buildHeaders();
      requestHeaders.addAll(headers);
      requestHeaders['Content-Length'] = data.length.toString();

      http.Response response = await _makeRequest(
        'PUT',
        url,
        headers: requestHeaders,
        bodyBytes: data,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'PUT failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during PUT', cause: e);
    }
  }

  @override
  Future<void> putWithContentLength(
    String url,
    Uint8List data,
    String contentType,
    bool expectContinue,
    int contentLength,
  ) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = contentType;
      headers['Content-Length'] = contentLength.toString();

      if (expectContinue) {
        headers['Expect'] = '100-continue';
      }

      http.Response response = await _makeRequest(
        'PUT',
        url,
        headers: headers,
        bodyBytes: data,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'PUT failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during PUT', cause: e);
    }
  }

  @override
  Future<Stream<List<int>>> getStream(String url) {
    return getStreamWithHeaders(url, {});
  }

  @override
  Future<Stream<List<int>>> getStreamWithHeaders(
    String url,
    Map<String, String> headers,
  ) async {
    final resolvedUrl = _resolveUrl(url);
    try {
      Map<String, String> requestHeaders = _buildHeaders();
      requestHeaders.addAll(headers);

      http.Request request = http.Request('GET', Uri.parse(resolvedUrl));
      request.headers.addAll(requestHeaders);

      http.StreamedResponse streamedResponse = await _client.send(request);

      // Handle authentication challenges
      if (streamedResponse.statusCode == 401) {
        if (_username != null && _password != null) {
          http.Request retryRequest = http.Request(
            'GET',
            Uri.parse(resolvedUrl),
          );
          retryRequest.headers.addAll(requestHeaders);
          String username = _username!;
          if (_domain != null && _domain!.isNotEmpty) {
            username = '$_domain\\$_username';
          }
          retryRequest.headers['Authorization'] = WebDAVUtil.basicAuth(
            username,
            _password!,
          );
          streamedResponse = await _client.send(retryRequest);
        }
      }

      if (WebDAVUtil.isSuccessStatus(streamedResponse.statusCode)) {
        // Handle compression if needed
        final encoding =
            streamedResponse.headers['content-encoding']?.toLowerCase() ?? '';
        if (encoding.contains('gzip')) {
          return streamedResponse.stream.transform(GZipCodec().decoder);
        } else if (encoding.contains('deflate')) {
          return streamedResponse.stream.transform(
            ZLibCodec(raw: true).decoder,
          );
        }
        return streamedResponse.stream;
      } else {
        // Consume the stream and throw exception
        final body = await streamedResponse.stream.bytesToString();
        throw WebDAVException(
          'GET stream failed',
          statusCode: streamedResponse.statusCode,
          responseBody: body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during GET stream', cause: e);
    }
  }

  @override
  Future<File> downloadToFile(
    String url,
    String savePath, {
    void Function(int bytesReceived, int totalBytes)? onProgress,
  }) async {
    final resolvedUrl = _resolveUrl(url);
    try {
      Map<String, String> requestHeaders = _buildHeaders();

      http.Request request = http.Request('GET', Uri.parse(resolvedUrl));
      request.headers.addAll(requestHeaders);

      http.StreamedResponse streamedResponse = await _client.send(request);

      // Handle authentication challenges
      if (streamedResponse.statusCode == 401) {
        if (_username != null && _password != null) {
          http.Request retryRequest = http.Request(
            'GET',
            Uri.parse(resolvedUrl),
          );
          retryRequest.headers.addAll(requestHeaders);
          String username = _username!;
          if (_domain != null && _domain!.isNotEmpty) {
            username = '$_domain\\$_username';
          }
          retryRequest.headers['Authorization'] = WebDAVUtil.basicAuth(
            username,
            _password!,
          );
          streamedResponse = await _client.send(retryRequest);
        }
      }

      if (!WebDAVUtil.isSuccessStatus(streamedResponse.statusCode)) {
        final body = await streamedResponse.stream.bytesToString();
        throw WebDAVException(
          'Download failed',
          statusCode: streamedResponse.statusCode,
          responseBody: body,
        );
      }

      final file = File(savePath);
      final sink = file.openWrite();
      final totalBytes = streamedResponse.contentLength ?? -1;
      int bytesReceived = 0;

      // Handle compression
      final encoding =
          streamedResponse.headers['content-encoding']?.toLowerCase() ?? '';
      Stream<List<int>> dataStream;
      if (encoding.contains('gzip')) {
        dataStream = streamedResponse.stream.transform(GZipCodec().decoder);
      } else if (encoding.contains('deflate')) {
        dataStream = streamedResponse.stream.transform(
          ZLibCodec(raw: true).decoder,
        );
      } else {
        dataStream = streamedResponse.stream;
      }

      await for (final chunk in dataStream) {
        sink.add(chunk);
        bytesReceived += chunk.length;
        onProgress?.call(bytesReceived, totalBytes);
      }

      await sink.close();
      return file;
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during download', cause: e);
    }
  }

  @override
  Future<void> putStream(
    String url,
    Stream<List<int>> dataStream,
    int contentLength,
    String contentType,
  ) async {
    final resolvedUrl = _resolveUrl(url);
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = contentType;
      headers['Content-Length'] = contentLength.toString();

      http.StreamedRequest request = http.StreamedRequest(
        'PUT',
        Uri.parse(resolvedUrl),
      );
      request.headers.addAll(headers);

      // Pipe the data stream to the request
      dataStream.listen(
        request.sink.add,
        onDone: () => request.sink.close(),
        onError: (e) => request.sink.addError(e),
        cancelOnError: true,
      );

      http.StreamedResponse streamedResponse = await _client.send(request);

      // Handle authentication challenges
      if (streamedResponse.statusCode == 401) {
        // For streamed requests, we cannot retry easily as the stream is consumed
        // Throw an auth error to let the caller know
        throw WebDAVAuthenticationException(
          'Authentication required. Use preemptive authentication for streaming uploads.',
        );
      }

      if (!WebDAVUtil.isSuccessStatus(streamedResponse.statusCode)) {
        final body = await streamedResponse.stream.bytesToString();
        throw WebDAVException(
          'PUT stream failed',
          statusCode: streamedResponse.statusCode,
          responseBody: body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during PUT stream', cause: e);
    }
  }

  @override
  Future<void> putFileStream(
    String url,
    File localFile, {
    String? contentType,
    void Function(int bytesSent, int totalBytes)? onProgress,
  }) async {
    final resolvedUrl = _resolveUrl(url);
    try {
      final fileLength = await localFile.length();
      final mimeType = contentType ?? WebDAVUtil.getMimeType(localFile.path);
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = mimeType;
      headers['Content-Length'] = fileLength.toString();

      http.StreamedRequest request = http.StreamedRequest(
        'PUT',
        Uri.parse(resolvedUrl),
      );
      request.headers.addAll(headers);

      int bytesSent = 0;

      // Create a transforming stream that tracks progress
      final fileStream = localFile.openRead();
      fileStream.listen(
        (chunk) {
          request.sink.add(chunk);
          bytesSent += chunk.length;
          onProgress?.call(bytesSent, fileLength);
        },
        onDone: () => request.sink.close(),
        onError: (e) => request.sink.addError(e),
        cancelOnError: true,
      );

      http.StreamedResponse streamedResponse = await _client.send(request);

      // Handle authentication challenges
      if (streamedResponse.statusCode == 401) {
        throw WebDAVAuthenticationException(
          'Authentication required. Use preemptive authentication for streaming uploads.',
        );
      }

      if (!WebDAVUtil.isSuccessStatus(streamedResponse.statusCode)) {
        final body = await streamedResponse.stream.bytesToString();
        throw WebDAVException(
          'PUT file stream failed',
          statusCode: streamedResponse.statusCode,
          responseBody: body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Network error during PUT file stream',
        cause: e,
      );
    }
  }

  @override
  Future<void> delete(String url) async {
    try {
      Map<String, String> headers = _buildHeaders();

      http.Response response = await _makeRequest(
        'DELETE',
        url,
        headers: headers,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'DELETE failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during DELETE', cause: e);
    }
  }

  @override
  Future<void> deleteWithHeaders(
    String url,
    Map<String, String> headers,
  ) async {
    try {
      Map<String, String> requestHeaders = _buildHeaders();
      requestHeaders.addAll(headers);

      http.Response response = await _makeRequest(
        'DELETE',
        url,
        headers: requestHeaders,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'DELETE failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during DELETE', cause: e);
    }
  }

  @override
  Future<void> createDirectory(String url) async {
    try {
      Map<String, String> headers = _buildHeaders();

      http.Response response = await _makeRequest(
        'MKCOL',
        url,
        headers: headers,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'MKCOL failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during MKCOL', cause: e);
    }
  }

  @override
  Future<void> move(String sourceUrl, String destinationUrl) {
    return moveWithOverwrite(sourceUrl, destinationUrl, true);
  }

  @override
  Future<void> moveWithOverwrite(
    String sourceUrl,
    String destinationUrl,
    bool overwrite,
  ) {
    return moveWithLock(sourceUrl, destinationUrl, overwrite, '');
  }

  @override
  Future<void> moveWithLock(
    String sourceUrl,
    String destinationUrl,
    bool overwrite,
    String lockToken,
  ) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Destination'] = destinationUrl;
      headers['Overwrite'] = overwrite ? 'T' : 'F';

      if (lockToken.isNotEmpty) {
        headers['If'] = '(<$lockToken>)';
      }

      http.Response response = await _makeRequest(
        'MOVE',
        sourceUrl,
        headers: headers,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'MOVE failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during MOVE', cause: e);
    }
  }

  @override
  Future<void> moveWithHeaders(
    String sourceUrl,
    String destinationUrl,
    bool overwrite,
    Map<String, String> headers,
  ) async {
    try {
      Map<String, String> requestHeaders = _buildHeaders();
      requestHeaders['Destination'] = destinationUrl;
      requestHeaders['Overwrite'] = overwrite ? 'T' : 'F';
      requestHeaders.addAll(headers);

      http.Response response = await _makeRequest(
        'MOVE',
        sourceUrl,
        headers: requestHeaders,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'MOVE failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during MOVE', cause: e);
    }
  }

  @override
  Future<void> copy(String sourceUrl, String destinationUrl) {
    return copyWithOverwrite(sourceUrl, destinationUrl, true);
  }

  @override
  Future<void> copyWithOverwrite(
    String sourceUrl,
    String destinationUrl,
    bool overwrite,
  ) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Destination'] = destinationUrl;
      headers['Overwrite'] = overwrite ? 'T' : 'F';

      http.Response response = await _makeRequest(
        'COPY',
        sourceUrl,
        headers: headers,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'COPY failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during COPY', cause: e);
    }
  }

  @override
  Future<void> copyWithHeaders(
    String sourceUrl,
    String destinationUrl,
    bool overwrite,
    Map<String, String> headers,
  ) async {
    try {
      Map<String, String> requestHeaders = _buildHeaders();
      requestHeaders['Destination'] = destinationUrl;
      requestHeaders['Overwrite'] = overwrite ? 'T' : 'F';
      requestHeaders.addAll(headers);

      http.Response response = await _makeRequest(
        'COPY',
        sourceUrl,
        headers: requestHeaders,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException(
          'COPY failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during COPY', cause: e);
    }
  }

  @override
  Future<bool> exists(String url) async {
    try {
      Map<String, String> headers = _buildHeaders();

      http.Response response = await _makeRequest(
        'HEAD',
        url,
        headers: headers,
      );

      return WebDAVUtil.isSuccessStatus(response.statusCode);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> lock(String url) {
    return lockWithTimeout(url, 3600); // Default 1 hour timeout
  }

  @override
  Future<String> lockWithTimeout(String url, int timeout) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Timeout'] = 'Second-$timeout';

      Lockinfo lockinfo = Lockinfo(
        lockscope: Lockscope(exclusive: true),
        locktype: Locktype(),
        owner: Owner(owner: _username ?? 'dart-webdav-client'),
      );

      String body = lockinfo.toXml();

      http.Response response = await _makeRequest(
        'LOCK',
        url,
        headers: headers,
        body: body,
      );

      if (WebDAVUtil.isSuccessStatus(response.statusCode)) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        String? token = WebDAVUtil.parseLockToken(xmlString);
        if (token != null) {
          return token;
        } else {
          throw WebDAVException('Lock token not found in response');
        }
      } else {
        throw WebDAVException.fromResponse(
          'LOCK failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during LOCK', cause: e);
    }
  }

  @override
  Future<String> refreshLock(String url, String token, String file) async {
    final resolvedUrl = _resolveUrl(url);
    try {
      Map<String, String> headers = _buildHeaders();
      // Align with Java: include resource and token in If header
      final resource = (file.isNotEmpty) ? file : Uri.parse(resolvedUrl).path;
      headers['If'] = '<$resource> (<$token>)';
      headers['Timeout'] = 'Second-3600'; // Default 1 hour timeout

      http.Response response = await _makeRequest(
        'LOCK',
        resolvedUrl,
        headers: headers,
      );

      if (WebDAVUtil.isSuccessStatus(response.statusCode)) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        String? newToken = WebDAVUtil.parseLockToken(xmlString);
        return newToken ?? token; // Return original token if new one not found
      } else {
        throw WebDAVException.fromResponse(
          'Lock refresh failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Network error during lock refresh',
        cause: e,
      );
    }
  }

  @override
  Future<void> unlock(String url, String token) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Lock-Token'] = '<$token>';

      http.Response response = await _makeRequest(
        'UNLOCK',
        url,
        headers: headers,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException.fromResponse(
          'UNLOCK failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during UNLOCK', cause: e);
    }
  }

  /// Discover existing locks on a WebDAV resource
  /// Returns a list of active locks using the lockdiscovery property
  @override
  Future<List<Activelock>> discoverLocks(String url) async {
    try {
      // Use PROPFIND to request lockdiscovery property
      final propfind = Propfind(prop: Prop(properties: {'lockdiscovery'}));

      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = '0';

      String body = propfind.toXml();

      http.Response response = await _makeRequest(
        'PROPFIND',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        final multistatus = Multistatus.fromXml(xmlString);
        if (multistatus.responses.isNotEmpty) {
          final firstResponse = multistatus.responses.first;
          for (final propstat in firstResponse.propstats) {
            if (propstat.status.contains('200')) {
              final lockdiscovery =
                  propstat.prop.customProperties['lockdiscovery'];
              if (lockdiscovery != null) {
                return lock_parser.parseActiveLocks(lockdiscovery);
              }
            }
          }
        }
        return [];
      } else {
        throw WebDAVException.fromResponse(
          'Lock discovery failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Network error during lock discovery',
        cause: e,
      );
    }
  }

  // Deprecated: replaced by parser/lock_parser.dart

  /// Check if a resource is locked
  /// Returns true if the resource has any active locks
  @override
  Future<bool> isLocked(String url) async {
    final locks = await discoverLocks(url);
    return locks.isNotEmpty;
  }

  /// Get lock token for a locked resource if available
  /// Returns the first available lock token or null if not locked
  @override
  Future<String?> getLockToken(String url) async {
    final locks = await discoverLocks(url);
    if (locks.isNotEmpty) {
      return locks.first.locktoken;
    }
    return null;
  }

  @override
  Future<DavAcl> getAcl(String url) async {
    try {
      // Use PROPFIND to request ACL property
      final propfind = Propfind(prop: Prop(properties: {'acl'}));

      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = '0';

      String body = propfind.toXml();

      http.Response response = await _makeRequest(
        'PROPFIND',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        return acl_parser.parseAclFromMultistatusXml(xmlString, url);
      } else {
        throw WebDAVException(
          'ACL retrieval failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Network error during ACL retrieval',
        cause: e,
      );
    }
  }

  @override
  Future<DavQuota> getQuota(String url) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = '0';

      // Create PROPFIND request for quota properties
      final propfind = Propfind(
        prop: Prop(properties: {'quota-available-bytes', 'quota-used-bytes'}),
      );

      String body = propfind.toXml();

      http.Response response = await _makeRequest(
        'PROPFIND',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        final resources = ms_parser.parseMultistatusResources(xmlString);
        if (resources.isNotEmpty) {
          return _createDavQuotaFromResource(resources.first);
        } else {
          throw WebDAVException('No quota information found in response');
        }
      } else {
        throw WebDAVException(
          'Failed to get quota: ${response.statusCode} - ${response.reasonPhrase}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Error getting quota', cause: e);
    }
  }

  @override
  Future<void> setAcl(String url, List<DavAce> aces) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      // Build WebDAV ACL request body
      final acl = Acl(
        aces: aces
            .where((ace) {
              // Filter out protected and inherited ACEs as per WebDAV spec
              return !ace.inherited && !ace.protected;
            })
            .map((davAce) {
              return Ace(
                principal: Principal(
                  href: davAce.principal.startsWith('DAV:')
                      ? null
                      : davAce.principal,
                  isAll: davAce.principal == 'DAV:all',
                  isAuthenticated: davAce.principal == 'DAV:authenticated',
                  isUnauthenticated: davAce.principal == 'DAV:unauthenticated',
                  isSelf: davAce.principal == 'DAV:self',
                ),
                grant: davAce.isGrant
                    ? Grant(
                        privileges: davAce.privileges
                            .map((p) => Privilege(name: p))
                            .toList(),
                      )
                    : null,
                deny: davAce.isDeny
                    ? Deny(
                        privileges: davAce.privileges
                            .map((p) => Privilege(name: p))
                            .toList(),
                      )
                    : null,
                isProtected: davAce.protected,
                inherited: davAce.inherited ? davAce.principal : null,
              );
            })
            .toList(),
      );

      String body = acl.toXml();

      http.Response response = await _makeRequest(
        'ACL',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WebDAVException(
          'Failed to set ACL: ${response.statusCode} - ${response.reasonPhrase}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Error setting ACL', cause: e);
    }
  }

  @override
  Future<List<DavPrincipal>> getPrincipals(String url) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = '1';

      // Create PROPFIND request for principal discovery
      final propfind = Propfind(
        prop: Prop(
          properties: {'displayname', 'resourcetype', 'principal-URL'},
        ),
      );

      String body = propfind.toXml();

      http.Response response = await _makeRequest(
        'PROPFIND',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        final resources = ms_parser.parseMultistatusResources(xmlString);
        final principals = <DavPrincipal>[];

        for (final resource in resources) {
          // Check if this resource is a principal by looking for principal in resourcetype
          final resourceType = resource.customProperties['resourcetype'] ?? '';
          if (resourceType.contains('principal')) {
            final displayName = resource.customProperties['displayname'];
            principals.add(
              DavPrincipal(
                url: resource.href.toString(),
                displayName: displayName,
                type: PrincipalType.user, // Default to user type
              ),
            );
          }
        }

        return principals;
      } else {
        throw WebDAVException(
          'Failed to get principals: ${response.statusCode} - ${response.reasonPhrase}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Error getting principals', cause: e);
    }
  }

  @override
  Future<List<String>> getPrincipalCollectionSet(String url) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = '0';

      // Create PROPFIND request for principal-collection-set property
      final propfind = Propfind(
        prop: Prop(properties: {'principal-collection-set'}),
      );

      String body = propfind.toXml();

      http.Response response = await _makeRequest(
        'PROPFIND',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final xmlString = _decodeBodyStringIfCompressed(response);
        final resources = ms_parser.parseMultistatusResources(xmlString);
        final collections = <String>[];

        for (final resource in resources) {
          final principalCollectionSet =
              resource.customProperties['principal-collection-set'];
          if (principalCollectionSet != null &&
              principalCollectionSet.isNotEmpty) {
            final doc = xml.XmlDocument.parse(principalCollectionSet);
            for (final el in doc.findAllElements('href')) {
              final href = el.innerText.trim();
              if (href.isNotEmpty) collections.add(href);
            }
          }
        }

        return collections;
      } else {
        throw WebDAVException(
          'Failed to get principal collection set: ${response.statusCode} - ${response.reasonPhrase}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Error getting principal collection set',
        cause: e,
      );
    }
  }

  @override
  void enableCompression() {
    _compressionEnabled = true;
    _defaultHeaders['Accept-Encoding'] = 'gzip, deflate';
  }

  @override
  void disableCompression() {
    _compressionEnabled = false;
    _defaultHeaders.remove('Accept-Encoding');
  }

  /// Build request headers including authentication and other defaults
  Map<String, String> _buildHeaders() {
    Map<String, String> headers = Map.from(_defaultHeaders);

    // Use custom authentication handler if available
    if (_preemptiveAuth && _authHandler != null) {
      try {
        // Create a dummy HttpRequest for the auth handler with actual URL context
        final dummyRequest = _createDummyRequest();
        String? authHeader = _authHandler!.getPreemptiveAuth(dummyRequest);
        if (authHeader != null) {
          headers['Authorization'] = authHeader;
        }

        // Add workstation information if available (for NTLM compatibility)
        if (_workstation != null && _workstation!.isNotEmpty) {
          headers['X-Workstation'] = _workstation!;
        }
      } catch (e) {
        // If auth handler fails, fall back to basic auth if available
        if (_username != null && _password != null) {
          String username = _username!;
          if (_domain != null && _domain!.isNotEmpty) {
            username = '$_domain\\$_username';
          }
          headers['Authorization'] = WebDAVUtil.basicAuth(username, _password!);
        }
      }
    } else if (_preemptiveAuth && _username != null && _password != null) {
      // Fall back to basic auth for backward compatibility
      String username = _username!;
      if (_domain != null && _domain!.isNotEmpty) {
        username = '$_domain\\$_username';
      }
      headers['Authorization'] = WebDAVUtil.basicAuth(username, _password!);

      // Add workstation information if available (for NTLM compatibility)
      if (_workstation != null && _workstation!.isNotEmpty) {
        headers['X-Workstation'] = _workstation!;
      }
    }

    // Apply compression settings
    if (_compressionEnabled) {
      headers['Accept-Encoding'] = 'gzip, deflate';
    }

    // Ensure cookies are not sent when ignored
    if (_ignoreCookies) {
      headers.remove('Cookie');
      headers.remove('cookie');
    }

    return headers;
  }

  /// Create a dummy HttpRequest for authentication handler
  HttpRequest _createDummyRequest([String? url, String? method]) {
    // This is a simplified dummy request for auth handlers
    // In a real implementation, you might want to pass more context
    return _DummyHttpRequest(url, method);
  }

  /// Create an HttpRequest from response for authentication challenge handling
  HttpRequest _createHttpRequestFromResponse(
    http.Response response,
    String requestUrl, [
    String? method,
  ]) {
    // Create a dummy request with challenge information from response
    return _ChallengeHttpRequest(response, requestUrl, method);
  }

  /// Make an HTTP request with proper error handling
  Future<http.Response> _makeRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    String? body,
    Uint8List? bodyBytes,
  }) async {
    final resolvedUrl = _resolveUrl(url);
    try {
      http.Request request = http.Request(method, Uri.parse(resolvedUrl));

      if (headers != null) {
        request.headers.addAll(headers);
      }

      if (body != null) {
        request.body = body;
      } else if (bodyBytes != null) {
        request.bodyBytes = bodyBytes;
      }

      http.StreamedResponse streamedResponse = await _client.send(request);
      http.Response response = await http.Response.fromStream(streamedResponse);

      // Handle authentication challenges
      if (response.statusCode == 401) {
        // Try to handle authentication challenge with auth handler
        if (_authHandler != null) {
          try {
            String? authHeader = await _authHandler!.handleChallenge(
              resolvedUrl,
              _createHttpRequestFromResponse(response, resolvedUrl, method),
            );
            if (authHeader != null) {
              // Retry with authentication
              http.Request retryRequest = http.Request(
                method,
                Uri.parse(resolvedUrl),
              );
              retryRequest.headers.addAll(headers ?? {});
              retryRequest.headers['Authorization'] = authHeader;

              if (body != null) {
                retryRequest.body = body;
              } else if (bodyBytes != null) {
                retryRequest.bodyBytes = bodyBytes;
              }

              streamedResponse = await _client.send(retryRequest);
              response = await http.Response.fromStream(streamedResponse);
            }
          } catch (e) {
            // If auth handler fails, fall back to basic auth
            if (!_preemptiveAuth && _username != null && _password != null) {
              http.Request retryRequest = http.Request(
                method,
                Uri.parse(resolvedUrl),
              );
              retryRequest.headers.addAll(headers ?? {});

              String username = _username!;
              if (_domain != null && _domain!.isNotEmpty) {
                username = '$_domain\\$_username';
              }
              retryRequest.headers['Authorization'] = WebDAVUtil.basicAuth(
                username,
                _password!,
              );

              if (body != null) {
                retryRequest.body = body;
              } else if (bodyBytes != null) {
                retryRequest.bodyBytes = bodyBytes;
              }

              streamedResponse = await _client.send(retryRequest);
              response = await http.Response.fromStream(streamedResponse);
            }
          }
        } else if (!_preemptiveAuth && _username != null && _password != null) {
          // Fallback to basic auth for backward compatibility
          http.Request retryRequest = http.Request(
            method,
            Uri.parse(resolvedUrl),
          );
          retryRequest.headers.addAll(headers ?? {});

          String username = _username!;
          if (_domain != null && _domain!.isNotEmpty) {
            username = '$_domain\\$_username';
          }
          retryRequest.headers['Authorization'] = WebDAVUtil.basicAuth(
            username,
            _password!,
          );

          if (body != null) {
            retryRequest.body = body;
          } else if (bodyBytes != null) {
            retryRequest.bodyBytes = bodyBytes;
          }

          streamedResponse = await _client.send(retryRequest);
          response = await http.Response.fromStream(streamedResponse);
        }
      }

      return response;
    } catch (e) {
      throw WebDAVNetworkException('HTTP request failed', cause: e);
    }
  }

  // Decode response body bytes if Content-Encoding indicates compression
  Uint8List _decodeBodyBytesIfCompressed(http.Response response) {
    try {
      final encoding =
          response.headers['content-encoding']?.toLowerCase() ?? '';
      final bytes = response.bodyBytes;
      if (encoding.contains('gzip')) {
        final decoded = GZipCodec().decode(bytes);
        return Uint8List.fromList(decoded);
      }
      if (encoding.contains('deflate')) {
        final decoded = ZLibCodec(raw: true).decode(bytes);
        return Uint8List.fromList(decoded);
      }
      return bytes;
    } catch (_) {
      return response.bodyBytes;
    }
  }

  // Decode response body to UTF-8 string considering compression
  String _decodeBodyStringIfCompressed(http.Response response) {
    final bytes = _decodeBodyBytesIfCompressed(response);
    return utf8.decode(bytes, allowMalformed: true);
  }

  // Resolve a specific version by first locating version-history like Java implementation
  Future<Uint8List> _getSpecificVersion(String url, String version) async {
    try {
      // Discover version-history
      final propfind = Propfind(prop: Prop(properties: {'version-history'}));
      final headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = '0';
      final response = await _makeRequest(
        'PROPFIND',
        url,
        headers: headers,
        body: propfind.toXml(),
      );
      if (response.statusCode != 207) {
        // Fallback to header-based versioning
        return getWithHeaders(url, {'DAV:version': version});
      }
      final xmlString = _decodeBodyStringIfCompressed(response);
      final resources = ms_parser.parseMultistatusResources(xmlString);
      if (resources.isEmpty) {
        return getWithHeaders(url, {'DAV:version': version});
      }
      final storageUrl = resources.first.customProperties['version-history'];
      if (storageUrl == null || storageUrl.isEmpty) {
        return getWithHeaders(url, {'DAV:version': version});
      }
      final resolved = WebDAVUtil.joinPaths(storageUrl, version);
      return get(resolved);
    } catch (_) {
      // Fallback
      return getWithHeaders(url, {'DAV:version': version});
    }
  }

  // Deprecated: moved to parser/multistatus_parser.dart

  // Deprecated: moved to parser/multistatus_parser.dart

  /// Create DavQuota from DavResource
  DavQuota _createDavQuotaFromResource(DavResource resource) {
    // Extract quota information from custom properties
    final properties = resource.customProperties;

    // Parse quota-available-bytes
    int? availableBytes;
    final availableStr = properties['quota-available-bytes'];
    if (availableStr != null && availableStr.isNotEmpty) {
      availableBytes = int.tryParse(availableStr);
    }

    // Parse quota-used-bytes
    int? usedBytes;
    final usedStr = properties['quota-used-bytes'];
    if (usedStr != null && usedStr.isNotEmpty) {
      usedBytes = int.tryParse(usedStr);
    }

    return DavQuota(
      quotaAvailableBytes: availableBytes ?? double.maxFinite.toInt(),
      quotaUsedBytes: usedBytes ?? 0,
      resourceUrl: resource.href.toString(),
    );
  }

  /// Put a resource under version control (RFC 3253)
  /// Makes a resource versionable by creating a version history
  @override
  Future<void> versionControl(String url, {String? initialVersion}) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      final versionControl = VersionControl(version: initialVersion);
      String body = versionControl.toXml();

      http.Response response = await _makeRequest(
        'VERSION-CONTROL',
        url,
        headers: headers,
        body: body,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException.fromResponse(
          'VERSION-CONTROL failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Network error during VERSION-CONTROL',
        cause: e,
      );
    }
  }

  /// Check out a version-controlled resource for editing
  /// Returns the URL of the working resource
  @override
  Future<String> checkout(String url, {String? activity}) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      final checkout = Checkout(activitySet: activity);
      String body = checkout.toXml();

      http.Response response = await _makeRequest(
        'CHECKOUT',
        url,
        headers: headers,
        body: body,
      );

      if (WebDAVUtil.isSuccessStatus(response.statusCode)) {
        // Extract working resource URL from Location header or response body
        String? location = response.headers['location'];
        if (location != null) {
          return location;
        }

        // If no Location header, try to parse from response body
        if (response.body.isNotEmpty) {
          final doc = xml.XmlDocument.parse(response.body);
          final href = xh.textOfFirstDescendant(doc.rootElement, 'href');
          if (href != null && href.isNotEmpty) return href;
        }

        return url; // Fallback to original URL
      } else {
        throw WebDAVException.fromResponse(
          'CHECKOUT failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during CHECKOUT', cause: e);
    }
  }

  /// Check in a checked-out resource to create a new version
  /// Returns the URL of the new version
  @override
  Future<String> checkin(String url, {bool keepCheckedOut = false}) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      final checkin = Checkin(keepCheckedOut: keepCheckedOut);
      String body = checkin.toXml();

      http.Response response = await _makeRequest(
        'CHECKIN',
        url,
        headers: headers,
        body: body,
      );

      if (WebDAVUtil.isSuccessStatus(response.statusCode)) {
        // Extract version URL from Location header or response body
        String? location = response.headers['location'];
        if (location != null) {
          return location;
        }

        // If no Location header, try to parse from response body
        if (response.body.isNotEmpty) {
          final doc = xml.XmlDocument.parse(response.body);
          final href = xh.textOfFirstDescendant(doc.rootElement, 'href');
          if (href != null && href.isNotEmpty) return href;
        }

        return url; // Fallback to original URL
      } else {
        throw WebDAVException.fromResponse(
          'CHECKIN failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during CHECKIN', cause: e);
    }
  }

  /// Cancel a checkout operation
  /// Reverts the working resource to its pre-checkout state
  @override
  Future<void> uncheckout(String url) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      final uncheckout = Uncheckout();
      String body = uncheckout.toXml();

      http.Response response = await _makeRequest(
        'UNCHECKOUT',
        url,
        headers: headers,
        body: body,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException.fromResponse(
          'UNCHECKOUT failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during UNCHECKOUT', cause: e);
    }
  }

  /// Put a collection under baseline control
  /// Enables baseline management for version-controlled collections
  @override
  Future<void> baselineControl(String url, {String? initialBaseline}) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      final baselineControl = BaselineControl(baseline: initialBaseline);
      String body = baselineControl.toXml();

      http.Response response = await _makeRequest(
        'BASELINE-CONTROL',
        url,
        headers: headers,
        body: body,
      );

      if (!WebDAVUtil.isSuccessStatus(response.statusCode)) {
        throw WebDAVException.fromResponse(
          'BASELINE-CONTROL failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Network error during BASELINE-CONTROL',
        cause: e,
      );
    }
  }

  /// Create a new baseline from a baseline-controlled collection
  /// Returns the URL of the new baseline
  @override
  Future<String> makeBaseline(String url) async {
    try {
      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';

      final mkBaseline = MkBaseline();
      String body = mkBaseline.toXml();

      http.Response response = await _makeRequest(
        'MKBASELINE',
        url,
        headers: headers,
        body: body,
      );

      if (WebDAVUtil.isSuccessStatus(response.statusCode)) {
        // Extract baseline URL from Location header
        String? location = response.headers['location'];
        if (location != null) {
          return location;
        }

        // If no Location header, try to parse from response body
        if (response.body.isNotEmpty) {
          final hrefMatch = RegExp(
            r'<D:href>([^<]+)</D:href>',
          ).firstMatch(response.body);
          if (hrefMatch != null) {
            return hrefMatch.group(1) ?? url;
          }
        }

        return url; // Fallback to original URL
      } else {
        throw WebDAVException.fromResponse(
          'MKBASELINE failed',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException('Network error during MKBASELINE', cause: e);
    }
  }

  /// Get version history for a version-controlled resource
  /// Returns a list of version URLs
  @override
  Future<List<String>> getVersionHistory(String url) async {
    try {
      // Use PROPFIND to request version-history property
      final propfind = Propfind(prop: Prop(properties: {'version-history'}));

      Map<String, String> headers = _buildHeaders();
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Depth'] = '0';

      String body = propfind.toXml();

      http.Response response = await _makeRequest(
        'PROPFIND',
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 207) {
        final multistatus = Multistatus.fromXml(response.body);
        if (multistatus.responses.isNotEmpty) {
          final firstResponse = multistatus.responses.first;
          for (final propstat in firstResponse.propstats) {
            if (propstat.status.contains('200')) {
              // Extract version history from properties
              final versionHistory =
                  propstat.prop.customProperties['version-history'];
              if (versionHistory != null) {
                return _parseVersionHistory(versionHistory);
              }
            }
          }
        }
        return [];
      } else {
        throw WebDAVException.fromResponse(
          'Failed to get version history',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is WebDAVException) rethrow;
      throw WebDAVNetworkException(
        'Network error during version history retrieval',
        cause: e,
      );
    }
  }

  /// Parse version history XML and return list of version URLs
  List<String> _parseVersionHistory(String xmlString) {
    try {
      final doc = xml.XmlDocument.parse(xmlString);
      final versions = <String>[];
      final hrefEls = xh.descendantsByLocalName(doc, 'href');
      for (final h in hrefEls) {
        final v = h.innerText.trim();
        if (v.isNotEmpty) versions.add(v);
      }
      return versions;
    } catch (_) {
      return [];
    }
  }

  @override
  void ignoreCookies() {
    // Ensure we do not send Cookie headers on subsequent requests
    _ignoreCookies = true;
  }

  @override
  void enablePreemptiveAuthentication(String hostname) {
    enablePreemptiveAuthenticationWithPorts(hostname, 80, 443);
  }

  @override
  void enablePreemptiveAuthenticationWithPorts(
    String hostname,
    int httpPort,
    int httpsPort,
  ) {
    // Enable preemptive authentication for the specified hostname and ports
    _preemptiveAuth = true;
    // In a full implementation, you would store the hostname and ports
    // and use them to determine when to send authentication headers
  }

  @override
  void disablePreemptiveAuthentication() {
    _preemptiveAuth = false;
  }

  @override
  void shutdown() {
    _client.close();
  }

  /// Dispose of resources
  void dispose() {
    shutdown();
  }

  /// Test helper method to access headers for testing domain authentication
  @visibleForTesting
  Map<String, String> buildHeadersForTest() {
    return _buildHeaders();
  }
}

/// Internal report class for version tree queries
class _VersionTreeReport implements WebDAVReport<List<DavResource>> {
  final VersionTree versionTree;
  final HttpWebdavClient client;

  _VersionTreeReport(this.versionTree, this.client);

  @override
  String toXml() {
    return versionTree.toXml();
  }

  @override
  String generateRequestBody() => toXml();

  @override
  String? getDepth() => null;

  @override
  Map<String, String> getHeaders() => {};

  @override
  List<DavResource> parseResponse(String xmlResponse) {
    // Parse the version tree response using the client's parser
    return ms_parser.parseMultistatusResources(xmlResponse);
  }
}

/// Simple dummy HttpRequest implementation for authentication handlers
class _DummyHttpRequest implements HttpRequest {
  final String? _url;
  final String? _method;

  _DummyHttpRequest([this._url, this._method]);

  @override
  String get method => _method ?? 'GET';

  @override
  Uri get uri => Uri.parse(_url ?? 'http://localhost/');

  @override
  HttpHeaders get headers => _DummyHttpHeaders();

  @override
  // ignore: override_on_non_overriding_member
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// HttpRequest implementation for authentication challenge handling
class _ChallengeHttpRequest implements HttpRequest {
  final http.Response _response;
  final String _requestUrl;
  final String? _method;

  _ChallengeHttpRequest(this._response, this._requestUrl, [this._method]);

  @override
  String get method => _method ?? 'GET';

  @override
  Uri get uri => Uri.parse(_requestUrl);

  @override
  HttpHeaders get headers => _ChallengeHttpHeaders(_response);

  @override
  // ignore: override_on_non_overriding_member
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Simple dummy HttpHeaders implementation
class _DummyHttpHeaders implements HttpHeaders {
  @override
  // ignore: override_on_non_overriding_member
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// HttpHeaders implementation for authentication challenge handling
class _ChallengeHttpHeaders implements HttpHeaders {
  final http.Response _response;

  _ChallengeHttpHeaders(this._response);

  @override
  String? value(String name) {
    return _response.headers[name.toLowerCase()];
  }

  @override
  List<String>? operator [](String name) {
    final value = _response.headers[name.toLowerCase()];
    return value != null ? [value] : null;
  }

  @override
  // ignore: override_on_non_overriding_member
  dynamic noSuchMethod(Invocation invocation) => null;
}
