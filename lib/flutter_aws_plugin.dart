import 'dart:async';

import 'package:flutter/services.dart';

typedef void PinPointResultHandler(dynamic results);

class FlutterAwsPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_aws_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get loginByFacebook async {
    final String result = await _channel.invokeMethod('loginByFacebook');
    return result;
  }

  static Future<String> get loginByGoogle async {
    final String result = await _channel.invokeMethod('loginByGoogle');
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

  static Future<String> logCustomEvent(String eventName, Map<String, String> attributes, String metric) async {
    final String result = await _channel.invokeMethod("logCustomEvent",
        {"eventName": eventName, "atributes": attributes, "metric": metric});
    return result;
  }

  Future<void> initPinPointHandler() async {
    _channel.setMethodCallHandler(_platformCallHandler);
  }

  PinPointResultHandler receiveTokenHandler;
  PinPointResultHandler receiveUserInfoHandler;
  Future<void> _platformCallHandler(MethodCall call) async {
    switch(call.method) {
      case "pushReceiveToken":
        if(receiveTokenHandler != null) {
          receiveTokenHandler(call.arguments);
        }
        break;
      case "pushReceiveUserInfo":
        if(receiveUserInfoHandler != null) {
          receiveUserInfoHandler(call.arguments);
        }
        break;
      default:
        print('unknow method');
    }
    return Future.value();
  }

}
