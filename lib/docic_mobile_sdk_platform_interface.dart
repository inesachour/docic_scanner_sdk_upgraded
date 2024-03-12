import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'docic_mobile_sdk_method_channel.dart';

abstract class DocicMobileSdkPlatform extends PlatformInterface {
  /// Constructs a DocicMobileSdkPlatform.
  DocicMobileSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static DocicMobileSdkPlatform _instance = MethodChannelDocicMobileSdk();

  /// The default instance of [DocicMobileSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelDocicMobileSdk].
  static DocicMobileSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DocicMobileSdkPlatform] when
  /// they register themselves.
  static set instance(DocicMobileSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
