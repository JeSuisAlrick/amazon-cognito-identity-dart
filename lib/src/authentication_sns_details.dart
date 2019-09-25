
import 'package:meta/meta.dart';

enum ProviderType {
  GOOGLE,
  FACEBOOK,
  // APPLE,
}

class AuthenticationSNSDetails {
  final String region;
  final String userPoolDomainPrefix;
  final String userPoolId;
  final String userPoolAppClientId;
  final String identityPoolId;
  final String cognitoIdentityPoolUrl;
  final String cognitoUserPoolLoginRedirectUrl;
  final String cognitoUserPoolLogoutRedirectUrl;
  final String cognitoUserPoolLoginScopes;

  AuthenticationSNSDetails({
    @required this.region,
    @required this.userPoolDomainPrefix,
    @required this.userPoolId,
    @required this.userPoolAppClientId,
    @required this.identityPoolId,
    @required this.cognitoIdentityPoolUrl,
    @required this.cognitoUserPoolLoginRedirectUrl,
    @required this.cognitoUserPoolLogoutRedirectUrl,
    @required this.cognitoUserPoolLoginScopes,
  });

  String get cognitoUserPoolLoginUrl =>
      "https://$userPoolDomainPrefix.auth.$region.amazoncognito.com/login?"
      "redirect_uri=${Uri.encodeFull(cognitoUserPoolLoginRedirectUrl)}&"
      "response_type=code&client_id=$userPoolAppClientId&"
      "identity_provider=COGNITO&"
      "scopes=${Uri.encodeFull(cognitoUserPoolLoginScopes)}";

  String get cognitoUserPoolLoginFacebookUrl =>
      'https://$userPoolDomainPrefix.auth.$region.amazoncognito.com/oauth2/authorize?'
      'response_type=code&'
      "client_id=$userPoolAppClientId&"
      "redirect_uri=${Uri.encodeFull(cognitoUserPoolLoginRedirectUrl)}&"
      'scope=${Uri.encodeFull(cognitoUserPoolLoginScopes)}&'
      'identity_provider=Facebook';

  String get cognitoUserPoolLoginGoogleUrl =>
      'https://$userPoolDomainPrefix.auth.$region.amazoncognito.com/oauth2/authorize?'
      'response_type=code&'
      "client_id=$userPoolAppClientId&"
      "redirect_uri=${Uri.encodeFull(cognitoUserPoolLoginRedirectUrl)}&"
      'scope=${Uri.encodeFull(cognitoUserPoolLoginScopes)}&'
      'identity_provider=Google';

  String get cognitoUserPoolLogoutUrl =>
      "https://$userPoolDomainPrefix.auth.$region.amazoncognito.com/logout?"
      "logout_uri=${Uri.encodeFull(cognitoUserPoolLogoutRedirectUrl)}&"
      "client_id=$userPoolAppClientId";

  String get cognitoUserPoolTokenUrl =>
      "https://$userPoolDomainPrefix.auth.$region.amazoncognito.com/oauth2/token";

}
