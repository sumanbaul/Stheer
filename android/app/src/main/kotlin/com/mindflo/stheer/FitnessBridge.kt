package com.mindflo.stheer

import android.app.Activity
import android.content.Context
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
import com.google.android.gms.tasks.Tasks
import java.util.Calendar
import java.util.concurrent.TimeUnit

object FitnessBridge {
    private var connected: Boolean = false
    const val REQUEST_OAUTH: Int = 9002

    fun isConnected(): Boolean = connected

    fun connect(activity: Activity): Boolean {
        val fitnessOptions = FitnessOptions.builder()
            .addDataType(DataType.TYPE_STEP_COUNT_CUMULATIVE, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
            .build()
        val account = GoogleSignIn.getAccountForExtension(activity, fitnessOptions)
        if (!GoogleSignIn.hasPermissions(account, fitnessOptions)) {
            // Launch permission flow
            GoogleSignIn.requestPermissions(activity, REQUEST_OAUTH, account, fitnessOptions)
            return false
        }
        connected = true
        return true
    }

    fun hasPermissions(activity: Activity): Boolean {
        val fitnessOptions = FitnessOptions.builder()
            .addDataType(DataType.TYPE_STEP_COUNT_CUMULATIVE, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
            .build()
        val account = GoogleSignIn.getAccountForExtension(activity, fitnessOptions)
        return GoogleSignIn.hasPermissions(account, fitnessOptions)
    }

    fun getTodaySteps(context: Context): Int {
        return try {
            val acct = GoogleSignIn.getLastSignedInAccount(context) ?: return 0
            val task = Fitness.getHistoryClient(context, acct)
                .readDailyTotal(DataType.TYPE_STEP_COUNT_DELTA)
            val dataSet: DataSet = Tasks.await(task, 3, TimeUnit.SECONDS)
            if (!dataSet.isEmpty) {
                dataSet.dataPoints.first().getValue(Field.FIELD_STEPS).asInt()
            } else 0
        } catch (e: Exception) {
            0
        }
    }

    fun getWeeklySteps(context: Context): List<Int> {
        return try {
            val cal = Calendar.getInstance()
            val end = cal.timeInMillis
            cal.add(Calendar.DAY_OF_YEAR, -6)
            val start = cal.timeInMillis
            val readRequest = DataReadRequest.Builder()
                .aggregate(DataType.TYPE_STEP_COUNT_DELTA)
                .bucketByTime(1, TimeUnit.DAYS)
                .setTimeRange(start, end, TimeUnit.MILLISECONDS)
                .build()
            val acct = GoogleSignIn.getLastSignedInAccount(context) ?: return MutableList(7) { 0 }
            val task = Fitness.getHistoryClient(context, acct)
                .readData(readRequest)
            val response: DataReadResponse = Tasks.await(task, 5, TimeUnit.SECONDS)
            val list = MutableList(7) { 0 }
            var idx = 0
            for (bucket in response.buckets) {
                val dataSet: DataSet? = bucket.getDataSet(DataType.AGGREGATE_STEP_COUNT_DELTA)
                val points = dataSet?.dataPoints ?: emptyList()
                if (points.isNotEmpty()) list[idx] = points.first().getValue(Field.FIELD_STEPS).asInt()
                idx = (idx + 1).coerceAtMost(6)
            }
            list
        } catch (e: Exception) {
            MutableList(7) { 0 }
        }
    }
}


