import 'package:google_oauth2/google_oauth2.dart';

Future<void> main() async {
  final Map<String, dynamic> json = {
    /*'service-account.json'*/
  };
  final scopes = [
    'https://www.googleapis.com/auth/cloud-platform',
    'https://www.googleapis.com/auth/firebase.messaging',
  ];
  final scopesToTokenGenerator = genTokenFromJson(json);
  final tokenGenerator = scopesToTokenGenerator(scopes);
  await tokenGenerator.generate().then((token) => print(token));
}
