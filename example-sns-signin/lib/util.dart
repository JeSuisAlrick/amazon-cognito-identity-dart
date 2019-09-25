import 'dart:convert';

import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sns_signin/secret.dart';

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

  Future<void> signOut() async {
    if (_credentials != null) {
      _credentials = null;
    }
    if (_cognitoUser != null) {
      return _cognitoUser.signOut();
    }
  }
}
