import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sns_signin/services.dart';

import 'login_page.dart';
import 'home_page.dart';
import 'secret.dart';

UserService userService;

Future main() async {
  userService = UserService(CognitoUserPool(
    snsDetails.userPoolId,
    snsDetails.userPoolAppClientId,
    storage: CognitoStorageHelper(Storage(await SharedPreferences.getInstance())).getStorage(),
  ));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StateMyApp();
  }
}

class _StateMyApp extends State<MyApp> {

  Future<bool> _checkUser() async {
    try {
      return await userService.init();
    } catch (e) {
      print(e);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _checkUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            if (snapshot.data){
              return HomePage();
            } else {
              return LoginPage();
            }
          } else {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('slash logo here'),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                  ],
                ),
              ),
            );
          }
          }
        ),
    );
  }
}
