import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'secret.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  _refeshData() async {
    http.Response response;
    try {
      print(DateTime.fromMillisecondsSinceEpoch((await userService.credentials).expireTime));
      final session = await userService.session;

      // response =
      //     await http.post(
      //   graphQLEndpoint,
      //   headers: {
      //     "Content-Type": "application/json",
      //     'Authorization': session.getIdToken().getJwtToken()
      //   },
      //   body: json.encode(getBodyGraphQL(session.accessToken.payload['jti'])),
      // );

      response =
          await http.get(
            apiEndpointUrl,
            headers: {
              'Authorization': 'Bearer ${session.getIdToken().getJwtToken()}',
              'x-amz-meta-filekey': '1569212199649_Screen Shot 2019-09-23 at 9.37.17 AM.png'
              }
          );

      if (response.statusCode == 400 || response.statusCode == 401) {
        throw Exception("Authentication failed");
      }
      else if (response.statusCode < 200 || response.statusCode > 401) {
        throw Exception('code: ${response.statusCode} message: ${json.decode(response.body)["error"]["message"]}');
      }
      else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  _signout() async {
    await userService.signOut();
    await _gotoLogin();
  }

  _gotoLogin() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>
        LoginPage()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(children : <Widget>[
          Text('Home page'),
          Spacer(),
          FlatButton(
            child: Text('Logout'),
            onPressed: () => _signout(),
          )
          ])
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('Get request (CognitoUser)'),
                onPressed: () => _refeshData(),
                ),
            ],
          ),
        ),
    );
  }

}
