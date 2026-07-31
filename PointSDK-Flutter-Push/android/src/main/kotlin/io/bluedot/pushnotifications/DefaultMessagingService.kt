package io.bluedot.pushnotifications

import au.com.bluedot.point.net.engine.ServiceManager
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.rezolve.pushnotifications.isRezolvePushNotification
import com.rezolve.pushnotifications.toRezolvePushData

/**
 * Default FCM handler that forwards Bluedot push messages to the Bluedot Push SDK.
 *
 * Registered in the library manifest at [android:priority="-1"][intent-filter], so any
 * [FirebaseMessagingService] the consumer app registers at the default priority (0) takes
 * precedence and this service is never reached.
 *
 * ## Integration patterns
 *
 * ### Pattern A — automatic (recommended when not using @react-native-firebase/messaging)
 * No extra work needed. This service handles FCM automatically.
 *
 * ### Pattern B — @react-native-firebase/messaging
 * That library registers its own [FirebaseMessagingService] at priority 0, which pre-empts
 * this service. Forward messages to Bluedot from your JS handlers instead:
 * ```
 * messaging().onMessage(msg => PushNotifications.onMessageReceived(msg));
 * messaging().onTokenRefresh(token => PushNotifications.onNewFcmToken(token));
 * ```
 *
 * ### Pattern C — multiple push sources (e.g. Airship + Bluedot)
 * Create your own [FirebaseMessagingService] (default intent-filter priority 0).
 * Android routes all FCM messages to your service; this service never fires.
 * Forward Bluedot messages from your service:
 * ```kotlin
 * if (remoteMessage.isRezolvePushNotification()) {
 *     ServiceManager.getInstance(this)
 *         .pushNotificationsManager
 *         .onMessageReceived(remoteMessage.toRezolvePushData())
 * }
 * ServiceManager.getInstance(this)
 *     .pushNotificationsManager
 *     .onNewFcmToken(token)          // in onNewToken()
 * ```
 */
class DefaultMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        if (remoteMessage.isRezolvePushNotification()) {
            ServiceManager.getInstance(this).pushNotificationsManager.onMessageReceived(remoteMessage.toRezolvePushData())
        }
    }

    override fun onNewToken(token: String) {
        ServiceManager.getInstance(this).pushNotificationsManager.onNewFcmToken(token)
    }

    companion object {
        const val TAG = "DefaultMessagingService"
    }
}
