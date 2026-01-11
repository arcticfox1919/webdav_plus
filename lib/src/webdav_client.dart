import 'dart:io';
import 'dart:typed_data';
import 'dav_resource.dart';
import 'dav_ace.dart';
import 'dav_acl.dart';
import 'dav_principal.dart';
import 'dav_quota.dart';
import 'model/lock.dart';
import 'report/webdav_report.dart';
import 'impl/http_webdav_client.dart';
import 'auth/authentication_handler.dart';

/// WebDAV Client Interface
///
/// Provides a complete WebDAV client interface following WebDAV protocol specifications.
/// Supports file operations, property management, locking, and ACL operations.
abstract interface class WebdavClient {
  /// Factory constructor - creates basic client
  factory WebdavClient() => HttpWebdavClient();

  /// Factory constructor - creates client with authentication
  factory WebdavClient.withCredentials(
    String username,
    String password, {
    bool isPreemptive = false,
  }) => HttpWebdavClient.withCredentials(
    username,
    password,
    isPreemptive: isPreemptive,
  );

  /// Factory constructor - creates client with compression support
  factory WebdavClient.withCompression() => HttpWebdavClient.withCompression();

  /// Factory constructor - creates fully configured client
  factory WebdavClient.configured({
    String? username,
    String? password,
    bool isPreemptive = false,
    bool compression = false,
  }) => HttpWebdavClient.configured(
    username: username,
    password: password,
    isPreemptive: isPreemptive,
    compression: compression,
  );

  /// Add authentication credentials
  ///
  /// Sets [username] and [password] for authentication.
  /// If [isPreemptive] is true, credentials will be sent with the first request.
  void setCredentials(
    String username,
    String password, {
    bool isPreemptive = false,
  });

  /// Add authentication credentials with domain (for NTLM authentication)
  ///
  /// Sets [username], [password], [domain] and [workstation] for NTLM authentication.
  /// If [isPreemptive] is true, credentials will be sent with the first request.
  ///
  /// Note: This provides Basic authentication with domain\username format.
  /// For true NTLM authentication, use [setAuthenticationHandler] with an NTLM handler.
  void setCredentialsWithDomain(
    String username,
    String password,
    String domain,
    String workstation, {
    bool isPreemptive = false,
  });

  /// Set custom authentication handler
  ///
  /// Allows setting a custom authentication handler for advanced authentication
  /// schemes like NTLM, Kerberos, Digest, or OAuth.
  ///
  /// Example for NTLM:
  /// ```dart
  /// client.setAuthenticationHandler(
  ///   MyNTLMHandler(
  ///     username: 'user',
  ///     password: 'pass',
  ///     domain: 'DOMAIN',
  ///     workstation: 'WORKSTATION',
  ///   ),
  ///   isPreemptive: false, // NTLM requires challenge-response
  /// );
  /// ```
  void setAuthenticationHandler(
    AuthenticationHandler handler, {
    bool isPreemptive = false,
  });

  /// Remove all authentication settings
  ///
  /// Clears both basic credentials and custom authentication handlers.
  void clearAuthentication();

  /// List directory contents using WebDAV PROPFIND
  ///
  /// Returns a list of resources for [url], including the parent resource itself.
  Future<List<DavResource>> list(String url);

  /// List directory contents using WebDAV PROPFIND with depth
  ///
  /// Returns a list of resources for [url] with specified [depth]:
  /// - 0 for single resource
  /// - 1 for directory listing
  /// - -1 for infinite recursion
  Future<List<DavResource>> listWithDepth(String url, int depth);

  /// List directory contents using WebDAV PROPFIND with properties
  ///
  /// Returns a list of resources for [url] with specified [depth] and [props].
  /// Additional properties in [props] will be requested from the server.
  Future<List<DavResource>> listWithProps(
    String url,
    int depth,
    Set<String> props,
  );

  /// List directory contents using WebDAV PROPFIND with allprop option
  ///
  /// Returns a list of resources for [url] with specified [depth].
  /// If [allProp] is true, all properties will be requested (can be inefficient).
  Future<List<DavResource>> listWithAllProp(
    String url,
    int depth,
    bool allProp,
  );

  /// Gets versions listing of resource
  ///
  /// Returns a list of version resources for [url].
  Future<List<DavResource>> versionsList(String url);

  /// Gets versions listing of resource with depth
  ///
  /// Returns a list of version resources for [url] with specified [depth].
  Future<List<DavResource>> versionsListWithDepth(String url, int depth);

  /// Gets versions listing of resource with depth and properties
  ///
  /// Returns a list of version resources for [url] with specified [depth] and [props].
  Future<List<DavResource>> versionsListWithProps(
    String url,
    int depth,
    Set<String> props,
  );

  /// Get resources using WebDAV PROPFIND. Only retrieves specified properties
  ///
  /// Returns a list of resources for [url] with specified [depth] and [props].
  /// Only the properties specified in [props] will be retrieved.
  Future<List<DavResource>> propfind(String url, int depth, Set<String> props);

  /// Run a report on a given resource (using WebDAV REPORT)
  ///
  /// Executes [report] on [url] with specified [depth].
  /// Returns report results wrapped in a report-specific result object.
  Future<T> report<T>(String url, int depth, WebDAVReport<T> report);

  /// Perform a search of the WebDAV repository
  ///
  /// Searches from [url] base resource using [query] in specified [language].
  /// Returns a list of matching resources.
  Future<List<DavResource>> search(String url, String language, String query);

  /// Add custom properties for a url WebDAV PROPPATCH
  ///
  /// Adds properties in [addProps] to the resource at [url].
  /// If a property already exists, its value is replaced.
  /// Returns the patched resources from the response.
  Future<List<DavResource>> patch(String url, Map<String, String> addProps);

  /// Add or remove custom properties for a url using WebDAV PROPPATCH
  ///
  /// Adds properties in [addProps] and removes properties in [removeProps]
  /// for the resource at [url]. If a property already exists, its value is replaced.
  /// Specifying removal of a non-existent property is not an error.
  /// Returns the patched resources from the response.
  Future<List<DavResource>> patchWithRemove(
    String url,
    Map<String, String> addProps,
    List<String> removeProps,
  );

  /// Add or remove custom properties using WebDAV PROPPATCH with additional headers
  ///
  /// Adds properties in [addProps] and removes properties in [removeProps]
  /// for the resource at [url], and includes custom HTTP [headers] on the request.
  /// Returns the patched resources from the response.
  Future<List<DavResource>> patchWithHeaders(
    String url,
    Map<String, String> addProps,
    List<String> removeProps,
    Map<String, String> headers,
  );

  /// Uses HTTP GET to download data from a server
  ///
  /// Downloads data from the resource at [url].
  /// Returns the data as a byte array.
  Future<Uint8List> get(String url);

  /// Uses HTTP GET to download specific version of data from a server
  ///
  /// Downloads data from the specific [version] of resource at [url].
  /// Returns the data as a byte array.
  Future<Uint8List> getVersion(String url, String version);

  /// Uses HTTP GET to download data from a server
  ///
  /// Downloads data from the resource at [url] with additional [headers].
  /// Returns the data as a byte array.
  Future<Uint8List> getWithHeaders(String url, Map<String, String> headers);

  /// Uses HTTP GET to download data as a stream (for large files)
  ///
  /// Downloads data from the resource at [url] as a stream.
  /// Returns a Stream of byte chunks, suitable for large file downloads.
  /// The caller is responsible for consuming and closing the stream.
  Future<Stream<List<int>>> getStream(String url);

  /// Uses HTTP GET to download data as a stream with headers (for large files)
  ///
  /// Downloads data from the resource at [url] with additional [headers] as a stream.
  /// Returns a Stream of byte chunks, suitable for large file downloads.
  Future<Stream<List<int>>> getStreamWithHeaders(
    String url,
    Map<String, String> headers,
  );

  /// Download a file directly to disk with progress tracking (for large files)
  ///
  /// Downloads the resource at [url] directly to [savePath].
  /// [onProgress] callback receives (bytesReceived, totalBytes) for progress tracking.
  /// If totalBytes is -1, the content length is unknown.
  Future<File> downloadToFile(
    String url,
    String savePath, {
    void Function(int bytesReceived, int totalBytes)? onProgress,
  });

  /// Uses HTTP PUT to send data to a server
  ///
  /// Uploads [data] to the resource at [url].
  Future<void> put(String url, Uint8List data);

  /// Uses PUT to send data to a server with a specific content type header
  ///
  /// Uploads [data] to the resource at [url] with specified [contentType] MIME type.
  Future<void> putWithContentType(
    String url,
    Uint8List data,
    String contentType,
  );

  /// Uses PUT to upload file to a server with specific contentType
  ///
  /// Uploads [localFile] to the resource at [url] with specified [contentType] MIME type.
  Future<void> putFile(String url, File localFile, String contentType);

  /// Uses PUT to upload file to a server with specific contentType
  ///
  /// Uploads [localFile] to the resource at [url] with specified [contentType] MIME type.
  /// If [expectContinue] is true, enables Expect: continue header for PUT requests.
  Future<void> putFileWithExpect(
    String url,
    File localFile,
    String contentType,
    bool expectContinue,
  );

  /// Uses PUT to upload file to a server with specific contentType
  ///
  /// Uploads [localFile] to the resource at [url] with specified [contentType] MIME type.
  /// If [expectContinue] is true, enables Expect: continue header for PUT requests.
  /// Uses [lockToken] to identify a particular lock for the operation.
  Future<void> putFileWithLock(
    String url,
    File localFile,
    String contentType,
    bool expectContinue,
    String lockToken,
  );

  /// Uses PUT to send data to a server with specific headers
  ///
  /// Uploads data to the resource at [url] with additional [headers].
  Future<void> putWithHeaders(
    String url,
    Uint8List data,
    Map<String, String> headers,
  );

  /// Uses PUT to send data to a server with content length
  ///
  /// Uploads [data] to the resource at [url] with specified [contentType] and [contentLength].
  /// If [expectContinue] is true, enables Expect: continue header for PUT requests.
  Future<void> putWithContentLength(
    String url,
    Uint8List data,
    String contentType,
    bool expectContinue,
    int contentLength,
  );

  /// Uses PUT to upload data from a stream (for large files)
  ///
  /// Uploads data from [dataStream] to the resource at [url].
  /// [contentLength] must be provided for the Content-Length header.
  /// [contentType] specifies the MIME type.
  /// Suitable for large file uploads without loading entire file into memory.
  Future<void> putStream(
    String url,
    Stream<List<int>> dataStream,
    int contentLength,
    String contentType,
  );

  /// Upload a file using streaming (for large files) with progress tracking
  ///
  /// Uploads [localFile] to the resource at [url] using streaming.
  /// [onProgress] callback receives (bytesSent, totalBytes) for progress tracking.
  /// Does not load the entire file into memory.
  Future<void> putFileStream(
    String url,
    File localFile,
    String contentType, {
    void Function(int bytesSent, int totalBytes)? onProgress,
  });

  /// Delete a resource using HTTP DELETE at the specified url
  ///
  /// Deletes the resource at [url].
  Future<void> delete(String url);

  /// Delete a resource using HTTP DELETE with additional headers
  ///
  /// Deletes the resource at [url] with additional [headers].
  Future<void> deleteWithHeaders(String url, Map<String, String> headers);

  /// Uses WebDAV MKCOL to create a directory at the specified url
  ///
  /// Creates a directory at [url].
  Future<void> createDirectory(String url);

  /// Move a url to from source to destination using WebDAV MOVE. Assumes overwrite.
  ///
  /// Moves resource from [sourceUrl] to [destinationUrl], overwriting if destination exists.
  Future<void> move(String sourceUrl, String destinationUrl);

  /// Move a url to from source to destination using WebDAV MOVE
  ///
  /// Moves resource from [sourceUrl] to [destinationUrl].
  /// If [overwrite] is true, overwrites destination if it exists.
  Future<void> moveWithOverwrite(
    String sourceUrl,
    String destinationUrl,
    bool overwrite,
  );

  /// Move a url to from source to destination using WebDAV MOVE
  ///
  /// Moves resource from [sourceUrl] to [destinationUrl].
  /// If [overwrite] is true, overwrites destination if it exists.
  /// Uses [lockToken] to identify a particular lock for the operation.
  Future<void> moveWithLock(
    String sourceUrl,
    String destinationUrl,
    bool overwrite,
    String lockToken,
  );

  /// Move a url to from source to destination using WebDAV MOVE with headers
  ///
  /// Moves resource from [sourceUrl] to [destinationUrl].
  /// If [overwrite] is true, overwrites destination if it exists.
  /// Uses additional [headers] for the request.
  Future<void> moveWithHeaders(
    String sourceUrl,
    String destinationUrl,
    bool overwrite,
    Map<String, String> headers,
  );

  /// Copy a url from source to destination using WebDAV COPY. Assumes overwrite.
  ///
  /// Copies resource from [sourceUrl] to [destinationUrl], overwriting if destination exists.
  Future<void> copy(String sourceUrl, String destinationUrl);

  /// Copy a url from source to destination using WebDAV COPY
  ///
  /// Copies resource from [sourceUrl] to [destinationUrl].
  /// If [overwrite] is true, overwrites destination if it exists.
  Future<void> copyWithOverwrite(
    String sourceUrl,
    String destinationUrl,
    bool overwrite,
  );

  /// Copy a url from source to destination using WebDAV COPY with headers
  ///
  /// Copies resource from [sourceUrl] to [destinationUrl].
  /// If [overwrite] is true, overwrites destination if it exists.
  /// Uses additional [headers] for the request.
  Future<void> copyWithHeaders(
    String sourceUrl,
    String destinationUrl,
    bool overwrite,
    Map<String, String> headers,
  );

  /// Performs a HTTP HEAD request to see if a resource exists or not
  ///
  /// Checks if the resource at [url] exists.
  /// Returns false for any status code outside of the 200-299 range.
  Future<bool> exists(String url);

  /// Put an exclusive write lock on this resource
  ///
  /// Creates an exclusive write lock on the resource at [url]. A write lock prevents
  /// principals without the lock from executing PUT, POST, PROPPATCH, LOCK, UNLOCK,
  /// MOVE, DELETE, or MKCOL on the locked resource. Other operations like GET function
  /// independently of the lock.
  ///
  /// A WebDAV compliant server is not required to support locking. If the server does
  /// support locking, it may choose to support any combination of exclusive and shared
  /// locks for any access types.
  ///
  /// Returns the lock token to unlock this resource. A lock token is a type of state
  /// token, represented as a URI, which identifies a particular lock. A lock token is
  /// returned by every successful LOCK operation in the lockdiscovery property in the
  /// response body, and can also be found through lock discovery on a resource.
  Future<String> lock(String url);

  /// Put an exclusive write lock on this resource with timeout
  ///
  /// Creates an exclusive write lock on the resource at [url] with specified [timeout].
  /// The [timeout] is measured in seconds remaining until lock expiration.
  /// Returns the lock token to unlock this resource.
  Future<String> lockWithTimeout(String url, int timeout);

  /// Refresh a lock to restart its timers
  ///
  /// A LOCK request with no request body is a "LOCK refresh" request. Its purpose is
  /// to restart all timers associated with a lock. The request must include an "If"
  /// header that contains the lock tokens of the locks to be refreshed (note there
  /// may be multiple in the case of shared locks).
  ///
  /// Uses [token] to identify the lock on the resource at [url].
  /// The [file] parameter specifies the name of the file at the end of the url.
  /// Returns the lock token to unlock this resource.
  Future<String> refreshLock(String url, String token, String file);

  /// Unlock the resource
  ///
  /// Unlocks the resource at [url] using the specified [token].
  /// A WebDAV compliant server is not required to support locking. If the server does
  /// support locking, it may choose to support any combination of exclusive and shared
  /// locks for any access types.
  Future<void> unlock(String url, String token);

  /// Read access control list for resource
  ///
  /// Returns the current ACL set on the resource at [url].
  Future<DavAcl> getAcl(String url);

  /// Read quota properties for resource
  ///
  /// Returns the current quota and size properties for the resource at [url].
  Future<DavQuota> getQuota(String url);

  /// Write access control list for resource
  ///
  /// Sets the access control list for the resource at [url] using the specified [aces].
  Future<void> setAcl(String url, List<DavAce> aces);

  /// List the principals that can be used to set ACLs on given url
  ///
  /// Returns a list of principals (in the form of URLs according to spec) that can be
  /// used to set ACLs on the resource at [url].
  Future<List<DavPrincipal>> getPrincipals(String url);

  /// The principals that are available on the server that implements this resource
  ///
  /// Returns the URLs in DAV:principal-collection-set for the resource at [url].
  Future<List<String>> getPrincipalCollectionSet(String url);

  /// Read current user privileges for resource
  ///
  /// Returns the current user privileges for the resource at [url].
  Future<List<String>> getCurrentUserPrivileges(String url);

  /// Check if the current user has a specific privilege
  ///
  /// Returns true if the current user has the specified [privilege] on the resource at [url].
  Future<bool> hasPrivilege(String url, String privilege);

  /// Validate that the current user has all specified privileges
  ///
  /// Returns a map indicating which of the specified [privileges] the current user has
  /// on the resource at [url]. The map keys are privilege names and values indicate
  /// whether the user has that privilege.
  Future<Map<String, bool>> validatePrivileges(
    String url,
    List<String> privileges,
  );

  /// Discover locks on a resource
  ///
  /// Returns detailed lock information for the resource at [url].
  Future<List<Activelock>> discoverLocks(String url);

  /// Check if a resource is locked
  ///
  /// Returns true if the resource at [url] is locked.
  Future<bool> isLocked(String url);

  /// Get the lock token for a locked resource
  ///
  /// Returns the lock token for the resource at [url], or null if not locked.
  Future<String?> getLockToken(String url);

  /// Synchronize collection
  ///
  /// Performs a synchronization operation on the collection at [url] using the sync [syncToken].
  /// Returns a list of DavResource objects representing the changes since the last sync.
  /// Optionally specify [depth] (default 1), [properties] to retrieve, and [limit] for results.
  Future<List<DavResource>> syncCollection(
    String url,
    String syncToken, {
    int depth = 1,
    List<String>? properties,
    int? limit,
  });

  /// Bind a resource to a collection
  ///
  /// Creates a binding between [sourceUrl] and [targetUrl]. If [overwrite] is true,
  /// any existing binding at the target will be replaced.
  Future<void> bind(String sourceUrl, String targetUrl, bool overwrite);

  /// Unbind a resource from a collection
  ///
  /// Removes the binding at [bindingUrl] for the specified [segment].
  Future<void> unbind(String bindingUrl, String segment);

  /// Put a version under version control
  ///
  /// Places the resource at [url] under version control.
  Future<void> versionControl(String url);

  /// Checkout a version-controlled resource
  ///
  /// Checks out the version-controlled resource at [url].
  Future<void> checkout(String url);

  /// Checkin a version-controlled resource
  ///
  /// Checks in the version-controlled resource at [url] and returns the URL of the new version.
  /// If [keepCheckedOut] is true, the resource remains checked out after creating the version.
  Future<String> checkin(String url, {bool keepCheckedOut = false});

  /// Uncheckout a version-controlled resource
  ///
  /// Cancels the checkout of the version-controlled resource at [url].
  Future<void> uncheckout(String url);

  /// Create a baseline for version-controlled collection
  ///
  /// Creates a baseline for the version-controlled collection at [url].
  Future<void> baselineControl(String url);

  /// Make a baseline from a baseline-controlled collection
  ///
  /// Creates a baseline from the baseline-controlled collection at [url] and returns
  /// the URL of the new baseline.
  Future<String> makeBaseline(String url);

  /// Get version history for a version-controlled resource
  ///
  /// Returns the version history URLs for the version-controlled resource at [url].
  Future<List<String>> getVersionHistory(String url);

  /// Enables HTTP GZIP compression. If enabled, requests originating from this client
  /// will include "gzip" as an "Accept-Encoding" header.
  ///
  /// If the server also supports gzip compression, it should serve the
  /// contents in compressed gzip format and include "gzip" as the
  /// Content-Encoding. If the content encoding is present, this client will
  /// automatically decompress the files upon reception.
  void enableCompression();

  /// Disables support for HTTP compression.
  void disableCompression();

  /// Ignores cookies for HTTP requests.
  void ignoreCookies();

  /// Send a Basic authentication header with each request even before 401 is returned.
  /// Uses default ports: 80 for http and 443 for https
  ///
  /// The [hostname] specifies the hostname to enable preemptive authentication for.
  void enablePreemptiveAuthentication(String hostname);

  /// Send a Basic authentication header with each request even before 401 is returned.
  ///
  /// The [hostname] specifies the hostname to enable preemptive authentication for.
  /// The [httpPort] is the http port to enable preemptive authentication for. -1 for default value.
  /// The [httpsPort] is the https port to enable preemptive authentication for. -1 for default value.
  void enablePreemptiveAuthenticationWithPorts(
    String hostname,
    int httpPort,
    int httpsPort,
  );

  /// Disable preemptive authentication.
  void disablePreemptiveAuthentication();

  /// Releases any resources that might be held open. This is an optional method,
  /// and callers are not expected to call it, but can if they want to explicitly
  /// release any open resources. Once a client has been shutdown, it should not
  /// be used to make any more requests.
  void shutdown();
}
