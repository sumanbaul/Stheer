package com.mindflo.stheer

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.DataType
import com.google.android.gms.fitness.data.Field
import com.google.android.gms.fitness.request.DataReadRequest
import com.google.android.gms.fitness.data.DataSet
import com.google.android.gms.fitness.result.DataReadResponse
import com.google.android.gms.tasks.Task
import java.util.Calendar
import java.util.concurrent.TimeUnit

object FitnessBridge {
    private const val TAG = "FitnessBridge"
    private var connected: Boolean = false
    private var account: com.google.android.gms.auth.api.signin.GoogleSignInAccount? = null
    const val REQUEST_OAUTH: Int = 9002
    
    // Callback interfaces for async operations
    interface StepsCallback {
        fun onSuccess(steps: Int)
        fun onError(error: String)
    }
    
    interface WeeklyStepsCallback {
        fun onSuccess(steps: List<Int>)
        fun onError(error: String)
    }

    fun isConnected(): Boolean = connected

    fun connect(activity: Activity): Boolean {
        try {
            Log.d(TAG, "Attempting to connect to Google Fit")
            
            // Check if Google Play Services is available
            if (!isGooglePlayServicesAvailable(activity)) {
                Log.w(TAG, "Google Play Services not available")
                return false
            }
            
            val fitnessOptions = FitnessOptions.builder()
                .addDataType(DataType.TYPE_STEP_COUNT_CUMULATIVE, FitnessOptions.ACCESS_READ)
                .addDataType(DataType.TYPE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
                .build()

            account = GoogleSignIn.getAccountForExtension(activity, fitnessOptions)
            
            if (account == null) {
                Log.w(TAG, "No Google account found")
                return false
            }

            if (!GoogleSignIn.hasPermissions(account, fitnessOptions)) {
                Log.d(TAG, "Requesting Google Fit permissions")
                // Launch permission flow
                val signInClient = GoogleSignIn.getClient(activity, GoogleSignInOptions.DEFAULT_SIGN_IN)
                val intent = signInClient.signInIntent
                activity.startActivityForResult(intent, REQUEST_OAUTH)
                return false
            } else {
                Log.d(TAG, "Google Fit permissions already granted")
                connected = true
                return true
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error connecting to Google Fit", e)
            connected = false
            return false
        }
    }
    
    private fun isGooglePlayServicesAvailable(context: Context): Boolean {
        return try {
            val googleApiAvailability = com.google.android.gms.common.GoogleApiAvailability.getInstance()
            val resultCode = googleApiAvailability.isGooglePlayServicesAvailable(context)
            resultCode == com.google.android.gms.common.ConnectionResult.SUCCESS
        } catch (e: Exception) {
            Log.e(TAG, "Error checking Google Play Services availability", e)
            false
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_OAUTH) {
            try {
                val task = GoogleSignIn.getSignedInAccountFromIntent(data)
                val account = task.getResult(com.google.android.gms.common.api.ApiException::class.java)
                
                if (account != null) {
                    Log.d(TAG, "Google Sign-In successful")
                    this.account = account
                    
                    // Check if we have fitness permissions
                    val fitnessOptions = FitnessOptions.builder()
                        .addDataType(DataType.TYPE_STEP_COUNT_CUMULATIVE, FitnessOptions.ACCESS_READ)
                        .addDataType(DataType.TYPE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
                        .build()
                    
                    if (GoogleSignIn.hasPermissions(account, fitnessOptions)) {
                        Log.d(TAG, "Fitness permissions granted")
                        connected = true
                        return true
                    } else {
                        Log.w(TAG, "Fitness permissions not granted")
                        connected = false
                        return false
                    }
                } else {
                    Log.w(TAG, "Google Sign-In failed")
                    connected = false
                    return false
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error handling activity result", e)
                connected = false
                return false
            }
        }
        return false
    }

    fun hasPermissions(activity: Activity): Boolean {
        try {
            val fitnessOptions = FitnessOptions.builder()
                .addDataType(DataType.TYPE_STEP_COUNT_CUMULATIVE, FitnessOptions.ACCESS_READ)
                .addDataType(DataType.TYPE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
                .build()
            
            account = GoogleSignIn.getAccountForExtension(activity, fitnessOptions)
            val hasPermissions = GoogleSignIn.hasPermissions(account, fitnessOptions)
            
            Log.d(TAG, "Has fitness permissions: $hasPermissions")
            return hasPermissions
        } catch (e: Exception) {
            Log.e(TAG, "Error checking permissions", e)
            return false
        }
    }

    fun isGoogleFitInstalled(context: Context): Boolean {
        return try {
            context.packageManager.getPackageInfo("com.google.android.apps.fitness", 0)
            true
        } catch (e: Exception) {
            Log.d(TAG, "Google Fit not installed: ${e.message}")
            false
        }
    }

    fun getTodaySteps(context: Context, callback: StepsCallback) {
        try {
            val currentAccount = account
            if (currentAccount == null) {
                Log.w(TAG, "No account available for getting steps")
                callback.onError("No account available")
                return
            }
            
            Log.d(TAG, "Fetching today's steps")
            val task = Fitness.getHistoryClient(context, currentAccount)
                .readDailyTotal(DataType.TYPE_STEP_COUNT_DELTA)
            
            // Use async callback instead of blocking await
            task.addOnSuccessListener { dataSet ->
                try {
                    if (!dataSet.isEmpty) {
                        val steps = dataSet.dataPoints.first().getValue(Field.FIELD_STEPS).asInt()
                        Log.d(TAG, "Today's steps: $steps")
                        callback.onSuccess(steps)
                    } else {
                        Log.d(TAG, "No step data available for today")
                        callback.onSuccess(0)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error processing step data", e)
                    callback.onError("Error processing data: ${e.message}")
                }
            }.addOnFailureListener { exception ->
                Log.e(TAG, "Error getting today's steps", exception)
                callback.onError("Failed to fetch steps: ${exception.message}")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error getting today's steps", e)
            callback.onError("Error: ${e.message}")
        }
    }

    fun getWeeklySteps(context: Context, callback: WeeklyStepsCallback) {
        try {
            val currentAccount = account
            if (currentAccount == null) {
                Log.w(TAG, "No account available for getting weekly steps")
                callback.onError("No account available")
                return
            }
            
            Log.d(TAG, "Fetching weekly steps")
            val cal = Calendar.getInstance()
            val end = cal.timeInMillis
            cal.add(Calendar.DAY_OF_YEAR, -6)
            val start = cal.timeInMillis
            
            val readRequest = DataReadRequest.Builder()
                .aggregate(DataType.TYPE_STEP_COUNT_DELTA)
                .bucketByTime(1, TimeUnit.DAYS)
                .setTimeRange(start, end, TimeUnit.MILLISECONDS)
                .build()
            
            val task = Fitness.getHistoryClient(context, currentAccount)
                .readData(readRequest)
            
            // Use async callback instead of blocking await
            task.addOnSuccessListener { response ->
                try {
                    val list = MutableList(7) { 0 }
                    
                    var idx = 0
                    for (bucket in response.buckets) {
                        val dataSet: DataSet? = bucket.getDataSet(DataType.AGGREGATE_STEP_COUNT_DELTA)
                        val points = dataSet?.dataPoints ?: emptyList()
                        if (points.isNotEmpty()) {
                            list[idx] = points.first().getValue(Field.FIELD_STEPS).asInt()
                        }
                        idx = (idx + 1).coerceAtMost(6)
                    }
                    
                    Log.d(TAG, "Weekly steps: $list")
                    callback.onSuccess(list)
                } catch (e: Exception) {
                    Log.e(TAG, "Error processing weekly step data", e)
                    callback.onError("Error processing data: ${e.message}")
                }
            }.addOnFailureListener { exception ->
                Log.e(TAG, "Error getting weekly steps", exception)
                callback.onError("Failed to fetch weekly steps: ${exception.message}")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error getting weekly steps", e)
            callback.onError("Error: ${e.message}")
        }
    }

    // Synchronous wrapper methods for backward compatibility
    fun getTodayStepsSync(context: Context): Int {
        var result = 0
        var error = ""
        val latch = java.util.concurrent.CountDownLatch(1)
        
        getTodaySteps(context, object : StepsCallback {
            override fun onSuccess(steps: Int) {
                result = steps
                latch.countDown()
            }
            
            override fun onError(errorMsg: String) {
                error = errorMsg
                latch.countDown()
            }
        })
        
        try {
            latch.await(10, TimeUnit.SECONDS)
        } catch (e: InterruptedException) {
            Log.e(TAG, "Timeout waiting for steps", e)
        }
        
        if (error.isNotEmpty()) {
            Log.e(TAG, "Error in sync call: $error")
        }
        
        return result
    }

    fun getWeeklyStepsSync(context: Context): List<Int> {
        var result = MutableList(7) { 0 }
        var error = ""
        val latch = java.util.concurrent.CountDownLatch(1)
        
        getWeeklySteps(context, object : WeeklyStepsCallback {
            override fun onSuccess(steps: List<Int>) {
                result = steps.toMutableList()
                latch.countDown()
            }
            
            override fun onError(errorMsg: String) {
                error = errorMsg
                latch.countDown()
            }
        })
        
        try {
            latch.await(15, TimeUnit.SECONDS)
        } catch (e: InterruptedException) {
            Log.e(TAG, "Timeout waiting for weekly steps", e)
        }
        
        if (error.isNotEmpty()) {
            Log.e(TAG, "Error in sync call: $error")
        }
        
        return result
    }

    fun disconnect() {
        Log.d(TAG, "Disconnecting from Google Fit")
        connected = false
        account = null
    }
}



