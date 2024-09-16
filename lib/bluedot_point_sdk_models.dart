
import 'dart:convert';
import 'package:flutter/services.dart';

class BluedotPointSdkModels {
  static const geoTriggeringUtils = 'bluedot_point_flutter/geo_triggering_utils';
  static const tempoUtils = 'bluedot_point_flutter/tempo_utils';

  static final instance = BluedotPointSdkModels();

  static const MethodChannel methodChannelGeoUtils = MethodChannel(geoTriggeringUtils);

  BluedotPointSdkModels() {
    print("ABCD BluedotPointSdkModels");
    methodChannelGeoUtils.setMethodCallHandler(parseJson);
  }

  // Parse passed in string as json and return resulting object.
  // Possible TODO: Add Models for each "model" type being passed in.
  Future<dynamic> parseJson(MethodCall call) {
    print("ABCD BluedotPointSdkModels parseJson");
    String model = call.arguments[0];
    String json = call.arguments[1];
    try {
      return Future.value(jsonDecode(json));
    }
    on FormatException {
      return Future.value(null);
    }
  }
}
