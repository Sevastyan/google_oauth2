A Dart library for generating OAuth 2.0 access tokens for Google APIs based on
JSON service account credentials.

## Usage

The package provides a flexible, extensible interface through generator
functions:

```dart
final scopesToTokenGenerator = genTokenFromJson(json);
/* or
final scopesToTokenGenerator = genTokenFromJsonFile(file); */

final scopes = [
    'https://www.googleapis.com/auth/cloud-platform',
    'https://www.googleapis.com/auth/firebase.messaging',
];

final tokenGenerator = scopesToTokenGenerator(scopes);

final accessToken = await tokenGenerator.generate();
```

Don't forget to handle any errors.
