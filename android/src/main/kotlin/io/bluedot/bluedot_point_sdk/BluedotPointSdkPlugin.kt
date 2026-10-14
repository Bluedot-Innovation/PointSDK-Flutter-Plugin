package io.bluedot.bluedot_point_sdk

import android.os.Handler
import android.os.Looper
import au.com.bluedot.point.error.CustomEventMetaDataSetError
import au.com.bluedot.point.net.engine.*
import au.com.bluedot.point.net.engine.ZoneInfo
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.atomic.AtomicBoolean

/** BluedotPointSdkPlugin */
class BluedotPointSdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

  companion object {
    @JvmStatic var geoTriggeringChannel: MethodChannel? = null
    @JvmStatic var tempoChannel: MethodChannel? = null
    @JvmStatic var bluedotServiceChannel: MethodChannel? = null
  }

  private val FLUTTER_PLUGIN_CHANNEL= "bluedot_point_flutter/bluedot_point_sdk"
  private val GEO_TRIGGERING_CHANNEL = "bluedot_point_flutter/geo_triggering_events"
  private val TEMPO_CHANNEL = "bluedot_point_flutter/tempo_events"
  private val BLUEDOT_SERVICE_CHANNEL = "bluedot_point_flutter/bluedot_service_events"

  private var channel: MethodChannel? = null
  private lateinit var serviceManager: ServiceManager

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    if (channel == null) {
      channel = MethodChannel(flutterPluginBinding.binaryMessenger, FLUTTER_PLUGIN_CHANNEL)
      channel!!.setMethodCallHandler(this)
    }

    if (geoTriggeringChannel == null)
       geoTriggeringChannel = MethodChannel(flutterPluginBinding.binaryMessenger, GEO_TRIGGERING_CHANNEL)

    if (tempoChannel == null)
       tempoChannel = MethodChannel(flutterPluginBinding.binaryMessenger, TEMPO_CHANNEL)

    if (bluedotServiceChannel == null)
        bluedotServiceChannel = MethodChannel(flutterPluginBinding.binaryMessenger, BLUEDOT_SERVICE_CHANNEL)

    serviceManager = ServiceManager.getInstance(flutterPluginBinding.applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "isInitialized" -> result.success(serviceManager.isBluedotServiceInitialized)
      "isGeoTriggeringRunning" -> result.success(GeoTriggeringService.isRunning())
      "isTempoRunning" -> result.success(TempoService.isRunning())
      "initialize" -> initialize(call, result)
      "androidStartGeoTriggering" -> startGeoTriggering(result)
      "stopGeoTriggering" -> stopGeoTriggering(result)
      "androidStartTempoTracking" -> startTempoTracking(call, result)
      "stopTempoTracking" -> stopTempoTracking(result)
      "setCustomEventMetaData" -> setCustomEventMetaData(call, result)
      "setZoneDisableByApplication" -> setZoneDisableByApplication(call)
      "linkForegroundService" -> linkForegroundService(result)
      "unlinkForegroundService" -> unlinkForegroundService(result)
      "reset" -> reset(result)
      "getInstallRef" -> result.success(serviceManager.installRef)
      "getSDKVersion" -> result.success(serviceManager.sdkVersion)
      "getZonesAndFences" -> getZonesAndFences(serviceManager.zonesAndFences, result)
      "getCustomEventMetaData" -> result.success(serviceManager.customEventMetaData)
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initialize(call: MethodCall, result: Result) {
    val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()
    val projectId = args["projectId"] as String
    val resultListener = InitializationResultListener { error ->
      handleError(error, result)
    }
    if (projectId.isBlank()) {
      result.error("Invalid projectId", "Project id is null or blank", "Expected project Id as String")
    } else {
      serviceManager.initialize(projectId, resultListener)
    }
  }

  private fun startGeoTriggering(result: Result) {
    val geoTriggeringStatusListener = GeoTriggeringStatusListener { error ->
      handleError(error, result)
    }
    GeoTriggeringService.builder().start(geoTriggeringStatusListener)
  }

  private fun stopGeoTriggering(result: Result) {
    val geoTriggeringStatusListener = GeoTriggeringStatusListener { error ->
      handleError(error, result)
    }
    GeoTriggeringService.stop(geoTriggeringStatusListener)
  }

  private fun startTempoTracking(call: MethodCall, result: Result) {
    val destinationId: String? = call.argument("destinationId")

    val tempoServiceStatusListener = TempoServiceStatusListener { error ->
      handleError(error, result)
    }
    if (destinationId.isNullOrBlank()) {
      result.error("Invalid destination id", "Destination Id is null or blank", "")
      return
    }
    // Tempo requires a foreground service to be linked (see linkForegroundService()) before
    // it is able to start; calling this without one linked fails synchronously via
    // tempoServiceStatusListener.
    TempoService.builder()
      .destinationId(destinationId)
      .start(tempoServiceStatusListener)
  }

  private fun stopTempoTracking(result: Result) {
    // Use the onStopped overload so the Dart Future only resolves once Tempo has fully
    // stopped (e.g. TempoService.isRunning() is guaranteed false), matching the semantics
    // callers need to safely tear down a foreground service that was only linked for Tempo.
    //
    // onStopped may be invoked from a background dispatcher, so the reply is marshalled to
    // the main looper (as AppGeoTriggeringReceiver does for its events). A reply-once guard
    // also protects against TempoService.stop() returning a synchronous error and onStopped
    // still firing later, which would otherwise submit a second reply on the same result.
    val replied = AtomicBoolean(false)
    val error: BDError? = TempoService.stop {
      if (replied.compareAndSet(false, true)) {
        Handler(Looper.getMainLooper()).post { result.success(null) }
      }
    }
    if (error != null && replied.compareAndSet(false, true)) {
      handleError(error, result)
    }
  }

  private fun linkForegroundService(result: Result) {
    try {
      serviceManager.linkForegroundService()
      result.success(null)
    } catch (e: Exception) {
      result.error("linkForegroundService failed", e.message, e.toString())
    }
  }

  private fun unlinkForegroundService(result: Result) {
    try {
      serviceManager.unlinkForegroundService()
      result.success(null)
    } catch (e: Exception) {
      result.error("unlinkForegroundService failed", e.message, e.toString())
    }
  }

  private fun setCustomEventMetaData(call: MethodCall, result: Result) {
    val metadata = call.arguments as HashMap<String, String>
    try {
      serviceManager.customEventMetaData = metadata
      result.success(null)
    } catch (err: Error) {
      result.error(CustomEventMetaDataSetError().errorCode.toString(), err.message, err.toString())
    }
  }

  private fun setZoneDisableByApplication(call: MethodCall) {
    val zoneId: String? = call.argument("zoneId")
    val disable: Boolean? = call.argument("disable")
    if (!zoneId.isNullOrBlank() && disable != null) {
      serviceManager.setZoneDisableByApplication(zoneId, disable)
    }
  }

  private fun reset(result: Result) {
    val resetResultReceiver = ResetResultReceiver { error ->
      handleError(error, result)
    }
    serviceManager.reset(resetResultReceiver)
  }

  fun ZoneInfo.toJson(): Map<String, Any?> {
    val map = mutableMapOf<String, Any?>(
      "zoneId" to zoneId,
      "zoneName" to zoneName
    )
    destination?.let {
      map["destination"] = mapOf(
        "destinationId" to it.destinationId,
        "name" to it.name,
        "address" to it.address,
        "location" to mapOf(
          "latitude" to it.location?.latitude,
          "longitude" to it.location?.longitude
        ),
        "customData" to it.customData
      )
    }
    return map
  }

  private fun getZonesAndFences(
    zoneInfos: ArrayList<ZoneInfo>?,
    result: Result
  ) {
    val resultMap: ArrayList<Map<String, Any?>> = arrayListOf()
    zoneInfos?.forEach { zoneInfo ->
      resultMap.add(zoneInfo.toJson())
    }
    result.success(resultMap)
  }

  private fun handleError(error: BDError?, result: Result) {
    if (error != null) {
      result.error(error.errorCode.toString(), error.reason, error.toString())
    } else {
      result.success(null)
    }
  }

}
