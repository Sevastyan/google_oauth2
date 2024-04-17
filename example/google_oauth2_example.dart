import 'package:google_oauth2/google_oauth2.dart';

Future<void> main() async {
  print(await getToken(_serviceAccountJson, _scopes));
}

const _serviceAccountJson = '';

final _scopes = [
  'https://www.googleapis.com/auth/cloud-platform',
  'https://www.googleapis.com/auth/firebase.messaging',
];
