import 'dart:io';
import 'dart:convert';

/// Abstract authentication handler for WebDAV client
///
/// Allows implementation of custom authentication schemes including NTLM,
/// Kerberos, OAuth, and other authentication mechanisms.
///
/// This follows the same pattern as Java Sardine's CredentialsProvider
/// and AuthScheme interfaces, allowing pluggable authentication.
abstract class AuthenticationHandler {
  /// Handle authentication challenge from server
  ///
  /// Called when the server returns a 401 Unauthorized response.
  /// The [challenge] contains the WWW-Authenticate header value.
  /// The [request] contains the original request details.
  ///
  /// Returns the Authorization header value, or null if authentication
  /// cannot be handled.
  Future<String?> handleChallenge(String challenge, HttpRequest request);

  /// Get preemptive authentication header if supported
  ///
  /// Called before making the initial request if preemptive authentication
  /// is enabled. Returns the Authorization header value, or null if
  /// preemptive authentication is not supported by this handler.
  String? getPreemptiveAuth(HttpRequest request);

  /// Check if this handler can handle the given authentication scheme
  ///
  /// Returns true if this handler supports the authentication scheme
  /// specified in the [challenge] (e.g., "Basic", "NTLM", "Negotiate").
  bool canHandle(String challenge);

  /// Get the authentication scheme name this handler supports
  ///
  /// Returns the name of the authentication scheme (e.g., "Basic", "NTLM").
  String get schemeName;
}

/// Basic authentication handler
///
/// Implements HTTP Basic authentication as defined in RFC 7617.
/// This is the default authentication method used by most WebDAV servers.
class BasicAuthenticationHandler implements AuthenticationHandler {
  final String username;
  final String password;
  final String? domain;
  final String? workstation;

  BasicAuthenticationHandler({
    required this.username,
    required this.password,
    this.domain,
    this.workstation,
  });

  @override
  Future<String?> handleChallenge(String challenge, HttpRequest request) async {
    if (!canHandle(challenge)) {
      return null;
    }

    return _createBasicAuth();
  }

  @override
  String? getPreemptiveAuth(HttpRequest request) {
    return _createBasicAuth();
  }

  @override
  bool canHandle(String challenge) {
    return challenge.toLowerCase().contains('basic');
  }

  @override
  String get schemeName => 'Basic';

  String _createBasicAuth() {
    String userPart = username;

    // Use domain\username format if domain is specified
    if (domain != null && domain!.isNotEmpty) {
      userPart = '$domain\\$username';
    }

    return _basicAuth(userPart, password);
  }

  String _basicAuth(String username, String password) {
    String credentials = '$username:$password';
    String encoded = base64.encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }
}

/// NTLM authentication handler interface
///
/// This is an abstract base class for NTLM authentication implementations.
/// Users can extend this class to provide their own NTLM implementation
/// using libraries like 'ntlm' package or other NTLM implementations.
abstract class NTLMAuthenticationHandler implements AuthenticationHandler {
  final String username;
  final String password;
  final String domain;
  final String workstation;

  NTLMAuthenticationHandler({
    required this.username,
    required this.password,
    required this.domain,
    required this.workstation,
  });

  @override
  bool canHandle(String challenge) {
    return challenge.toLowerCase().contains('ntlm');
  }

  @override
  String get schemeName => 'NTLM';

  /// Create NTLM Type 1 message
  ///
  /// This should return the base64-encoded NTLM Type 1 message
  /// to initiate the NTLM handshake.
  String createType1Message();

  /// Create NTLM Type 3 message
  ///
  /// This should parse the [type2Challenge] (NTLM Type 2 message from server)
  /// and return the base64-encoded NTLM Type 3 response message.
  String createType3Message(String type2Challenge);

  @override
  Future<String?> handleChallenge(String challenge, HttpRequest request) async {
    if (!canHandle(challenge)) {
      return null;
    }

    // NTLM is a multi-step process
    if (challenge.toLowerCase() == 'ntlm') {
      // Initial challenge - send Type 1 message
      return 'NTLM ${createType1Message()}';
    } else if (challenge.toLowerCase().startsWith('ntlm ')) {
      // Server sent Type 2 challenge - respond with Type 3
      String type2Message = challenge.substring(5); // Remove "NTLM " prefix
      return 'NTLM ${createType3Message(type2Message)}';
    }

    return null;
  }

  @override
  String? getPreemptiveAuth(HttpRequest request) {
    // NTLM cannot be used preemptively as it requires a challenge-response
    return null;
  }
}

/// Digest authentication handler interface
///
/// Abstract base class for HTTP Digest authentication (RFC 7616).
/// Users can implement this to provide Digest authentication support.
abstract class DigestAuthenticationHandler implements AuthenticationHandler {
  final String username;
  final String password;

  DigestAuthenticationHandler({required this.username, required this.password});

  @override
  bool canHandle(String challenge) {
    return challenge.toLowerCase().contains('digest');
  }

  @override
  String get schemeName => 'Digest';

  /// Parse digest challenge and create response
  ///
  /// This should parse the [challenge] string and create appropriate
  /// digest response according to RFC 7616.
  String createDigestResponse(String challenge, HttpRequest request);

  @override
  Future<String?> handleChallenge(String challenge, HttpRequest request) async {
    if (!canHandle(challenge)) {
      return null;
    }

    return createDigestResponse(challenge, request);
  }

  @override
  String? getPreemptiveAuth(HttpRequest request) {
    // Digest authentication requires server challenge
    return null;
  }
}

/// Custom authentication handler interface
///
/// Allows implementation of custom authentication schemes like OAuth,
/// JWT Bearer tokens, or proprietary authentication methods.
abstract class CustomAuthenticationHandler implements AuthenticationHandler {
  /// Custom implementation should override all interface methods
  /// to provide their specific authentication logic.
}

/// Example NTLM implementation using external library
///
/// This is an example of how users would implement NTLM authentication
/// using an external NTLM library (like the 'ntlm' pub package).
///
/// ```dart
/// class ExternalNTLMHandler extends NTLMAuthenticationHandler {
///   ExternalNTLMHandler({
///     required String username,
///     required String password,
///     required String domain,
///     required String workstation,
///   }) : super(
///         username: username,
///         password: password,
///         domain: domain,
///         workstation: workstation,
///       );
///
///   @override
///   String createType1Message() {
///     // Use external NTLM library to create Type 1 message
///     // Example: return ntlm.createType1Message(domain, workstation);
///     throw UnimplementedError('Implement using external NTLM library');
///   }
///
///   @override
///   String createType3Message(String type2Challenge) {
///     // Use external NTLM library to create Type 3 response
///     // Example: return ntlm.createType3Message(type2Challenge, username, password, domain);
///     throw UnimplementedError('Implement using external NTLM library');
///   }
/// }
/// ```
class ExampleNTLMHandler extends NTLMAuthenticationHandler {
  ExampleNTLMHandler({
    required String username,
    required String password,
    required String domain,
    required String workstation,
  }) : super(
         username: username,
         password: password,
         domain: domain,
         workstation: workstation,
       );

  @override
  String createType1Message() {
    // This is a placeholder - users should implement using actual NTLM library
    throw UnimplementedError(
      'NTLM Type 1 message creation must be implemented using an external NTLM library. '
      'Consider using packages like "ntlm" or implement your own NTLM handler.',
    );
  }

  @override
  String createType3Message(String type2Challenge) {
    // This is a placeholder - users should implement using actual NTLM library
    throw UnimplementedError(
      'NTLM Type 3 message creation must be implemented using an external NTLM library. '
      'Consider using packages like "ntlm" or implement your own NTLM handler.',
    );
  }
}
