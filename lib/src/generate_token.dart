import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_oauth2/src/data/parse_file_as_json.dart';
import 'package:http/http.dart';
import 'package:pointycastle/pointycastle.dart';

/// Given service account credentials, returns a function to generate a
/// Bearer authorization token for accessing Google
/// APIs.
///
/// [json] - a JSON date structure containing the service account
/// credentials, as provided by Google.
ScopesToTokenGenerator genTokenFromJson(Map<String, dynamic> json) =>
    (scopes) => (now) => _createClaim(json)(now)(scopes)
        .let(_claimToJwt(_parsePrivateKey(json)))
        .let(_jwtToToken);

/// Given service account credentials, returns a function to generate a
/// Bearer authorization token for accessing Google
/// APIs.
///
/// [file] - a service account JSON file, as provided by Google.
ScopesToTokenGenerator genTokenFromJsonFile(File file) => (scopes) => (now) =>
    parseFileAsJson(file).then((json) => genTokenFromJson(json)(scopes)(now));

_NowToScopesToClaim _createClaim(Map<String, dynamic> json) =>
    (now) => (scopes) {
          final issuer = json['client_email'];
          final issuedAt = now.millisecondsSinceEpoch ~/ 1000;
          final expirationAt = issuedAt + 3600;

          return {
            'iss': issuer,
            'scope': scopes.join(' '),
            'aud': _audience,
            'iat': issuedAt,
            'exp': expirationAt,
          };
        };

_ClaimToJwt _claimToJwt(String privateKeyBase64) => (claimData) {
      final privateKey = base64
          .decode(privateKeyBase64)
          .let(_rsaPrivateKeyFromDERBytes)
          .let((privateKey) => PrivateKeyParameter<RSAPrivateKey>(privateKey));

      final isForSigning = true;

      Signer signer = Signer('SHA-256/RSA')..init(isForSigning, privateKey);

      final header = _base64urlEncode({'alg': 'RS256', 'typ': 'JWT'});
      final claim = _base64urlEncode(claimData);

      final signatureBytes = utf8
          .encode('$header.$claim')
          .let(signer.generateSignature)
          .let<RSASignature>((signature) => signature as RSASignature)
          .bytes;

      final signature = base64UrlEncode(signatureBytes);

      return '$header.$claim.$signature';
    };

// Adapted from the following source:
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

  return RSAPrivateKey(
    modulus.integer!,
    privateExponent.integer!,
    p.integer,
    q.integer,
  );
}

String _base64urlEncode(Map<String, dynamic> json) =>
    jsonEncode(json).let(utf8.encode).let(base64UrlEncode);

String _parsePrivateKey(Map<String, dynamic> json) =>
    (json['private_key'] as String)
        .split('\n')
        .where((line) => !line.contains('PRIVATE KEY'))
        .map((line) => line.trim())
        .join();

Future<String> _jwtToToken(String jwt) async {
  final headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  final body = {
    'assertion': jwt,
    'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
  };

  return post(Uri.parse(_audience), headers: headers, body: body)
      .then(_parseResponse)
      .then((body) => body['access_token']);
}

Map<String, dynamic> _parseResponse(Response response) =>
    response.statusCode == 200
        ? jsonDecode(response.body)
        : throw Exception(response.body);

// Recipient for whom the JWT is intended.
const _audience = 'https://www.googleapis.com/oauth2/v4/token';

/// Given API scopes, returns a function to get Bearer authorizations token for
/// Google APIs.
///
/// [scopes] - collection of OAuth 2.0 scopes as defined by Google APIs:
/// https://developers.google.com/identity/protocols/oauth2/scopes
typedef ScopesToTokenGenerator = TokenGenerator Function(
  Iterable<String> scopes,
);

/// Given time of a claim, returns a Bearer authorization token for Google APIs.
///
/// [now] - time of claim issuing. Pass current time for the longest lifetime
/// of the token.
typedef TokenGenerator = Future<String> Function(DateTime now);

extension TokenGeneratorExtension on TokenGenerator {
  Future<String> generate() => this(DateTime.now());
}

typedef _NowToScopesToClaim = _ScopesToClaim Function(DateTime now);
typedef _ScopesToClaim = Map<String, dynamic> Function(Iterable<String> scopes);
typedef _ClaimToJwt = String Function(Map<String, dynamic> claimData);

extension _LetExtension<T> on T {
  R let<R>(R Function(T) fun) => fun(this);
}
