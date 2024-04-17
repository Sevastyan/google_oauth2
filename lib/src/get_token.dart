import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pointycastle/pointycastle.dart';

///
///
/// [scopes] - collection of OAuth 2.0 scopes as defined by Google APIs:
/// https://developers.google.com/identity/protocols/oauth2/scopes
Future<String> getToken(String serviceAccountJson, Iterable<String> scopes) async {
  final Map<String, dynamic> credentials = jsonDecode(serviceAccountJson.replaceAll('\n', '\\n'));

  final privateKeyBase64 = (credentials['private_key'] as String)
      .split('\n')
      .where((line) => !line.contains('PRIVATE KEY'))
      .map((line) => line.trim())
      .join();

  final Uint8List privateKeyBytes = base64.decode(privateKeyBase64);
  final privateKey = _rsaPrivateKeyFromDERBytes(privateKeyBytes);
  Signer signer = Signer('SHA-256/RSA')..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
  final header = _base64url({'alg': 'RS256', 'typ': 'JWT'});
  final claim = _base64url(
    {
      'iss': credentials['client_email'],
      'scope': scopes.join(' '),
      'aud': _aud,
      'iat': _getSecondsSinceEpoch(),
      'exp': _getSecondsSinceEpoch(addDuration: const Duration(hours: 1)),
    },
  );
  final signatureBytes = (signer.generateSignature(utf8.encode('$header.$claim')) as RSASignature).bytes;
  final signature = base64UrlEncode(signatureBytes);
  final jwt = '$header.$claim.$signature';

  final data = {
    'grant_type': _grantType,
    'assertion': jwt,
  };

  final response = await http.post(
    Uri.parse(_aud),
    body: data,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> responseData = jsonDecode(response.body);
    return responseData['access_token'];
  } else {
    return 'Request failed: ${response.body}';
  }
}

int _getSecondsSinceEpoch({Duration addDuration = Duration.zero}) {
  final now = DateTime.now();
  final oneHourIntoTheFuture = now.add(addDuration);
  final expirationInMilliseconds = oneHourIntoTheFuture.millisecondsSinceEpoch;
  final expirationInSeconds = expirationInMilliseconds ~/ 1000;

  return expirationInSeconds;
}

// "A descriptor of the intended target of the assertion".
const _aud = 'https://www.googleapis.com/oauth2/v4/token';

const _grantType = 'urn:ietf:params:oauth:grant-type:jwt-bearer';

String _base64url(Map<String, dynamic> json) {
  final jsonString = jsonEncode(json);
  final jsonUtf8 = utf8.encode(jsonString);

  return base64UrlEncode(jsonUtf8);
}

// Shamefully copied from https://github.com/Ephenodrom/Dart-Basic-Utils/blob/45ed0a3087b2051004f17b39eb5289874b9c0390/lib/src/CryptoUtils.dart#L430
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
