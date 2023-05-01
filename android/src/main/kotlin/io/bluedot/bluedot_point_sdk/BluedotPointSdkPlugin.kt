package io.bluedot.bluedot_point_sdk

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.core.app.NotificationCompat
import au.com.bluedot.point.net.engine.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** BluedotPointSdkPlugin */
class BluedotPointSdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

  companion object {
    @JvmStatic lateinit var geoTriggeringChannel: MethodChannel
    @JvmStatic lateinit var tempoChannel: MethodChannel
    @JvmStatic lateinit var bluedotServiceChannel: MethodChannel
  }

  private val FLUTTER_PLUGIN_CHANNEL= "bluedot_point_flutter/bluedot_point_sdk"
  private val GEO_TRIGGERING_CHANNEL = "bluedot_point_flutter/geo_triggering_events"
  private val TEMPO_CHANNEL = "bluedot_point_flutter/tempo_events"
  private val BLUEDOT_SERVICE_CHANNEL = "bluedot_point_flutter/bluedot_service_events"

  private lateinit var channel: MethodChannel
  private lateinit var serviceManager: ServiceManager
  private lateinit var context: Context
  private var notificationResourceId = 0

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, FLUTTER_PLUGIN_CHANNEL)
    channel.setMethodCallHandler(this)
    geoTriggeringChannel = MethodChannel(flutterPluginBinding.binaryMessenger, GEO_TRIGGERING_CHANNEL)
    tempoChannel = MethodChannel(flutterPluginBinding.binaryMessenger, TEMPO_CHANNEL)
    bluedotServiceChannel = MethodChannel(flutterPluginBinding.binaryMessenger, BLUEDOT_SERVICE_CHANNEL)
    context = flutterPluginBinding.applicationContext
    serviceManager = ServiceManager.getInstance(flutterPluginBinding.applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "isInitialized" -> result.success(serviceManager.isBluedotServiceInitialized)
      "isGeoTriggeringRunning" -> result.success(GeoTriggeringService.isRunning())
      "isTempoRunning" -> result.success(TempoService.isRunning(context))
      "initialize" -> initialize(call, result)
      "androidStartGeoTriggering" -> startGeoTriggering(call, result)
      "stopGeoTriggering" -> stopGeoTriggering(result)
      "androidStartTempoTracking" -> startTempoTracking(call, result)
      "stopTempoTracking" -> stopTempoTracking(result)
      "setCustomEventMetaData" -> setCustomEventMetaData(call, result)
      "setNotificationIcon" -> setNotificationIcon(call)
      "setZoneDisableByApplication" -> setZoneDisableByApplication(call)
      "reset" -> reset(result)
      "getInstallRef" -> result.success(serviceManager.installRef)
      "getSDKVersion" -> result.success(serviceManager.sdkVersion)
      "getZonesAndFences" -> result.success(serviceManager.zonesAndFences)
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

  private fun startGeoTriggering(call: MethodCall, result: Result) {
    // set a default notification icon if not yet set
    if (notificationResourceId == 0) {
      updateNotificationResource(null)
    }

    val channelId: String? = call.argument("channelId")
    val channelName: String? = call.argument("channelName")
    val title: String? = call.argument("title")
    val content: String? = call.argument("content")
    val notificationId: Int = call.argument("notificationId") ?: -1

    val geoTriggeringStatusListener = GeoTriggeringStatusListener { error ->
      handleError(error, result)
    }
    if (title.isNullOrBlank() || content.isNullOrBlank()) {
      GeoTriggeringService.builder().start(context, geoTriggeringStatusListener)
    } else {
      if (channelId.isNullOrBlank() || channelName.isNullOrBlank()) {
        result.error(
          "Missing parameters",
          "Missing parameters for channelId, channelName, title or content",
          ""
        )
        return
      }
      val notification = createNotification(channelId, channelName, title, content)
      if (notificationId != -1) {
        GeoTriggeringService.builder()
          .notificationId(notificationId)
          .notification(notification)
          .start(context, geoTriggeringStatusListener)
      } else {
        GeoTriggeringService.builder()
          .notification(notification)
          .start(context, geoTriggeringStatusListener)
      }
    }
  }

  private fun stopGeoTriggering(result: Result) {
    val geoTriggeringStatusListener = GeoTriggeringStatusListener { error ->
      handleError(error, result)
    }
    GeoTriggeringService.stop(context, geoTriggeringStatusListener)
  }

  private fun startTempoTracking(call: MethodCall, result: Result) {
    val destinationId: String? = call.argument("destinationId")
    val channelId: String? = call.argument("channelId")
    val channelName: String? = call.argument("channelName")
    val title: String? = call.argument("title")
    val content: String? = call.argument("content")
    val notificationId: Int = call.argument("notificationId") ?: -1

    val tempoServiceStatusListener = TempoServiceStatusListener { error ->
      handleError(error, result)
    }
    if (destinationId.isNullOrBlank()) {
      result.error("Invalid destination id", "Destination Id is null or blank", "")
      return
    }
    if (channelId.isNullOrBlank() || channelName.isNullOrBlank() || title.isNullOrBlank() || content.isNullOrBlank()) {
      result.error(
        "Missing parameters",
        "Missing parameters for channelId, channelName, title or content",
        ""
      )
      return
    }
    val notification = createNotification(channelId, channelName, title, content)
    if (notificationId != -1) {
      TempoService.builder()
        .notificationId(notificationId)
        .notification(notification)
        .destinationId(destinationId)
        .start(context, tempoServiceStatusListener)
    } else {
      TempoService.builder()
        .notification(notification)
        .destinationId(destinationId)
        .start(context, tempoServiceStatusListener)
    }
  }

  private fun stopTempoTracking(result: Result) {
    val error: BDError? = TempoService.stop(context)
    handleError(error, result)
  }

  private fun setCustomEventMetaData(call: MethodCall, result: Result) {
    val metadata = call.arguments as HashMap<String, String>
    try {
      serviceManager.setCustomEventMetaData(metadata)
      result.success(null)
    } catch (err: Error) {
      result.error(BDError.ERROR_CODE_CUSTOM_METADATA_NOT_SET.toString(), err.message, err.toString())
    }
  }

  private fun setNotificationIcon(call: MethodCall) {
    val icon: String? = call.argument("icon")
    updateNotificationResource(icon)
  }

  private fun updateNotificationResource(icon: String) {
    // find the resourceID int from the passed in icon name
    var resourceID = findIconResourceId(icon)
    if (resourceID == 0) {
      // fallback to the default name of Notification Icon `ic_stat_name`
      resourceID = findIconResourceId("ic_stat_name")
    }

    // save the resourceId and update to Bluedot PointSDK
    notificationResourceId = resourceID
    if (resourceID != 0) {
      serviceManager.setNotificationIDResourceID(resourceID)
    }
  }

  // Return the resourceId if available for icon name. Returns 0 if such resource doesn't exist
  private fun findIconResourceId(icon: String): Int {
    if (icon == null) {
      return 0
    }
    // find the resourceID int from the passed in icon name
    val packageName: String = context.packageName
    var resourceID: Int =
      context.resources.getIdentifier(icon, "drawable", packageName)
    if (resourceID == 0) {
      // not found in drawable, try mipmap
      resourceID = context.resources.getIdentifier(icon, "mipmap", packageName)
    }
    return resourceID
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

  private fun handleError(error: BDError?, result: Result) {
    if (error != null) {
      result.error(error.errorCode.toString(), error.reason, error.toString())
    } else {
      result.success(null)
    }
  }

  private fun createNotification(
    channelId: String,
    channelName: String,
    title: String,
    content: String
  ): Notification {

    val activityIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
    activityIntent?.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
    val pendingIntent = PendingIntent.getActivity(
      context,
      0,
      activityIntent,
      PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
    )
    // use the passed in resourceId as notification icon, if not available use the app icon
    val iconResourceId =
      if (notificationResourceId != 0) notificationResourceId else android.R.mipmap.sym_def_app_icon

    val notificationManager =
      context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      if (notificationManager.getNotificationChannel(channelId) == null) {
        val notificationChannel = NotificationChannel(
          channelId, channelName,
          NotificationManager.IMPORTANCE_HIGH
        )
        notificationChannel.enableLights(false)
        notificationChannel.lightColor = Color.RED
        notificationChannel.enableVibration(false)
        notificationManager.createNotificationChannel(notificationChannel)
      }
      val notification: Notification.Builder = Notification.Builder(context, channelId)
        .setContentTitle(title)
        .setContentText(content)
        .setStyle(Notification.BigTextStyle().bigText(content))
        .setOngoing(true)
        .setCategory(Notification.CATEGORY_SERVICE)
        .setContentIntent(pendingIntent)
        .setSmallIcon(iconResourceId)
      notification.build()
    } else {
      val notification: NotificationCompat.Builder = NotificationCompat.Builder(context, channelId)
        .setContentTitle(title)
        .setContentText(content)
        .setStyle(NotificationCompat.BigTextStyle().bigText(content))
        .setOngoing(true)
        .setCategory(Notification.CATEGORY_SERVICE)
        .setPriority(NotificationManager.IMPORTANCE_HIGH)
        .setContentIntent(pendingIntent)
        .setSmallIcon(iconResourceId)
      notification.build()
    }
  }

}
