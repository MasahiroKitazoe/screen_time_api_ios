import 'screen_time_api_ios_platform_interface.dart';
import 'screen_time_api_ios_method_channel.dart';

class ScreenTimeApiIos {
  Future<String?> getPlatformVersion() {
    return ScreenTimeApiIosPlatform.instance.getPlatformVersion();
  }

  Future<void> selectAppsToDiscourage() async {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;
    await instance.selectAppsToDiscourage();
  }

  Future<void> encourageAll() async {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;
    await instance.encourageAll();
  }

  Future<void> blockAppsAtTime(List<String> bundleIds, DateTime time) async {
    final instance = ScreenTimeApiIosPlatform.instance as MethodChannelScreenTimeApiIos;
    await instance.blockAppsAtTime(bundleIds, time);
  }
}
