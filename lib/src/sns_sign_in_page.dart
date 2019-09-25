import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

typedef String CodeParser(String url);

// The application's login page.
class SNSSignInPage extends StatefulWidget {
  final String loginUrl;
  final String redirectUrl;
  final CodeParser codeParser;

  SNSSignInPage({
    @required this.loginUrl,
    @required this.redirectUrl,
    this.codeParser,
  });

  @override
  _SNSSignInPageState createState() => new _SNSSignInPageState();
}

class _SNSSignInPageState extends State<SNSSignInPage> {
  FlutterWebviewPlugin _flutterWebviewPlugin;
  StreamSubscription<String> _onUrlChangedSubscription;

  @override
  void initState() {
    super.initState();
    _flutterWebviewPlugin = FlutterWebviewPlugin();
    _onUrlChangedSubscription = _flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.startsWith(widget.redirectUrl)) {
        var parser = widget.codeParser;
        if (parser == null) {
          parser = (url) {
            RegExp regExp = new RegExp("code=(.*)");
            var token = regExp.firstMatch(url)?.group(1);
            return token;
          };
        }
        Navigator.pop(context, parser(url));
      }
    });
  }

  @override
  void dispose() {
    _onUrlChangedSubscription.cancel();
    _flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: mobile user agent
    return WebviewScaffold(
      url: widget.loginUrl,
      clearCookies: true,
      userAgent: Platform.isAndroid?
              'Mozilla/5.0 (Linux; Android 4.1.1; Galaxy Nexus Build/JRO03C) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_2 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Mobile/14F89 Safari/602.1'
    );
  }
}
