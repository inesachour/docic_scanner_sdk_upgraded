import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docic_mobile_sdk/docic_mobile_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDocicMobileSdk platform = MethodChannelDocicMobileSdk();
  const MethodChannel channel = MethodChannel('docic_mobile_sdk');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
