import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screen_time_api_ios_platform_interface.dart';

/// An implementation of [ScreenTimeApiIosPlatform] that uses method channels.
class MethodChannelScreenTimeApiIos extends ScreenTimeApiIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('screen_time_api_ios');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<void> selectAppsToDiscourage() async {
    await methodChannel.invokeMethod('selectAppsToDiscourage');
  }

  Future<void> encourageAll() async {
    await methodChannel.invokeMethod('encourageAll');
  }

  Future<List<String>> getBlockedApps() async {
    final blockedApps = await methodChannel.invokeMethod<List<dynamic>>('getBlockedApps');
    return blockedApps?.cast<String>() ?? [];
  }

  Future<List<String>> getBlockedCategories() async {
    final blockedCategories = await methodChannel.invokeMethod<List<dynamic>>('getBlockedCategories');
    return blockedCategories?.cast<String>() ?? [];
  }

  Future<void> blockAppsAtTime(List<String> bundleIds, DateTime time) async {
    await methodChannel.invokeMethod('blockAppsAtTime', {
      'bundleIds': bundleIds,
      'timestamp': time.millisecondsSinceEpoch / 1000, // 秒単位のタイムスタンプ
    });
  }

  Future<void> unblockApp(String bundleId) async {
    await methodChannel.invokeMethod('unblockApp', {
      'bundleId': bundleId,
    });
  }

  Future<void> unblockAppAtTime(String bundleId, DateTime time) async {
    await methodChannel.invokeMethod('unblockAppAtTime', {
      'bundleId': bundleId,
      'timestamp': time.millisecondsSinceEpoch / 1000, // 秒単位のタイムスタンプ
    });
  }
}
