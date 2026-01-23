import 'dart:convert';
import 'package:test/test.dart';
import 'package:webdav_plus/src/impl/http_webdav_client.dart';

void main() {
  group('Domain Authentication Tests', () {
    late HttpWebdavClient client;

    setUp(() {
      client = HttpWebdavClient();
    });

    test('setCredentialsWithDomain should store domain and workstation', () {
      client.setCredentialsWithDomain(
        'testuser',
        'testpass',
        'TESTDOMAIN',
        'WORKSTATION1',
        isPreemptive: true,
      );

      // Verify headers contain domain-formatted username
      var headers = client.buildHeadersForTest();
      expect(headers.containsKey('Authorization'), isTrue);

      // The basic auth should contain "TESTDOMAIN\testuser"
      String auth = headers['Authorization']!;
      expect(auth.startsWith('Basic '), isTrue);

      // Decode and verify the domain format
      String encoded = auth.substring(6);
      String decoded = utf8.decode(base64.decode(encoded));
      expect(decoded, equals('TESTDOMAIN\\testuser:testpass'));
    });

    test('setCredentialsWithDomain should add workstation header', () {
      client.setCredentialsWithDomain(
        'testuser',
        'testpass',
        'TESTDOMAIN',
        'WORKSTATION1',
        isPreemptive: true,
      );

      var headers = client.buildHeadersForTest();
      expect(headers['X-Workstation'], equals('WORKSTATION1'));
    });

    test('setCredentials without domain should work as before', () {
      client.setCredentials('testuser', 'testpass', isPreemptive: true);

      var headers = client.buildHeadersForTest();
      expect(headers.containsKey('Authorization'), isTrue);
      expect(headers.containsKey('X-Workstation'), isFalse);

      String auth = headers['Authorization']!;
      String encoded = auth.substring(6);
      String decoded = utf8.decode(base64.decode(encoded));
      expect(decoded, equals('testuser:testpass'));
    });
  });
}
