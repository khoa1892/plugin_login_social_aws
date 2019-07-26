import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_aws_plugin/flutter_aws_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_aws_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterAwsPlugin.platformVersion, '42');
  });
}
