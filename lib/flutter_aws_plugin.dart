import 'dart:async';

import 'package:flutter/services.dart';

typedef void PinPointResultHandler(Map results);

class FlutterAwsPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_aws_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<Map<dynamic, dynamic>> get loginByFacebook async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('loginByFacebook');
    return result;
  }

  static Future<Map<dynamic, dynamic>> get loginByGoogle async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('loginByGoogle');
    return result;
  }

  static Future<String> get signOut async {
    final String result = await _channel.invokeMethod('signOut');
    return result;
  }

  static Future<void> get initPinPoint async {
    await _channel.invokeMethod('initPinPoint');
  }

  static Future<void> get initNotificationPermission async {
    await _channel.invokeMethod('initNotificationPermission');
  }

  Future<void> initPinPointHandler() async {
    _channel.setMethodCallHandler(_platformCallHandler);
  }

  PinPointResultHandler pinpointHandler;
  Future<void> _platformCallHandler(MethodCall call) async {
    switch(call.method) {
      case "pushReceived":
        if(pinpointHandler != null) {
          pinpointHandler(call.arguments);
        }
        break;
      default:
        print('unknow method');
    }
  }

}