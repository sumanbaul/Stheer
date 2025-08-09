package com.mindflo.stheer

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import java.io.ByteArrayOutputStream
import java.util.Calendar

object UsageBridge {
    fun hasUsageAccess(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow("android:get_usage_stats", android.os.Process.myUid(), context.packageName)
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow("android:get_usage_stats", android.os.Process.myUid(), context.packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun openUsageAccessSettings(context: Context) {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    fun getDailySummary(context: Context): Map<String, Any> {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val cal = Calendar.getInstance()
        val end = cal.timeInMillis
        cal.add(Calendar.DAY_OF_YEAR, -1)
        val start = cal.timeInMillis

        val stats: List<UsageStats> = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)
        var totalMs = 0L
        stats.forEach { totalMs += (it.totalTimeInForeground) }
        val screenTimeMinutes = (totalMs / 60000L).toInt()
        val pickups = 0 // Not directly available via public API
        return mapOf("screenTimeMinutes" to screenTimeMinutes, "pickups" to pickups)
    }

    fun getMostUsedApps(context: Context, limit: Int): List<Map<String, Any>> {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val cal = Calendar.getInstance()
        val end = cal.timeInMillis
        cal.add(Calendar.DAY_OF_YEAR, -1)
        val start = cal.timeInMillis
        val stats: List<UsageStats> = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)

        val top = stats.sortedByDescending { it.totalTimeInForeground }.take(limit)
        return top.map {
            mapOf(
                "packageName" to it.packageName,
                "minutes" to (it.totalTimeInForeground / 60000L).toInt()
            )
        }
    }

    fun getMostUsedAppsDetailed(context: Context, limit: Int): List<Map<String, Any>> {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val pm = context.packageManager
        val cal = Calendar.getInstance()
        val end = cal.timeInMillis
        cal.add(Calendar.DAY_OF_YEAR, -1)
        val start = cal.timeInMillis
        val stats: List<UsageStats> = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)
        val top = stats.sortedByDescending { it.totalTimeInForeground }.take(limit)

        fun drawableToBase64(drawable: Drawable): String {
            val bitmap: Bitmap = when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                else -> {
                    val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
                    val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
                    val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    val canvas = Canvas(bmp)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bmp
                }
            }
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            val bytes = stream.toByteArray()
            return Base64.encodeToString(bytes, Base64.NO_WRAP)
        }

        val list = ArrayList<Map<String, Any>>()
        for (it in top) {
            try {
                val appInfo = pm.getApplicationInfo(it.packageName, 0)
                val label = pm.getApplicationLabel(appInfo).toString()
                val icon = pm.getApplicationIcon(appInfo)
                val iconB64 = drawableToBase64(icon)
                list.add(
                    mapOf(
                        "packageName" to it.packageName,
                        "label" to label,
                        "minutes" to (it.totalTimeInForeground / 60000L).toInt(),
                        "iconBase64" to iconB64
                    )
                )
            } catch (e: Exception) {
                list.add(
                    mapOf(
                        "packageName" to it.packageName,
                        "label" to it.packageName,
                        "minutes" to (it.totalTimeInForeground / 60000L).toInt()
                    )
                )
            }
        }
        return list
    }

    fun getWeeklyMinutes(context: Context): List<Int> {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val cal = Calendar.getInstance()
        // Build 7 buckets: from 6 days ago to today, each day midnight..next midnight
        val result = IntArray(7) { 0 }
        // Start from 6 days ago
        for (i in 6 downTo 0) {
            val dayIndex = 6 - i // 0..6
            val startCal = Calendar.getInstance()
            startCal.timeInMillis = cal.timeInMillis
            startCal.add(Calendar.DAY_OF_YEAR, -i)
            startCal.set(Calendar.HOUR_OF_DAY, 0)
            startCal.set(Calendar.MINUTE, 0)
            startCal.set(Calendar.SECOND, 0)
            startCal.set(Calendar.MILLISECOND, 0)

            val endCal = Calendar.getInstance()
            endCal.timeInMillis = startCal.timeInMillis
            endCal.add(Calendar.DAY_OF_YEAR, 1)

            val stats: List<UsageStats> = usm.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startCal.timeInMillis,
                endCal.timeInMillis
            )
            var totalMs = 0L
            stats.forEach { totalMs += it.totalTimeInForeground }
            result[dayIndex] = (totalMs / 60000L).toInt()
        }
        return result.toList()
    }
}


