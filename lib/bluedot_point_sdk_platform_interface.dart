import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bluedot_point_sdk_method_channel.dart';

abstract class BluedotPointSdkPlatform extends PlatformInterface {
  /// Constructs a BluedotPointSdkPlatform.
  BluedotPointSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static MethodChannelBluedotPointSdk _instance = MethodChannelBluedotPointSdk();

  /// The default instance of [BluedotPointSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelBluedotPointSdk].
  static MethodChannelBluedotPointSdk get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BluedotPointSdkPlatform] when
  /// they register themselves.
  static set instance(MethodChannelBluedotPointSdk instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
  
  Future<void> unimplementedError() {
    throw UnimplementedError('Unimplemented Error');
  }
}
