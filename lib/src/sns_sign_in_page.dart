import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';

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
  String _webUserAgent;

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
            print("token $token - $url");
            return token;
          };
        }
        Navigator.pop(context, parser(url));
      }
    });
    FlutterUserAgent.init().then((_){
      setState(() {
        _webUserAgent = FlutterUserAgent.webViewUserAgent;
      });
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
    // TODO: mobile user agent, local storage
    return _webUserAgent != null ? WebviewScaffold(
      url: widget.loginUrl,
      clearCookies: true,
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      userAgent: FlutterUserAgent.webViewUserAgent
      // userAgent: FlutterUserAgent.webViewUserAgent,
    ) : Container();
  }
}
