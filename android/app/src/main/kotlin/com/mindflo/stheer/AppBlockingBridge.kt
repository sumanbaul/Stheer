package com.mindflo.stheer

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import java.util.concurrent.Executors

object AppBlockingBridge {
    private const val TAG = "AppBlockingBridge"
    private val executor = Executors.newSingleThreadExecutor()
    
    // Check if app blocking is supported
    fun isAppBlockingSupported(context: Context): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
    }
    
    // Block apps by package names
    fun blockApps(
        context: Context,
        packageNames: List<String>,
        categories: List<String>,
        durationMinutes: Int
    ): Boolean {
        if (!isAppBlockingSupported(context)) {
            Log.w(TAG, "App blocking not supported on this Android version")
            return false
        }
        
        try {
            Log.d(TAG, "Blocking apps: $packageNames, categories: $categories for $durationMinutes minutes")
            
            // For now, we'll use a simple approach by opening app info settings
            // In a production app, you'd implement actual app blocking using:
            // 1. Device Policy Controller (DPC) for enterprise devices
            // 2. Parental Controls API
            // 3. Custom launcher with app hiding
            // 4. Accessibility services for app blocking
            
            if (packageNames.isNotEmpty()) {
                // Open settings for the first app to allow user to disable it
                val packageName = packageNames[0]
                openAppInfoSettings(context, packageName)
            }
            
            // Schedule unblocking after duration
            if (durationMinutes > 0) {
                executor.execute {
                    Thread.sleep(durationMinutes * 60 * 1000L)
                    unblockApps(context, packageNames, categories)
                }
            }
            
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error blocking apps: ${e.message}")
            return false
        }
    }
    
    // Unblock apps
    fun unblockApps(
        context: Context,
        packageNames: List<String>,
        categories: List<String>
    ): Boolean {
        try {
            Log.d(TAG, "Unblocking apps: $packageNames, categories: $categories")
            
            // In a production app, you'd implement actual app unblocking
            // For now, we'll just log the action
            
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error unblocking apps: ${e.message}")
            return false
        }
    }
    
    // Open app info settings for manual disabling
    private fun openAppInfoSettings(context: Context, packageName: String) {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            intent.data = Uri.parse("package:$packageName")
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            
            Log.d(TAG, "Opened app info settings for: $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "Error opening app info settings: ${e.message}")
        }
    }
    
    // Get installed apps
    fun getInstalledApps(context: Context): List<Map<String, Any>> {
        val packageManager = context.packageManager
        val installedPackages = packageManager.getInstalledPackages(0)
        val apps = mutableListOf<Map<String, Any>>()
        
        for (packageInfo in installedPackages) {
            try {
                val applicationInfo = packageInfo.applicationInfo
                if (applicationInfo == null) {
                    Log.w(TAG, "Skipping app ${packageInfo.packageName}: null applicationInfo")
                    continue
                }
                
                // Get app name - prioritize app name over package name
                val appName = try {
                    val label = packageManager.getApplicationLabel(applicationInfo)
                    if (label != null && label.isNotEmpty() && label != packageInfo.packageName) {
                        label.toString()
                    } else {
                        // If no proper label, try to extract a readable name from package name
                        val packageName = packageInfo.packageName
                        if (packageName.contains(".")) {
                            val parts = packageName.split(".")
                            if (parts.isNotEmpty()) {
                                parts.last().replaceFirstChar { it.uppercase() }
                            } else {
                                packageName
                            }
                        } else {
                            packageName
                        }
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "Error getting app label for ${packageInfo.packageName}: ${e.message}")
                    packageInfo.packageName
                }
                
                val isSystemApp = (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
                val isEnabled = applicationInfo.enabled
                val icon = packageManager.getApplicationIcon(applicationInfo)
                
                // Convert icon to base64
                val iconBase64 = drawableToBase64(icon)
                
                // Get app category and type
                val category = getAppCategory(packageInfo.packageName, appName)
                val appType = getAppType(packageInfo.packageName, appName, category)
                
                apps.add(mapOf(
                    "packageName" to packageInfo.packageName,
                    "appName" to appName,
                    "versionName" to (packageInfo.versionName ?: ""),
                    "versionCode" to (if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) packageInfo.longVersionCode else packageInfo.versionCode.toLong()),
                    "installTime" to packageInfo.firstInstallTime,
                    "updateTime" to packageInfo.lastUpdateTime,
                    "isSystemApp" to isSystemApp,
                    "isEnabled" to isEnabled,
                    "iconBase64" to iconBase64,
                    "category" to category,
                    "appType" to appType
                ))
            } catch (e: Exception) {
                Log.w(TAG, "Error processing app ${packageInfo.packageName}: ${e.message}")
            }
        }
        
        // Sort apps by name for better user experience
        apps.sortBy { it["appName"] as String }
        
        return apps
    }
    
    // Convert drawable to base64
    private fun drawableToBase64(drawable: android.graphics.drawable.Drawable): String {
        return try {
            val bitmap = when (drawable) {
                is android.graphics.drawable.BitmapDrawable -> drawable.bitmap
                else -> {
                    val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
                    val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
                    val bmp = android.graphics.Bitmap.createBitmap(width, height, android.graphics.Bitmap.Config.ARGB_8888)
                    val canvas = android.graphics.Canvas(bmp)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bmp
                }
            }
            
            val stream = java.io.ByteArrayOutputStream()
            bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
            val bytes = stream.toByteArray()
            android.util.Base64.encodeToString(bytes, android.util.Base64.NO_WRAP)
        } catch (e: Exception) {
            Log.e(TAG, "Error converting drawable to base64: ${e.message}")
            ""
        }
    }
    
    // Get app category based on package name
    private fun getAppCategory(packageName: String, appName: String): String {
        return when {
            packageName.startsWith("com.android") || packageName.startsWith("android") -> "System"
            packageName.startsWith("com.google.android") -> "Google"
            appName.contains("social") || appName.contains("chat") -> "Social"
            appName.contains("game") || appName.contains("play") -> "Gaming"
            appName.contains("work") || appName.contains("business") -> "Work"
            appName.contains("education") || appName.contains("learn") -> "Education"
            appName.contains("health") || appName.contains("fitness") -> "Health"
            else -> "Other"
        }
    }
    
    // Get app type for focus scoring
    private fun getAppType(packageName: String, appName: String, category: String): String {
        return when {
            packageName.startsWith("com.android") || packageName.startsWith("android") -> "System"
            packageName.startsWith("com.google.android") -> "Google"
            appName.contains("social") || appName.contains("chat") || 
            appName.contains("facebook") || appName.contains("instagram") || 
            appName.contains("twitter") || appName.contains("whatsapp") -> "Social"
            appName.contains("game") || appName.contains("play") || 
            appName.contains("minecraft") || appName.contains("fortnite") -> "Gaming"
            appName.contains("work") || appName.contains("business") || 
            appName.contains("office") || appName.contains("slack") -> "Work"
            appName.contains("education") || appName.contains("learn") || 
            appName.contains("duolingo") || appName.contains("coursera") -> "Education"
            appName.contains("health") || appName.contains("fitness") || 
            appName.contains("strava") || appName.contains("fitbit") -> "Health"
            appName.contains("video") || appName.contains("music") || 
            appName.contains("youtube") || appName.contains("netflix") -> "Entertainment"
            else -> "Neutral"
        }
    }
    
    // Check if app is currently blocked
    fun isAppBlocked(context: Context, packageName: String): Boolean {
        try {
            val packageManager = context.packageManager
            val packageInfo = packageManager.getPackageInfo(packageName, 0)
            val applicationInfo = packageInfo.applicationInfo
            return applicationInfo?.enabled == false
        } catch (e: Exception) {
            Log.e(TAG, "Error checking if app is blocked: ${e.message}")
            return false
        }
    }
    
    // Get app usage statistics (requires PACKAGE_USAGE_STATS permission)
    fun getAppUsageStats(context: Context, packageName: String, days: Int): Map<String, Any> {
        val stats = mutableMapOf<String, Any>()
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as android.app.usage.UsageStatsManager
                
                val endTime = System.currentTimeMillis()
                val startTime = endTime - (days * 24 * 60 * 60 * 1000L)
                
                val usageStats = usageStatsManager.queryUsageStats(
                    android.app.usage.UsageStatsManager.INTERVAL_DAILY,
                    startTime,
                    endTime
                )
                
                var totalTime = 0L
                var launchCount = 0
                
                for (stat in usageStats) {
                    if (stat.packageName == packageName) {
                        totalTime += stat.totalTimeInForeground
                        launchCount++
                    }
                }
                
                stats["totalTimeMinutes"] = (totalTime / 60000L).toInt()
                stats["launchCount"] = launchCount
                stats["averageTimePerSession"] = if (launchCount > 0) (totalTime / launchCount / 60000L).toInt() else 0
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting app usage stats: ${e.message}")
        }
        
        return stats
    }
}
