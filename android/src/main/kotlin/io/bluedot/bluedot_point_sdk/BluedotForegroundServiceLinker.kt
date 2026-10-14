package io.bluedot.bluedot_point_sdk

import android.content.Context
import au.com.bluedot.point.net.engine.ServiceManager

/**
 * Public entry point that lets a host app's own foreground [android.app.Service] link/unlink
 * itself with the Bluedot Point SDK, without the host app needing to declare its own Gradle
 * dependency on the (unpublished-to-consumers) Point SDK Android artifact.
 *
 * The bluedot_point_sdk plugin already depends on the Point SDK internally (as an
 * `implementation` dependency, so its classes are *not* exposed on a consuming app's compile
 * classpath even though they are present at runtime). This object re-exposes just the two calls
 * a host-owned foreground service needs, compiled against the SDK from inside the plugin itself.
 *
 * Usage from a host app's `Service` (Kotlin/Java), after calling `startForeground(...)`:
 * ```kotlin
 * override fun onCreate() {
 *   super.onCreate()
 *   startForeground(NOTIFICATION_ID, buildNotification())
 *   try {
 *     BluedotForegroundServiceLinker.link(applicationContext)
 *   } catch (e: Exception) {
 *     // handle link failure
 *   }
 * }
 *
 * override fun onDestroy() {
 *   BluedotForegroundServiceLinker.unlink(applicationContext)
 *   super.onDestroy()
 * }
 * ```
 *
 * No additional `point_sdk_android` dependency is required in the host app's `build.gradle`.
 *
 * [link] and [unlink] are idempotent: calling [link] while already linked, or [unlink] while
 * not linked, is a no-op rather than an error, since there is a single, shared link state
 * (not one per feature) and callers (including the Dart API and this native helper) could
 * otherwise race each other into an unbalanced state.
 */
object BluedotForegroundServiceLinker {
  @JvmStatic
  @Throws(Exception::class)
  fun link(context: Context) {
    val serviceManager = ServiceManager.getInstance(context)
    if (!serviceManager.isForegroundServiceLinked) {
      serviceManager.linkForegroundService()
    }
  }

  @JvmStatic
  @Throws(Exception::class)
  fun unlink(context: Context) {
    val serviceManager = ServiceManager.getInstance(context)
    if (serviceManager.isForegroundServiceLinked) {
      serviceManager.unlinkForegroundService()
    }
  }

  /**
   * Returns whether a foreground service is currently linked to the Point SDK (see [link]).
   */
  @JvmStatic
  fun isForegroundServiceLinked(context: Context): Boolean {
    return ServiceManager.getInstance(context).isForegroundServiceLinked
  }
}
