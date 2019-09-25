import 'dart:convert';

import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'secret.dart';

UserService userService;

/// Extend CognitoStorage with Shared Preferences to persist account
/// login sessions
class Storage extends CognitoStorage {
  SharedPreferences _prefs;
  Storage(this._prefs);

  @override
  Future getItem(String key) async {
    String item;
    try {
      item = json.decode(_prefs.getString(key));
    } catch (e) {
      return null;
    }
    return item;
  }

  @override
  Future setItem(String key, value) async {
    _prefs.setString(key, json.encode(value));
    return getItem(key);
  }

  @override
  Future removeItem(String key) async {
    final item = getItem(key);
    if (item != null) {
      _prefs.remove(key);
      return item;
    }
    return null;
  }

  @override
  Future<void> clear() async {
    // TODO: it may not delete all data
    for (var key in _prefs.getKeys()) {
      if (key.startsWith('CognitoIdentityServiceProvider'))
        await removeItem(key);
    }
  }
}

class UserService {
  CognitoUserPool _userPool;
  CognitoUser _cognitoUser;
  CognitoUserSession _session;
  UserService(this._userPool);
  CognitoCredentials _credentials;

  String email = '';

  /// Initiate user session from local storage if present
  Future<bool> init() async {
    _cognitoUser = await _userPool.getCurrentUser();
    if (_cognitoUser == null) {
      return false;
    }
    _session = await _cognitoUser.getSession();

    email = _session == null? '' : _session.idToken.payload['email'];
    return _session?.isValid();
  }

  /// Get existing user from session with his/her attributes
  CognitoUser get currentUser => _cognitoUser;

  Future<CognitoUserSession> get session async {
    if (!_session.isValid()){
      _session = await _cognitoUser.refreshSession(_session.refreshToken);
    }

    return _session;
  }

  get userPool => _userPool;

  /// Retrieve user credentials -- for use with other AWS services
  Future<CognitoCredentials> get credentials async {
    if (_credentials != null && DateTime.now().millisecondsSinceEpoch < _credentials.expireTime - 60000 ){
      return _credentials;
    }

    if (_cognitoUser == null || _session == null) {
      return null;
    }

    _credentials = new CognitoCredentials(snsDetails.identityPoolId, _userPool);
    await _credentials.getAwsCredentials(_session.getIdToken().getJwtToken());
    return _credentials;
  }

  /// Check if user's current session is valid
  Future<bool> checkAuthenticated() async {
    if (_cognitoUser == null || _session == null) {
      return false;
    }
    return _session.isValid();
  }

  /// Sign up new user
  Future<bool> signUp(String code) async {
    // User name makeshift, it will be replace by IdToken.payload['cognito:username']
    final cognitoUser = new CognitoUser(
      'user-abc', _userPool,
      storage: _userPool.storage
    );

    await cognitoUser.authenticateBySnsCode(
      code: code,
      userPoolAppClientId: snsDetails.userPoolAppClientId,
      cognitoUserPoolTokenUrl: snsDetails.cognitoUserPoolTokenUrl,
      cognitoUserPoolLoginRedirectUrl: snsDetails.cognitoUserPoolLoginRedirectUrl,
    );
    return await init();
  }

  Future<void> logOut() async {
    if (_credentials != null) {
      _credentials = null;
    }
    if (_cognitoUser != null) {
      return _cognitoUser.signOut();
    }
  }
}

Future main() async {
  userService = UserService(CognitoUserPool(
    snsDetails.userPoolId,
    snsDetails.userPoolAppClientId,
    storage: CognitoStorageHelper(Storage(await SharedPreferences.getInstance())).getStorage(),
  ));

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

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => new _MainPageState();
}

enum PageState {
  Login,
  Loading,
  Logout
}

class _MainPageState extends State<MainPage> {

  PageState _currentState = PageState.Loading;

  @override
  initState(){
    super.initState();
    // Future.delayed(
    //   Duration(microseconds: 500),
    //   _checkUser
    //   );
    _checkUser();
  }

  Future _checkUser() async {
    bool isSuccess = false;
    try {
      isSuccess = await userService.init();
    } catch (e) {
      print(e);
    }

    if (isSuccess) {
      setState(() {
        _currentState = PageState.Logout;
      });
    } else {
      setState(() {
        _currentState = PageState.Login;
      });
    }
  }

  _registerNewUser(ProviderType type) async {
    setState(() {
      _currentState = PageState.Loading;
    });

    String loginUrl;
    switch (type) {
      case ProviderType.FACEBOOK:
        loginUrl = snsDetails.cognitoUserPoolLoginFacebookUrl;
        break;
      case ProviderType.GOOGLE:
        loginUrl = snsDetails.cognitoUserPoolLoginGoogleUrl;
        break;
    }

    String code;
    bool isSuccess = false;
    try {
      code = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
          SNSSignInPage(
            loginUrl: loginUrl,
            redirectUrl: snsDetails.cognitoUserPoolLoginRedirectUrl,
          )
        ),
      );

      if (code != null){
        isSuccess = await userService.signUp(code);
      }
    } catch (e) {
      print(e);
    }

    if (isSuccess) {
      setState(() {
        _currentState = PageState.Logout;
      });
    } else {
      setState(() {
        _currentState = PageState.Login;
      });
    }
  }

  _logOut() async {
    setState(() {
      _currentState = PageState.Loading;
    });

    bool isSuccess = false;
    try {
      await userService.logOut();
      isSuccess = true;
    } catch (e) {
      print(e);
    }

    if (isSuccess) {
      setState(() {
        _currentState = PageState.Login;
      });
    } else {
      setState(() {
        _currentState = PageState.Logout;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    switch (_currentState) {
      case PageState.Loading:
        widget = _buildLoading();
        break;
      case PageState.Login:
        widget = _buildLogin();
        break;
      case PageState.Logout:
        widget = _buildLogout(userService.email);
        break;
    }
    return Scaffold(
      body: widget
    );
  }

  _buildLoading(){
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

  _buildLogin(){
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
              () => _registerNewUser(ProviderType.GOOGLE)),
            SizedBox(height: 20),
            _signInButton(
              'assets/f_logo_RGB-Blue_250.png',
              'Sign in with Facebook',
              () => _registerNewUser(ProviderType.FACEBOOK)),
          ],
        ),
      ),
    );
  }

  _buildLogout(String text){
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(text),
          SizedBox(height: 20),
          RaisedButton(
            child: Text('Logout'),
            onPressed: _logOut,
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
