import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'docic_mobile_sdk_platform_interface.dart';

/// An implementation of [DocicMobileSdkPlatform] that uses method channels.
class MethodChannelDocicMobileSdk extends DocicMobileSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('docic_mobile_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
