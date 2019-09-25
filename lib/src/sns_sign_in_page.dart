import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';


// The application's login page.
class SNSSignInPage extends StatefulWidget {
  final String loginUrl;
  final String redirectUrl;
  final String Function(String url) parseSNSCode;

  SNSSignInPage(
    this.loginUrl,
    this.redirectUrl,
    this.parseSNSCode
    );

  @override
  _SNSSignInPageState createState() => new _SNSSignInPageState();
}

// The application's login page state.
class _SNSSignInPageState extends State<SNSSignInPage> {
  // Webview to present the sign in/up web page.
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  // Webview subscriptions.
  StreamSubscription<String> _onUrlChanged;

  String token;

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onUrlChanged.cancel();
    flutterWebviewPlugin.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Close, just to be sure.
    flutterWebviewPlugin.close();

    // Add a listener to on url changed.
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url
          .startsWith(widget.redirectUrl)) {
        Navigator.pop(context, widget.parseSNSCode(url));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String loginUrl = widget.loginUrl;
    return FutureBuilder<bool>(
      future: () async {
          await FlutterUserAgent.init();
          return true;
        }(),
      builder: (context, snapshot)  {
        if (snapshot.data == true) {
          return WebviewScaffold(
            url: loginUrl,
            clearCookies: true,
            appBar: new AppBar(
              title: new Text("Sign In"),
            ),
            userAgent: Platform.isAndroid?
              'Mozilla/5.0 (Linux; Android 4.1.1; Galaxy Nexus Build/JRO03C) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19'
              : FlutterUserAgent.webViewUserAgent
            // userAgent: FlutterUserAgent.webViewUserAgent,
          );
        }
        return Container();
    });
  }
}
