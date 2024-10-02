import 'dart:io';

import 'package:google_oauth2/google_oauth2.dart';

Future<void> main() async {
  final token = await getTokenFromFile(
    serviceAccountJsonFile: File('service-account.json'), // Provide path to your own service account file.
    scopes: [
      'https://www.googleapis.com/auth/cloud-platform',
      'https://www.googleapis.com/auth/firebase.messaging',
    ],
  );

  print(token);
}
