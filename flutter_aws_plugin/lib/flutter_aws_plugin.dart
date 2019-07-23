import 'dart:async';

import 'package:flutter/services.dart';

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

}
