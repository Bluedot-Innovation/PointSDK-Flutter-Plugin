import 'bluedot_point_sdk_platform_interface.dart';
import 'dart:io' show Platform;

class TempoBuilder {
  String channelId = '';
  String channelName = '';
  String androidNotificationTitle = '';
  String androidNotificationContent = '';
  int androidNotificationId = -1;

  String? iosNotificationTitle;
  String? iosNotificationButtonText;

  /// Set parameters for foreground service notification. Only required for apps targeting Android O and above.
  /// This is required to run Tempo Tracking service.
  TempoBuilder androidNotification (String channelId, String channelName, String androidNotificationTitle, String androidNotificationContent, int androidNotificationId) {
    this.channelId = channelId;
    this.channelName = channelName;
    this.androidNotificationTitle = androidNotificationTitle;
    this.androidNotificationContent = androidNotificationContent;
    this.androidNotificationId = androidNotificationId;

    return this;
  }

  /// Start Tempo Tracking for [destinationId] provided.
  ///
  /// An error will be returned if your App does not have __Always__ location permission.
  /// If the Tempo is started successful, error will be returned as nil. However, if the Start Tempo fails, an error will be provided.
  Future<void> start(String destinationId) {
    if (Platform.isAndroid) {
      return BluedotPointSdkPlatform.instance.androidStartTempoTracking(destinationId, channelId, channelName, androidNotificationTitle,
          androidNotificationContent, androidNotificationId);
    } else if (Platform.isIOS){
      return BluedotPointSdkPlatform.instance.iOSStartTempoTracking(destinationId);
    } else {
      return BluedotPointSdkPlatform.instance.unimplementedError();
    }
  }
}