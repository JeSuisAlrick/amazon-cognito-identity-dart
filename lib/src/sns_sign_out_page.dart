import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

// The application's login page.
class SNSSignOutPage extends StatefulWidget {
  final String logoutUrl;
  final String redirectUrl;

  SNSSignOutPage(
    this.logoutUrl,
    this.redirectUrl
    );

  @override
  _SNSSignOutPageState createState() => new _SNSSignOutPageState();
}

// The application's login page state.
class _SNSSignOutPageState extends State<SNSSignOutPage> {
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
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
      url: widget.logoutUrl,
      hidden: true,
      appBar: new AppBar(
        title: new Text("Sign Out"),
      ),
      userAgent: HttpClient().userAgent,
      clearCookies: true,
    );
  }
}
