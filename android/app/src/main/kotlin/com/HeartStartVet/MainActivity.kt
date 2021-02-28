package com.HeartStartVet

import io.flutter.embedding.android.FlutterActivity

import android.bluetooth.*
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.*
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*


class MainActivity: FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/battery"
    private var bluetoothGattServer: BluetoothGattServer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.e("heeeeelo", ";lkjasdf;lkjasdf;lkjadslfkj")
        getBatteryLevel()
    }


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
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
        val advertiser = BluetoothAdapter.getDefaultAdapter().bluetoothLeAdvertiser
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


        BluetoothAdapter.getDefaultAdapter().setName("a228b618")
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