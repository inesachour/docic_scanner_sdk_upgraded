
import 'docic_mobile_sdk_platform_interface.dart';

class DocicMobileSdk {
  Future<String?> getPlatformVersion() {
    return DocicMobileSdkPlatform.instance.getPlatformVersion();
  }
}
