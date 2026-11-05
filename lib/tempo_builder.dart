import 'bluedot_point_sdk_platform_interface.dart';
import 'dart:io' show Platform;

class TempoBuilder {
  /// Start Tempo Tracking for [destinationId] provided.
  ///
  /// An error will be returned if your App does not have __Always__ location permission.
  /// If the Tempo is started successful, error will be returned as nil. However, if the Start Tempo fails, an error will be provided.
  ///
  /// ### Android
  /// Tempo requires a foreground service to be linked before it can start. Start and
  /// foreground your own `Service` and call `BluedotPointSdk.instance.linkForegroundService()`
  /// before calling [start] — calling [start] with no foreground service linked fails
  /// synchronously. If the linked foreground service later goes away while Tempo is
  /// tracking, Tempo stops and reports it asynchronously via the
  /// `tempoTrackingStoppedWithError` event with `isForegroundServiceNotLinked: true`.
  Future<void> start(String destinationId) {
    if (Platform.isAndroid) {
      return BluedotPointSdkPlatform.instance.androidStartTempoTracking(destinationId);
    } else if (Platform.isIOS){
      return BluedotPointSdkPlatform.instance.iOSStartTempoTracking(destinationId);
    } else {
      return BluedotPointSdkPlatform.instance.unimplementedError();
    }
  }
}
