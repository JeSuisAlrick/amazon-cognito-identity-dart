
import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sns_signin/util.dart';
import 'secret.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Cognito on Flutter',
      home: MainPage(),
    );
  }
}

enum _PageState {
  login,
  loading,
  logout,
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  UserService _userService;
  _PageState _currentState;

  @override
  initState(){
    super.initState();
    _setup();
  }

  // logic
  Future _setup() async {
    _currentState = _PageState.loading;
    _userService = UserService(CognitoUserPool(
      snsDetails.userPoolId,
      snsDetails.userPoolAppClientId,
      storage: CognitoStorageHelper(Storage(await SharedPreferences.getInstance())).getStorage(),
    ));

    var isSignedIn = await _userService.init();
    setState(() {
      _currentState = isSignedIn ? _PageState.logout : _PageState.login;
    });
  }

  Future _signIn(ProviderType type) async {
    setState(() {
      _currentState = _PageState.loading;
    });

    final code = await Navigator.push(context,
      MaterialPageRoute(builder: (context) =>
        SNSSignInPage(
          loginUrl: type == ProviderType.FACEBOOK ? snsDetails.cognitoUserPoolLoginFacebookUrl : snsDetails.cognitoUserPoolLoginGoogleUrl,
          redirectUrl: snsDetails.cognitoUserPoolLoginRedirectUrl,
        )
      ),
    );

    if (await _userService.signUp(code)) {
      setState(() {
        _currentState = _PageState.logout;
      });
    }
  }

  Future _signOut() async {
    setState(() {
      _currentState = _PageState.loading;
    });

    await _userService.signOut();

    setState(() {
      _currentState = _PageState.logout;
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    Widget widget;
    switch (_currentState) {
      case _PageState.loading:
        widget = _buildLoading();
        break;
      case _PageState.login:
        widget = _buildLogin();
        break;
      case _PageState.logout:
        widget = _buildLogout();
        break;
    }
    return Scaffold(
      body: widget
    );
  }

  Widget _buildLoading(){
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Running'),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
        ],
      ),
    );
  }

  Widget _buildLogin(){
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _signInButton(
              "assets/google_logo.png",
              'Sign in with Google',
              () => _signIn(ProviderType.GOOGLE)),
            SizedBox(height: 20),
            _signInButton(
              'assets/f_logo_RGB-Blue_250.png',
              'Sign in with Facebook',
              () => _signIn(ProviderType.FACEBOOK)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogout(){
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_userService.email),
          SizedBox(height: 20),
          RaisedButton(
            child: Text('Logout'),
            onPressed: _signOut,
            ),
        ],
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
