# SNS signin

Example App sns signin for Amazon Cognito Identity SDK for Dart

## Getting Started

Create secret.dart file in `lib` folder, with content:

```dart
import 'package:amazon_cognito_identity_dart/cognito.dart';

final String apiEndpointUrl = 'https://xxxxxxxxxx.execute-api.ap-southeast-1.amazonaws.com/dev';

AuthenticationSNSDetails snsDetails = AuthenticationSNSDetails(
  region: "ap-southeast-1",
  userPoolDomainPrefix: "abc-dev",
  userPoolId: "ap-southeast-1_xxxxxxxxx",
  userPoolAppClientId: "xxxxxxxxxxxxxxxxxxxxxxxxxx",
  identityPoolId: "ap-southeast-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  cognitoIdentityPoolUrl: "https://cognito-identity.ap-southeast-1.amazonaws.com",
  cognitoUserPoolLoginRedirectUrl: "https://www.examples.com",
  cognitoUserPoolLogoutRedirectUrl: "https://www.examples.com",
  cognitoUserPoolLoginScopes: "phone email openid profile aws.cognito.signin.user.admin",
);
```
