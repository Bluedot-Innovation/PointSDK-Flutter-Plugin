package io.bluedot.pushnotifications

import android.content.Context
import au.com.bluedot.pushnotifications.PushNotificationsEventReceiver
import au.com.bluedot.pushnotifications.RezolvePushData

/**
 * Receives Bluedot push notification callbacks and forwards them to Flutter via
 * [BluedotPushPlugin.pushNotificationsChannel].
 *
 * Registered automatically in this plugin's AndroidManifest.xml — no manual
 * manifest entry required in the consuming app.
 */
class AppPushNotificationsEventReceiver : PushNotificationsEventReceiver() {

    override fun onNotificationReceived(rezolvePushData: RezolvePushData, context: Context) {
        BluedotPushPlugin.pushNotificationsChannel?.invokeMethod(
            "onNotificationReceived",
            rezolvePushData.toMap()
        )
    }

    override fun onNotificationClicked(rezolvePushData: RezolvePushData, context: Context) {
        BluedotPushPlugin.pushNotificationsChannel?.invokeMethod(
            "onNotificationClicked",
            rezolvePushData.toMap()
        )
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

