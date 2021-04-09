package com.HeartStartVet

import android.Manifest
import io.flutter.embedding.android.FlutterActivity

import android.bluetooth.*
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.*
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.PermissionChecker
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.random.Random.Default.nextInt


class MainActivity: FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/battery"
    private var bluetoothGattServer: BluetoothGattServer? = null

    var a = "r"
    var b = "r"
    var c = "r"
    val colors = arrayOf("r", "o", "y" , "g" , "b" , "v")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.e("heeeeelo", ";lkjasdf;lkjasdf;lkjadslfkj")
        a = colors[nextInt (0, 5)]
        b = colors[nextInt(0, 5)]
        c = colors[ nextInt(0, 5)]
        startServer()
    }


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod( "set colors: " + a + b + c , null)
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }



    }
    private fun getBatteryLevel(): Int {
        return 100
    }

    private fun startServer(): Int {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (ContextCompat.checkSelfPermission(baseContext,
                            Manifest.permission.ACCESS_BACKGROUND_LOCATION)
                    != PackageManager.PERMISSION_GRANTED) {
                val MY_PERMISSION = 0
                ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION), MY_PERMISSION)
            }
        }

        val gattServerCallback = object : BluetoothGattServerCallback() {

            override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
                Log.e("asdf", device.toString())
            }

            override fun onCharacteristicReadRequest(device: BluetoothDevice, requestId: Int, offset: Int,
                                                     characteristic: BluetoothGattCharacteristic) {

            }

            override fun onCharacteristicWriteRequest(device: BluetoothDevice?, requestId: Int, characteristic: BluetoothGattCharacteristic?, preparedWrite: Boolean, responseNeeded: Boolean, offset: Int, value: ByteArray?) {
                super.onCharacteristicWriteRequest(device, requestId, characteristic, preparedWrite, responseNeeded, offset, value)
                if (value != null) {
                    Log.e("asdf", value.toString(Charsets.UTF_8) )

                    Handler(Looper.getMainLooper()).post(Runnable {
                        // Call the desired channel message here.
                        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod(value.toString(Charsets.UTF_8) , null)
                    })

                }

                Log.e("adsf" ,  "neeeeeeeds respncessdfsleiflIJ!!  $responseNeeded")
                bluetoothGattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null);
            }
        }
        val pUuid = ParcelUuid(UUID.fromString("a228b618-d7a0-4ec7-87a5-a7b4e6b865cf"))
        val advertiser = BluetoothAdapter.getDefaultAdapter().bluetoothLeAdvertiser ?: return 0
        var service: BluetoothGattService = BluetoothGattService(UUID.fromString("a228b618-d7a0-4ec7-87a5-a7b4e6b865cf"),
                BluetoothGattService.SERVICE_TYPE_PRIMARY)
        var characteristic: BluetoothGattCharacteristic = BluetoothGattCharacteristic(
                UUID.fromString("a228b618-d7a0-4ec7-87a5-a7b4e6b865cf"),
                BluetoothGattCharacteristic.PROPERTY_WRITE,
                BluetoothGattCharacteristic.PERMISSION_WRITE )
        service.addCharacteristic(characteristic)

        var manager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager

        bluetoothGattServer = manager.openGattServer(this, gattServerCallback)
        bluetoothGattServer?.clearServices()
        bluetoothGattServer?.addService(service)

        val settings = AdvertiseSettings.Builder()
                .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
                .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
                .setConnectable(true)
                .build()






        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod( "set colors: " + a + b + c , null)

        BluetoothAdapter.getDefaultAdapter().setName("a228b" + a + b + c)
        val data = AdvertiseData.Builder()
                .setIncludeDeviceName(true)
                .addServiceUuid(pUuid)
                .build()
        val advertisingCallback: AdvertiseCallback = object : AdvertiseCallback() {
            override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
                super.onStartSuccess(settingsInEffect)
                Log.e("adverstising", "aaaaaaaaaaaaaaaaaaa")
            }

            override fun onStartFailure(errorCode: Int) {
                Log.e("Bluetooth", "Advertising onStartFailure: $errorCode")
                super.onStartFailure(errorCode)
            }
        }

        advertiser.startAdvertising( settings, data, advertisingCallback )


        return 1
    }

}