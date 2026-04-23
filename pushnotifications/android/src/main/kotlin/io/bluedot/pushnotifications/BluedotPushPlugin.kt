package io.bluedot.pushnotifications

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import au.com.bluedot.point.net.engine.ServiceManager
import au.com.bluedot.pushnotifications.RezolvePushData
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
                ServiceManager.getInstance(context).pushNotificationsManager.onMessageReceived(remoteMessage.toRezolvePushData())
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
            "onNewFcmToken" -> {
                val token = call.argument<String>("token") ?: return result.error("INVALID_ARG", "token is required", null)
                ServiceManager.getInstance(context).pushNotificationsManager.onNewFcmToken(token)
                result.success(null)
            }
            "onMessageReceived" -> {
                @Suppress("UNCHECKED_CAST")
                val data = call.arguments<Map<String, String>>() ?: emptyMap()
                val pushData = RezolvePushData(
                    title          = data[RezolvePushData.NOTIFICATION_TITLE_KEY].orEmpty(),
                    body           = data[RezolvePushData.NOTIFICATION_BODY_KEY].orEmpty(),
                    pushVersion    = data[RezolvePushData.KEY_REZOLVE_PUSH_VERSION].orEmpty(),
                    campaignId     = data[RezolvePushData.KEY_CAMPAIGN_ID].orEmpty(),
                    zoneId         = data[RezolvePushData.KEY_ZONE_ID].orEmpty(),
                    notificationId = data[RezolvePushData.KEY_NOTIFICATION_ID].orEmpty(),
                    data           = data.filterKeys { it !in RezolvePushData.KNOWN_KEYS }
                )
                ServiceManager.getInstance(context).pushNotificationsManager.onMessageReceived(pushData)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
