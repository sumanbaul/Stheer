package com.mindflo.stheer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.content.ComponentName
import android.text.TextUtils

class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL = "com.mindflo.stheer/notifications/methods"
    private val EVENT_CHANNEL = "com.mindflo.stheer/notifications/events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "openNotificationAccessSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERR", e.message, null)
                    }
                }
                "isNotificationAccessEnabled" -> {
                    try {
                        result.success(isNotificationServiceEnabled())
                    } catch (e: Exception) {
                        result.error("ERR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        // EventChannel stream is published from the service
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(NotificationStreamHandler)
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val pkgName = applicationContext.packageName
        val cn = ComponentName(pkgName, "com.mindflo.stheer.NotificationBridgeService")
        val flat = cn.flattenToString()
        val enabledListeners = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        if (enabledListeners.isNullOrEmpty()) return false
        val entries = enabledListeners.split(":")
        for (entry in entries) {
            if (!TextUtils.isEmpty(entry) && entry == flat) {
                return true
            }
        }
        return false
    }
}


