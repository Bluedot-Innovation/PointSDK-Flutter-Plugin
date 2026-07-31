package io.bluedot.bluedot_point_sdk

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import au.com.bluedot.point.net.engine.ServiceManager

/**
 * Auto-initializes the Bluedot SDK's [ServiceManager] during process startup.
 *
 * This ContentProvider is declared in the plugin's AndroidManifest and is invoked
 * automatically by Android before any WorkManager workers run. This ensures that
 * ContextProvider.applicationContext is always set in fresh processes — including
 * cases where WorkManager re-runs a pending DataLogWorker after an app restart
 * following SDK reset/re-initialization.
 */
internal class BluedotInitProvider : ContentProvider() {

    override fun onCreate(): Boolean {
        val ctx = context?.applicationContext ?: return false
        // Calling getInstance initializes ContextProvider.applicationContext inside
        // ServiceManager.init. It is safe to call before the Flutter engine attaches —
        // ServiceManager is a singleton and subsequent calls return the same instance.
        ServiceManager.getInstance(ctx)
        return true
    }

    // The remaining ContentProvider methods are not used.
    override fun query(uri: Uri, projection: Array<out String>?, selection: String?, selectionArgs: Array<out String>?, sortOrder: String?): Cursor? = null
    override fun getType(uri: Uri): String? = null
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int = 0
}

