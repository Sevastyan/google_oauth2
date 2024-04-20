import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:pointycastle/pointycastle.dart';

/// Returns bearer authorization token for Google APIs.
///
/// [serviceAccountJsonFile] - JSON file with service account credentials as provided by Google.
///
/// [scopes] - collection of OAuth 2.0 scopes as defined by Google APIs:
/// https://developers.google.com/identity/protocols/oauth2/scopes
Future<String> getToken({
  required File serviceAccountJsonFile,
  required Iterable<String> scopes,
}) async {
  final credentials = await _readAsJson(serviceAccountJsonFile);

  final issuer = credentials['client_email'];
  final issuedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final expirationAt = issuedAt + 3600;

  final jwt = _generateJsonWebToken(
    privateKeyBase64: _parsePrivateKey(credentials['private_key'] as String),
    claimData: {
      'iss': issuer,
      'scope': scopes.join(' '),
      'aud': _audience,
      'iat': issuedAt,
      'exp': expirationAt,
    },
  );

  return _getAccessToken(jwt: jwt);
}

Future<Map<String, dynamic>> _readAsJson(File serviceAccountJson) async {
  final fileLines = await serviceAccountJson.readAsLines();

  final fileContentString = fileLines
      .join()
      // properly escapes new line characters in private_key property, so that the file could be parsed as JSON.
      .replaceAll('\n', '\\n');

  return jsonDecode(fileContentString);
}

String _generateJsonWebToken({
  required String privateKeyBase64,
  required Map<String, dynamic> claimData,
}) {
  final Uint8List privateKeyBytes = base64.decode(privateKeyBase64);
  final privateKey = _rsaPrivateKeyFromDERBytes(privateKeyBytes);
  Signer signer = Signer('SHA-256/RSA')..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
  final header = _base64url({'alg': 'RS256', 'typ': 'JWT'});
  final claim = _base64url(claimData);
  final signatureBytes = (signer.generateSignature(utf8.encode('$header.$claim')) as RSASignature).bytes;
  final signature = base64UrlEncode(signatureBytes);

  return '$header.$claim.$signature';
}

// Shamefully copied from
// https://github.com/Ephenodrom/Dart-Basic-Utils/blob/45ed0a3087b2051004f17b39eb5289874b9c0390/lib/src/CryptoUtils.dart#L430
RSAPrivateKey _rsaPrivateKeyFromDERBytes(Uint8List bytes) {
  var asn1Parser = ASN1Parser(bytes);
  var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
  var privateKey = topLevelSeq.elements![2];

  asn1Parser = ASN1Parser(privateKey.valueBytes);
  var pkSeq = asn1Parser.nextObject() as ASN1Sequence;

  var modulus = pkSeq.elements![1] as ASN1Integer;
  var privateExponent = pkSeq.elements![3] as ASN1Integer;
  var p = pkSeq.elements![4] as ASN1Integer;
  var q = pkSeq.elements![5] as ASN1Integer;

  var rsaPrivateKey = RSAPrivateKey(modulus.integer!, privateExponent.integer!, p.integer, q.integer);

  return rsaPrivateKey;
}

String _base64url(Map<String, dynamic> json) {
  final jsonString = jsonEncode(json);
  final jsonUtf8 = utf8.encode(jsonString);

  return base64UrlEncode(jsonUtf8);
}

String _parsePrivateKey(String value) =>
    value.split('\n').where((line) => !line.contains('PRIVATE KEY')).map((line) => line.trim()).join();

// Recipient for whom the JWT is intended.
const _audience = 'https://www.googleapis.com/oauth2/v4/token';

Future<String> _getAccessToken({required String jwt}) async {
  final headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  final body = {
    'assertion': jwt,
    'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
  };

  final response = await post(Uri.parse(_audience), headers: headers, body: body);

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['access_token'];
  } else {
    throw Exception(response.body);
  }
}
