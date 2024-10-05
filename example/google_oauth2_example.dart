import 'dart:io';

import 'package:google_oauth2/google_oauth2.dart';

Future<void> main() async {
  final file = File(
    // Provide path to your own service account file.
    'service-account.json',
  );

  final scopes = [
    'https://www.googleapis.com/auth/cloud-platform',
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  // If you are on the Web, [genTokenFromJson] is also available.
  final scopesToTokenGenerator = genTokenFromJsonFile(file);
  final tokenGenerator = scopesToTokenGenerator(scopes);

  await tokenGenerator.generate().then((token) => print(token));
}
