import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_aws_plugin/flutter_aws_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = "";

  @override
  void initState() {
    super.initState();
  }

  void _loginFB() async {
    String temp = await FlutterAwsPlugin.loginByFacebook;
     setState(() {
       _result = temp;
     });
  }

  void _loginGoogle() async {
    String temp = await FlutterAwsPlugin.loginByGoogle;
    setState(() {
      _result = temp;
    });
  }

  void _signOut() async {
    await FlutterAwsPlugin.signOut;
    setState(() {
      _result = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            MaterialButton(
              child: Text("Login By Facebook"),
              color: Colors.blue,
              onPressed: _loginFB,
            ),
            MaterialButton(
              child: Text("Login By Google"),
              color: Colors.red,
              onPressed: _loginGoogle,
            ),
            MaterialButton(
              child: Text("Sign Out"),
              color: Colors.grey,
              onPressed: _signOut,
            ),
            Center(
              child: Text('Running on: $_result\n'),
            ),
          ],
        ),
      ),
    );
  }
}
