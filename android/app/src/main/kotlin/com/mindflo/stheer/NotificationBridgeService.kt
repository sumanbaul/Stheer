package com.mindflo.stheer

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.EventChannel
import android.util.Log

object NotificationStreamHandler : EventChannel.StreamHandler {
    @Volatile
    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun emit(map: Map<String, Any?>) {
        try {
            sink?.success(map)
        } catch (e: Throwable) {
            Log.e("NotificationBridge", "emit failed", e)
        }
    }
}

class NotificationBridgeService : NotificationListenerService() {
    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.i("NotificationBridge", "Listener connected")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val n = sbn.notification
        val extras = n.extras
        val title = extras?.getCharSequence("android.title")?.toString()
        val text = extras?.getCharSequence("android.text")?.toString()
        val packageName = sbn.packageName
        val timestamp = sbn.postTime

        val payload = mapOf(
            "title" to title,
            "text" to text,
            "packageName" to packageName,
            "timestamp" to timestamp,
            "createAt" to System.currentTimeMillis()
        )
        NotificationStreamHandler.emit(payload)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        // No-op
    }
}
