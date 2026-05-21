package com.cgm.cgm_monitor

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Base64
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.ArrayBlockingQueue
import java.util.concurrent.TimeUnit

class LibreOopBridge(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.cgm.cgm_monitor/libre_oop"
        private const val FRAM_SIZE = 344

        private val OOP_PACKAGES = listOf(
            "com.hg4.oopalgorithm.oopalgorithm2",
            "info.nightscout.deeplearning",
            "com.hg4.oopalgorithm.oopalgorithm",
            "org.andesite.lucky8",
        )

        private const val ACTION_LIBRE_DATA = "com.eveningoutpost.dexdrip.LIBRE_DATA"
        private const val ACTION_BLUETOOTH_ENABLE = "com.eveningoutpost.dexdrip.BLUETOOTH_ENABLE"
        private const val ACTION_DECODE_RESULT = "com.eveningoutpost.dexdrip.OOP2_DECODE_FARM_RESULT"
        private const val ACTION_BLE_DECODE_RESULT = "com.eveningoutpost.dexdrip.OOP2_DECODE_BLE_RESULT"
        private const val ACTION_BLE_ENABLE_RESULT = "com.eveningoutpost.dexdrip.OOP2_BLUETOOTH_ENABLE_RESULT"
        private const val ACTION_LIBRE_BLE_DATA = "com.eveningoutpost.dexdrip.LIBRE_BLE_DATA"

        fun register(flutterEngine: FlutterEngine, context: Context) {
            val bridge = LibreOopBridge(context.applicationContext)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler(bridge)
        }
    }

    private val appContext = context.applicationContext
    private var decodeQueue = ArrayBlockingQueue<JSONObject>(1)
    private var bleDecodeQueue = ArrayBlockingQueue<JSONObject>(1)
    private var unlockQueue = ArrayBlockingQueue<JSONObject>(1)
    private var receiverRegistered = false

    private val oopReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
            val action = intent?.action ?: return
            val bundle = intent.extras ?: return
            val jsonStr = bundle.getString("json") ?: return
            try {
                val json = JSONObject(jsonStr)
                val rowId = json.optInt("ROW_ID", -1)
                if (rowId != android.os.Process.myPid()) return

                when (action) {
                    ACTION_DECODE_RESULT -> decodeQueue.offer(json)
                    ACTION_BLE_DECODE_RESULT -> bleDecodeQueue.offer(json)
                    ACTION_BLE_ENABLE_RESULT -> unlockQueue.offer(json)
                }
            } catch (_: Exception) {
            }
        }
    }

    override fun onMethodCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isOop2Installed" -> result.success(findInstalledOopPackages().isNotEmpty())
            "installedOopPackages" -> result.success(findInstalledOopPackages())
            "decodeFram" -> handleDecodeFram(call, result)
            "decodeBle" -> handleDecodeBle(call, result)
            "requestBleUnlock" -> handleBleUnlock(call, result)
            else -> result.notImplemented()
        }
    }

    private fun findInstalledOopPackages(): List<String> {
        val pm = appContext.packageManager
        return OOP_PACKAGES.filter { pkg ->
            try {
                pm.getPackageInfo(pkg, 0)
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    private fun ensureReceiverRegistered() {
        if (receiverRegistered) return
        val filter = IntentFilter().apply {
            addAction(ACTION_DECODE_RESULT)
            addAction(ACTION_BLE_DECODE_RESULT)
            addAction(ACTION_BLE_ENABLE_RESULT)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            appContext.registerReceiver(oopReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            appContext.registerReceiver(oopReceiver, filter)
        }
        receiverRegistered = true
    }

    private fun sendToOop(intent: Intent) {
        val packages = findInstalledOopPackages()
        intent.addFlags(Intent.FLAG_INCLUDE_STOPPED_PACKAGES)
        if (packages.isEmpty()) {
            appContext.sendBroadcast(intent)
        } else {
            for (pkg in packages) {
                appContext.sendBroadcast(Intent(intent).setPackage(pkg))
            }
        }
    }

    private fun handleDecodeFram(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        Thread {
            try {
                ensureReceiverRegistered()
                decodeQueue.clear()

                val fram = call.argument<ByteArray>("fram")
                val patchUid = call.argument<ByteArray>("patchUid")
                val patchInfo = call.argument<ByteArray>("patchInfo")
                val timestamp = call.argument<Long>("timestamp") ?: System.currentTimeMillis()

                if (fram == null || patchUid == null || patchInfo == null || fram.size < FRAM_SIZE) {
                    result.error("INVALID_ARGS", "Missing FRAM/patch data", null)
                    return@Thread
                }

                val intent = Intent(ACTION_LIBRE_DATA).apply {
                    putExtra("com.eveningoutpost.dexdrip.Extras.DATA_BUFFER", fram.copyOf(FRAM_SIZE))
                    putExtra("com.eveningoutpost.dexdrip.Extras.TIMESTAMP", timestamp)
                    putExtra("com.eveningoutpost.dexdrip.Extras.LIBRE_PATCH_UID_BUFFER", patchUid)
                    putExtra("com.eveningoutpost.dexdrip.Extras.LIBRE_PATCH_INFO_BUFFER", patchInfo)
                    putExtra("com.eveningoutpost.dexdrip.Extras.LIBRE_RAW_ID", android.os.Process.myPid())
                    putExtra("TagId", "cgm_monitor")
                }

                sendToOop(intent)

                val json = decodeQueue.poll(12, TimeUnit.SECONDS)
                if (json == null) {
                    result.success(null)
                    return@Thread
                }

                val decodedB64 = json.optString("DecodedBuffer", "")
                val decryptedFram = if (decodedB64.isNotEmpty()) {
                    Base64.decode(decodedB64, Base64.NO_WRAP)
                } else {
                    fram
                }

                val trendBg = jsonArrayToIntList(json.optJSONArray("TrendBg"))
                val historicBg = jsonArrayToIntList(json.optJSONArray("HistoricBg"))

                val sensorAge = if (decryptedFram.size >= 318) {
                    (decryptedFram[316].toInt() and 0xFF) +
                        ((decryptedFram[317].toInt() and 0xFF) shl 8)
                } else {
                    0
                }

                result.success(
                    mapOf(
                        "decryptedFram" to decryptedFram,
                        "trendBg" to trendBg,
                        "historicBg" to historicBg,
                        "sensorAgeMinutes" to sensorAge,
                    )
                )
            } catch (e: Exception) {
                result.error("DECODE_FAILED", e.message, null)
            }
        }.start()
    }

    private fun handleBleUnlock(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        Thread {
            try {
                ensureReceiverRegistered()
                unlockQueue.clear()

                val patchUid = call.argument<ByteArray>("patchUid")
                val patchInfo = call.argument<ByteArray>("patchInfo")
                if (patchUid == null || patchInfo == null) {
                    result.error("INVALID_ARGS", "Missing patch UID/info", null)
                    return@Thread
                }

                val intent = Intent(ACTION_BLUETOOTH_ENABLE).apply {
                    putExtra("com.eveningoutpost.dexdrip.Extras.LIBRE_RAW_ID", android.os.Process.myPid())
                    putExtra("com.eveningoutpost.dexdrip.Extras.LIBRE_PATCH_UID_BUFFER", patchUid)
                    putExtra("com.eveningoutpost.dexdrip.Extras.LIBRE_PATCH_INFO_BUFFER", patchInfo)
                    putExtra("EnableTime", 42)
                    putExtra("ConnectionIndex", 1)
                    putExtra("BtUnlockBufferCount", 2000)
                }

                sendToOop(intent)

                val json = unlockQueue.poll(12, TimeUnit.SECONDS)
                if (json == null) {
                    result.success(null)
                    return@Thread
                }

                val nfcB64 = json.optString("NfcUnlockBuffer", "")
                val btB64 = json.optString("BtUnlockBuffer", "")
                val nfcPayload = if (nfcB64.isNotEmpty()) Base64.decode(nfcB64, Base64.NO_WRAP) else byteArrayOf()
                val btPayload = if (btB64.isNotEmpty()) Base64.decode(btB64, Base64.NO_WRAP) else byteArrayOf()
                val deviceName = json.optString("DeviceName", "")

                result.success(
                    mapOf(
                        "nfcUnlockPayload" to nfcPayload,
                        "btUnlockPayload" to btPayload,
                        "deviceName" to deviceName,
                    )
                )
            } catch (e: Exception) {
                result.error("UNLOCK_FAILED", e.message, null)
            }
        }.start()
    }

    private fun handleDecodeBle(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        Thread {
            try {
                ensureReceiverRegistered()
                bleDecodeQueue.clear()

                val blePacket = call.argument<ByteArray>("blePacket")
                val patchUid = call.argument<ByteArray>("patchUid")
                val timestamp = call.argument<Long>("timestamp") ?: System.currentTimeMillis()

                if (blePacket == null || patchUid == null || blePacket.size < 46) {
                    result.error("INVALID_ARGS", "Missing BLE packet", null)
                    return@Thread
                }

                val intent = Intent(ACTION_LIBRE_BLE_DATA).apply {
                    putExtra("com.eveningoutpost.dexdrip.Extras.DATA_BUFFER", blePacket)
                    putExtra("com.eveningoutpost.dexdrip.Extras.TIMESTAMP", timestamp)
                    putExtra("com.eveningoutpost.dexdrip.Extras.LIBRE_PATCH_UID_BUFFER", patchUid)
                    putExtra("com.eveningoutpost.dexdrip.Extras.LIBRE_RAW_ID", android.os.Process.myPid())
                }

                sendToOop(intent)

                val json = bleDecodeQueue.poll(8, TimeUnit.SECONDS)
                if (json == null) {
                    result.success(null)
                    return@Thread
                }

                val trendBg = jsonArrayToIntList(json.optJSONArray("TrendBg"))
                val historicBg = jsonArrayToIntList(json.optJSONArray("HistoricBg"))
                val current = trendBg.firstOrNull { it in 20..500 } ?: 0

                result.success(
                    mapOf(
                        "currentMgDl" to current,
                        "trendBg" to trendBg,
                        "historicBg" to historicBg,
                    )
                )
            } catch (e: Exception) {
                result.error("BLE_DECODE_FAILED", e.message, null)
            }
        }.start()
    }

    private fun jsonArrayToIntList(array: JSONArray?): List<Int> {
        if (array == null) return emptyList()
        return (0 until array.length()).map { array.getInt(it) }
    }
}
