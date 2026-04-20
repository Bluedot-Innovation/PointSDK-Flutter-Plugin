package io.bluedot.bluedot_point_sdk_push

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import au.com.bluedot.point.net.engine.ServiceManager
import au.com.bluedot.pushnotifications.isRezolvePushNotification
import au.com.bluedot.pushnotifications.toRezolvePushData
import com.google.firebase.messaging.RemoteMessage
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** BluedotPushPlugin — the Flutter plugin class for the push notifications sub-module. */
class BluedotPushPlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        /** Exposed so AppPushNotificationsReceiver can invoke push event callbacks. */
        @JvmStatic var pushNotificationsChannel: MethodChannel? = null

        /**
         * Forward a new FCM token to the Bluedot push module.
         * Call this from your FirebaseMessagingService.onNewToken().
         */
        @JvmStatic
        fun onNewFcmToken(token: String, context: Context) {
            ServiceManager.getInstance(context).pushNotificationsManager.onNewFcmToken(token)
        }

        /**
         * Forward an incoming FCM message to the Bluedot push module.
         * Call this from your FirebaseMessagingService.onMessageReceived().
         *
         * Returns true if the message was a Bluedot push notification and was handled,
         * false if you should handle it yourself.
         */
        @JvmStatic
        fun onMessageReceived(remoteMessage: RemoteMessage, context: Context): Boolean {
            if (remoteMessage.isRezolvePushNotification()) {
                ServiceManager.getInstance(context).pushNotificationsManager
                    .onMessageReceived(remoteMessage.toRezolvePushData())
                return true
            }
            return false
        }
    }

    private val PUSH_COMMAND_CHANNEL = "bluedot_point_flutter/push_sdk"
    private val PUSH_EVENTS_CHANNEL  = "bluedot_point_flutter/push_notification_events"

    private var commandChannel: MethodChannel? = null
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (commandChannel == null) {
            commandChannel = MethodChannel(binding.binaryMessenger, PUSH_COMMAND_CHANNEL)
            commandChannel!!.setMethodCallHandler(this)
        }
        if (pushNotificationsChannel == null) {
            pushNotificationsChannel = MethodChannel(binding.binaryMessenger, PUSH_EVENTS_CHANNEL)
        }
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        commandChannel?.setMethodCallHandler(null)
        commandChannel = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setCustomPushNotification" -> setCustomPushNotification(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * Configures the notification appearance used by the push module.
     *
     * Parameters (from Flutter):
     *   - channelId   : String  (required) – notification channel ID
     *   - channelName : String  (required) – notification channel display name
     *   - icon        : String? (optional) – drawable/mipmap resource name
     *   - importance  : Int?    (optional) – NotificationManager.IMPORTANCE_* value,
     *                                        defaults to IMPORTANCE_DEFAULT
     */
    private fun setCustomPushNotification(call: MethodCall, result: Result) {
        val channelId: String? = call.argument("channelId")
        val channelName: String? = call.argument("channelName")
        val icon: String? = call.argument("icon")
        val importance: Int = call.argument("importance") ?: NotificationManager.IMPORTANCE_DEFAULT

        if (channelId.isNullOrBlank() || channelName.isNullOrBlank()) {
            result.error("Missing parameters", "channelId and channelName are required", null)
            return
        }

        try {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (notificationManager.getNotificationChannel(channelId) == null) {
                    val notifChannel = NotificationChannel(channelId, channelName, importance)
                    notificationManager.createNotificationChannel(notifChannel)
                }
            }

            val iconResourceId = findIconResourceId(icon)
            val resolvedIconId =
                if (iconResourceId != 0) iconResourceId else android.R.mipmap.sym_def_app_icon

            val activityIntent =
                context.packageManager.getLaunchIntentForPackage(context.packageName)
            activityIntent?.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, activityIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )

            val customBuilder = NotificationCompat.Builder(context, channelId)
                .setSmallIcon(resolvedIconId)
                .setPriority(importanceToNotificationCompat(importance))
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)

            ServiceManager.getInstance(context)
                .pushNotificationsManager
                .setCustomPushNotification(customBuilder)

            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", e.message, e.toString())
        }
    }

    private fun findIconResourceId(icon: String?): Int {
        if (icon == null) return 0
        val pkg = context.packageName
        var id = context.resources.getIdentifier(icon, "drawable", pkg)
        if (id == 0) id = context.resources.getIdentifier(icon, "mipmap", pkg)
        return id
    }

    private fun importanceToNotificationCompat(importance: Int): Int = when (importance) {
        NotificationManager.IMPORTANCE_HIGH,
        NotificationManager.IMPORTANCE_MAX -> NotificationCompat.PRIORITY_HIGH
        NotificationManager.IMPORTANCE_LOW  -> NotificationCompat.PRIORITY_LOW
        NotificationManager.IMPORTANCE_MIN  -> NotificationCompat.PRIORITY_MIN
        else                                -> NotificationCompat.PRIORITY_DEFAULT
    }
}




