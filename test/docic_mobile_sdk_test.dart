import 'package:flutter_test/flutter_test.dart';
import 'package:docic_mobile_sdk/docic_mobile_sdk.dart';
import 'package:docic_mobile_sdk/docic_mobile_sdk_platform_interface.dart';
import 'package:docic_mobile_sdk/docic_mobile_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDocicMobileSdkPlatform
    with MockPlatformInterfaceMixin
    implements DocicMobileSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DocicMobileSdkPlatform initialPlatform = DocicMobileSdkPlatform.instance;

  test('$MethodChannelDocicMobileSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDocicMobileSdk>());
  });

  test('getPlatformVersion', () async {
    DocicMobileSdk docicMobileSdkPlugin = DocicMobileSdk();
    MockDocicMobileSdkPlatform fakePlatform = MockDocicMobileSdkPlatform();
    DocicMobileSdkPlatform.instance = fakePlatform;

    expect(await docicMobileSdkPlugin.getPlatformVersion(), '42');
  });
}
