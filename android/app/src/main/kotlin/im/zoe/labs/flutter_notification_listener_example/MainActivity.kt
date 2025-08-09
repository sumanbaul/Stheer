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
    private val USAGE_CHANNEL = "com.mindflo.stheer/usage"
    private val FITNESS_CHANNEL = "com.mindflo.stheer/fitness"
    private val ALARM_CHANNEL = "com.mindflo.stheer/alarms"

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

        // App usage channel (Android only)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_CHANNEL).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            try {
                when (call.method) {
                    "hasUsageAccess" -> result.success(UsageBridge.hasUsageAccess(applicationContext))
                    "openUsageAccessSettings" -> {
                        UsageBridge.openUsageAccessSettings(applicationContext)
                        result.success(true)
                    }
                    "getDailySummary" -> result.success(UsageBridge.getDailySummary(applicationContext))
                    "getMostUsedApps" -> {
                        val limit = (call.argument<Int>("limit") ?: 10)
                        result.success(UsageBridge.getMostUsedApps(applicationContext, limit))
                    }
                    "getMostUsedAppsDetailed" -> {
                        val limit = (call.argument<Int>("limit") ?: 10)
                        result.success(UsageBridge.getMostUsedAppsDetailed(applicationContext, limit))
                    }
                    "getWeeklyMinutes" -> {
                        result.success(UsageBridge.getWeeklyMinutes(applicationContext))
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("ERR", e.message, null)
            }
        }

        // Fitness / Google Fit bridge (Android only)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FITNESS_CHANNEL).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            try {
                when (call.method) {
                    "connect" -> result.success(FitnessBridge.connect(this))
                    "hasPermissions" -> result.success(FitnessBridge.hasPermissions(this))
                    "isConnected" -> result.success(FitnessBridge.isConnected())
                    "getTodaySteps" -> result.success(FitnessBridge.getTodaySteps(this))
                    "getWeeklySteps" -> result.success(FitnessBridge.getWeeklySteps(this))
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("ERR", e.message, null)
            }
        }

        // Exact alarm permission channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            try {
                when (call.method) {
                    "canScheduleExactAlarms" -> {
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                            val alarmManager = getSystemService(android.content.Context.ALARM_SERVICE) as android.app.AlarmManager
                            result.success(alarmManager.canScheduleExactAlarms())
                        } else {
                            result.success(true)
                        }
                    }
                    "openExactAlarmSettings" -> {
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                            val intent = android.content.Intent(android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                            intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                        } else {
                            val intent = android.content.Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                            intent.data = android.net.Uri.parse("package:" + applicationContext.packageName)
                            intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("ERR", e.message, null)
            }
        }
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


