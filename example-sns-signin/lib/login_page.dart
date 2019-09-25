
// import 'dart:async';

import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:flutter/material.dart';
import 'package:sns_signin/home_page.dart';
import 'main.dart';
import 'secret.dart' as secret;

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  _registerNewUser(ProviderType type) async {
    String loginUrl;
    switch (type) {
      case ProviderType.FACEBOOK:
        loginUrl = secret.snsDetails.cognitoUserPoolLoginFacebookUrl;
        break;
      case ProviderType.GOOGLE:
        loginUrl = secret.snsDetails.cognitoUserPoolLoginGoogleUrl;
        break;
    }
    try {
      String code = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
          SNSSignInPage(
            loginUrl: loginUrl,
            redirectUrl: secret.snsDetails.cognitoUserPoolLoginRedirectUrl,
          )
        ),
      );
      if (code != null && await userService.signUp(code, secret.snsDetails)) {
        await Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => HomePage())
        );
      }
    } catch (e) {
        print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlutterLogo(size: 200,),
                  SizedBox(height: 50),
                  _signInButton(
                    "assets/google_logo.png",
                    'Sign in with Google',
                    () => _registerNewUser(ProviderType.GOOGLE)),
                  SizedBox(height: 20),
                  _signInButton(
                    'assets/f_logo_RGB-Blue_250.png',
                    'Sign in with Facebook',
                    () => _registerNewUser(ProviderType.FACEBOOK)),
                ],
              ),
            ),
      ),
    );
  }

  Widget _signInButton(String asset, String text, Function onPressed) {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage(asset), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
