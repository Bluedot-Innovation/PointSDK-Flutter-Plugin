package io.bluedot.pushnotifications

import android.content.Context
import android.os.Handler
import android.os.Looper
import au.com.bluedot.point.api.push.model.RezolvePushData
import com.rezolve.pushnotifications.PushNotificationsEventReceiver

/**
 * Receives Bluedot push notification callbacks and forwards them to Flutter via
 * [BluedotPushPlugin.sendOrQueueEvent]. Events that arrive before the Flutter engine has
 * attached (e.g. a cold-start-on-notification-tap) are buffered by the plugin and replayed
 * once it attaches.
 *
 * Registered automatically in this plugin's AndroidManifest.xml — no manual
 * manifest entry required in the consuming app.
 */
class AppPushNotificationsEventReceiver : PushNotificationsEventReceiver() {

    override fun onNotificationReceived(rezolvePushData: RezolvePushData, context: Context) {
        Handler(Looper.getMainLooper()).post {
            BluedotPushPlugin.sendOrQueueEvent(
                "onNotificationReceived",
                rezolvePushData.toMap()
            )
        }
    }

    override fun onNotificationClicked(rezolvePushData: RezolvePushData, context: Context) {
        Handler(Looper.getMainLooper()).post {
            BluedotPushPlugin.sendOrQueueEvent(
                "onNotificationClicked",
                rezolvePushData.toMap()
            )
        }
    }

    private fun RezolvePushData.toMap(): Map<String, Any?> = mapOf(
        "title"          to title,
        "body"           to body,
        "pushVersion"    to pushVersion,
        "campaignId"     to campaignId,
        "zoneId"         to zoneId,
        "notificationId" to notificationId,
        "data"           to data
    )
}

