import 'package:webdav_plus/webdav_plus.dart';
import 'dart:io';
import 'dart:convert';

/// Example of using custom authentication handlers with WebDAV client
void main() async {
  // Create a WebDAV client
  final client = WebdavClient();

  // Example 1: Using Basic Authentication Handler
  print('Example 1: Basic Authentication');
  final basicHandler = BasicAuthenticationHandler(
    username: 'username',
    password: 'password',
  );
  client.setAuthenticationHandler(basicHandler);

  // Example 2: Using Basic Authentication with Domain
  print('Example 2: Basic Authentication with Domain');
  final domainHandler = BasicAuthenticationHandler(
    username: 'username',
    password: 'password',
    domain: 'MYDOMAIN',
  );
  client.setAuthenticationHandler(domainHandler);

  // Example 3: Custom NTLM Authentication Handler
  print('Example 3: Custom NTLM Authentication Handler');
  final ntlmHandler = ExampleNTLMHandler(
    'MYDOMAIN',
    'username',
    'password',
    'WORKSTATION',
  );
  client.setAuthenticationHandler(ntlmHandler);

  // Example 4: Custom OAuth Handler
  print('Example 4: Custom OAuth Handler');
  final oauthHandler = CustomOAuthHandler('your-access-token-here');
  client.setAuthenticationHandler(oauthHandler);

  // Example 5: Clear authentication
  print('Example 5: Clear Authentication');
  client.clearAuthentication();

  print('Authentication examples completed!');
}

/// Example implementation of NTLM authentication handler
/// This is a placeholder - real implementation would use an NTLM library
class ExampleNTLMHandler extends NTLMAuthenticationHandler {
  final String domain;
  final String username;
  final String password;
  final String workstation;

  ExampleNTLMHandler(
    this.domain,
    this.username,
    this.password,
    this.workstation,
  ) : super(
        domain: domain,
        username: username,
        password: password,
        workstation: workstation,
      );

  @override
  String createType1Message() {
    // Placeholder Type 1 message creation
    return 'NTLMSSP Type 1 Message Placeholder';
  }

  @override
  String createType3Message(String type2Challenge) {
    // Placeholder Type 3 message creation
    return 'NTLMSSP Type 3 Message Placeholder (responding to: $type2Challenge)';
  }

  @override
  String? getPreemptiveAuth(HttpRequest request) {
    // NTLM typically doesn't use preemptive auth
    return null;
  }

  @override
  Future<String?> handleChallenge(
    String requestUrl,
    HttpRequest challengeRequest,
  ) async {
    // This is where you would implement NTLM challenge-response
    print('NTLM Challenge received for: $requestUrl');
    print('Domain: $domain, User: $username, Workstation: $workstation');

    // In a real implementation, you would:
    // 1. Parse the challenge from challengeRequest.headers
    // 2. Generate appropriate NTLM response using createType1Message and createType3Message
    // 3. Return the Authorization header value

    // For demo purposes, fall back to basic auth
    final credentials = '$domain\\$username:$password';
    final encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }
}

/// Example of a custom authentication handler for OAuth or other schemes
class CustomOAuthHandler implements AuthenticationHandler {
  final String accessToken;

  CustomOAuthHandler(this.accessToken);

  @override
  String get schemeName => 'Bearer';

  @override
  bool canHandle(String scheme) => scheme.toLowerCase() == 'bearer';

  @override
  String? getPreemptiveAuth(HttpRequest request) {
    return 'Bearer $accessToken';
  }

  @override
  Future<String?> handleChallenge(
    String requestUrl,
    HttpRequest challengeRequest,
  ) async {
    // Handle OAuth token refresh if needed
    print('OAuth challenge received for: $requestUrl');

    // In a real implementation, you might refresh the token here
    // For now, return the same token
    return 'Bearer $accessToken';
  }
}
