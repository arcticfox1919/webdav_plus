/// WebDAV exception classes for error handling
///
/// This file defines all the exception types used throughout the WebDAV2 library
/// to provide meaningful error information for different failure scenarios.

import 'model/error.dart';

/// Base class for all WebDAV-related exceptions
class WebDAVException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;
  final Object? cause;
  final List<Error>? errors;

  const WebDAVException(
    this.message, {
    this.statusCode,
    this.responseBody,
    this.cause,
    this.errors,
  });

  /// Factory constructor that parses WebDAV error details from response body
  factory WebDAVException.fromResponse(
    String message,
    int statusCode,
    String responseBody,
  ) {
    List<Error>? errors;
    try {
      if (responseBody.contains('<D:error') ||
          responseBody.contains('<error')) {
        errors = Error.parseErrors(responseBody);
      }
    } catch (e) {
      // Ignore parsing errors, just use the basic exception
    }

    return WebDAVException(
      message,
      statusCode: statusCode,
      responseBody: responseBody,
      errors: errors,
    );
  }

  /// Returns true if this is an HTTP error (statusCode not null)
  bool get isHttpError => statusCode != null;

  /// Returns true if this is a client error (4xx status code)
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Returns true if this is a server error (5xx status code)
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Returns true if this is a not found error (404)
  bool get isNotFoundError => statusCode == 404;

  /// Returns true if this exception contains detailed WebDAV error information
  bool get hasDetailedErrors => errors != null && errors!.isNotEmpty;

  /// Returns a human-readable description of the first error condition
  String? get firstErrorCondition {
    if (hasDetailedErrors) {
      return errors!.first.condition;
    }
    return null;
  }

  @override
  String toString() {
    final buffer = StringBuffer('WebDAVException: $message');
    if (statusCode != null) {
      buffer.write(' (HTTP $statusCode)');
    }
    if (hasDetailedErrors) {
      buffer.write('\nWebDAV Errors:');
      for (final error in errors!) {
        buffer.write('\n  - ${error.condition}');
        if (error.description != null) {
          buffer.write(': ${error.description}');
        }
      }
    } else if (responseBody != null && responseBody!.isNotEmpty) {
      buffer.write('\nResponse: $responseBody');
    }
    if (cause != null) {
      buffer.write('\nCaused by: $cause');
    }
    return buffer.toString();
  }
}

/// Exception thrown when authentication fails
class WebDAVAuthenticationException extends WebDAVException {
  const WebDAVAuthenticationException(
    String message, {
    int? statusCode,
    String? responseBody,
    Object? cause,
  }) : super(
         message,
         statusCode: statusCode,
         responseBody: responseBody,
         cause: cause,
       );

  /// Returns true if this is an authentication error
  bool get isAuthenticationError => true;
}

/// Exception thrown when a resource is not found (404)
class WebDAVNotFoundException extends WebDAVException {
  const WebDAVNotFoundException(
    String message, {
    int? statusCode,
    String? responseBody,
    Object? cause,
  }) : super(
         message,
         statusCode: statusCode,
         responseBody: responseBody,
         cause: cause,
       );
}

/// Exception thrown when access is forbidden (403)
class WebDAVForbiddenException extends WebDAVException {
  const WebDAVForbiddenException(
    String message, {
    int? statusCode,
    String? responseBody,
    Object? cause,
  }) : super(
         message,
         statusCode: statusCode,
         responseBody: responseBody,
         cause: cause,
       );
}

/// Exception thrown when a resource already exists (409)
class WebDAVConflictException extends WebDAVException {
  const WebDAVConflictException(
    String message, {
    int? statusCode,
    String? responseBody,
    Object? cause,
  }) : super(
         message,
         statusCode: statusCode,
         responseBody: responseBody,
         cause: cause,
       );
}

/// Exception thrown for network-related errors
class WebDAVNetworkException extends WebDAVException {
  const WebDAVNetworkException(
    String message, {
    int? statusCode,
    String? responseBody,
    Object? cause,
  }) : super(
         message,
         statusCode: statusCode,
         responseBody: responseBody,
         cause: cause,
       );
}

/// Exception thrown when the server returns an unexpected response
class WebDAVServerException extends WebDAVException {
  const WebDAVServerException(
    String message, {
    int? statusCode,
    String? responseBody,
    Object? cause,
  }) : super(
         message,
         statusCode: statusCode,
         responseBody: responseBody,
         cause: cause,
       );
}

/// Exception thrown when a lock operation fails
class WebDAVLockException extends WebDAVException {
  const WebDAVLockException(
    String message, {
    int? statusCode,
    String? responseBody,
    Object? cause,
  }) : super(
         message,
         statusCode: statusCode,
         responseBody: responseBody,
         cause: cause,
       );
}

/// Exception thrown when XML parsing fails
class WebDAVXmlException extends WebDAVException {
  const WebDAVXmlException(
    String message, {
    int? statusCode,
    String? responseBody,
    Object? cause,
  }) : super(
         message,
         statusCode: statusCode,
         responseBody: responseBody,
         cause: cause,
       );
}

/// Exception thrown when a request times out
class WebDAVTimeoutException extends WebDAVException {
  const WebDAVTimeoutException(
    String message, {
    int? statusCode,
    String? responseBody,
    Object? cause,
  }) : super(
         message,
         statusCode: statusCode,
         responseBody: responseBody,
         cause: cause,
       );
}

/// Exception thrown when the client is used incorrectly
class WebDAVClientException extends WebDAVException {
  const WebDAVClientException(
    String message, {
    int? statusCode,
    String? responseBody,
    Object? cause,
  }) : super(
         message,
         statusCode: statusCode,
         responseBody: responseBody,
         cause: cause,
       );
}
