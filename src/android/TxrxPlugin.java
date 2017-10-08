package com.tertiumtechnology.plugin;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ActivityManager;
import android.bluetooth.BluetoothAdapter;
import android.content.Context;

import android.bluetooth.*;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

import com.tertiumtechnology.txrxlib.rw.*;
import com.tertiumtechnology.txrxlib.scan.*;
import com.tertiumtechnology.txrxlib.util.*;

import java.util.HashMap;
import java.util.Map;


public class TxrxPlugin extends CordovaPlugin {

    // Commands
    private static final String ACTION_START_SCAN = "startScan";
    private static final String ACTION_STOP_SCAN = "stopScan";
    private static final String ACTION_CONNECT = "connect";
    private static final String ACTION_DISCONNECT = "disconnect";
    private static final String ACTION_READ_DATA = "readData";
    private static final String ACTION_WRITE_DATA = "writeData";
    private static final String ACTION_IS_DEVICE_CONNECTED = "isDeviceConnected";
    private static final String ACTION_GET_TIMEOUTS = "getTimeouts";
    private static final String ACTION_SET_TIMEOUTS = "setTimeouts";
    private static final String ACTION_SET_DEFAULT_TIMEOUTS = "setDefaultTimeouts";
    private static final String ACTION_REGISTER_CALLBACK = "registerCallback";

    private Activity activity = null;
    private ActivityManager activityManager = null;

    private TxRxScanner scanner = null;
    private TxRxDeviceManager deviceManager = null;
    private HashMap<String, String> devices;

    /* Java Callback Classes */
    private ScanCallbackClass scanCallbackClass;
    private DeviceCallbackClass deviceCallbackClass;

    /* JavaScript callbacks */
    private Map<String, CallbackContext> jsCallbacks;
    private BluetoothAdapter bluetoothAdapter;


    /**
     * ScanCallback Class
     */
    private class ScanCallbackClass implements TxRxScanCallback {

        @Override
        public void onDeviceFound(final BluetoothDevice device) {
            String deviceName = device.getName() == null ? "unknown device" : device.getName();
            String deviceAddress = device.getAddress();

            if (!devices.containsKey(deviceAddress)) {
                devices.put(deviceAddress, deviceName);

                Log.i("TRX-cordova-plugin", "onDeviceFound");

                JSONObject response = new JSONObject();
                try {
                    response.put("name", deviceName);
                    response.put("address", deviceAddress);
                } catch (JSONException e) {
                    //e.printStackTrace(); TODO: error callback
                }

                PluginResult result = new PluginResult(PluginResult.Status.OK, response);
                result.setKeepCallback(true);
                if (jsCallbacks.get("onDeviceFound") != null)
                    jsCallbacks.get("onDeviceFound").sendPluginResult(result);
            }

        }

        @Override
        public void afterStopScan() {

            Log.i("TRX-cordova-plugin", "afterStopScan");

            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("afterStopScan") != null)
                jsCallbacks.get("afterStopScan").sendPluginResult(result);
        }
    }


    /**
     * DeviceCallback Class
     */
    private class DeviceCallbackClass implements TxRxDeviceCallback {
        @Override public void onConnectionError(int errorCode) {


            Log.i("TRX-cordova-plugin", "onConnectionError: " + errorCode);

            PluginResult result = new PluginResult(PluginResult.Status.OK, errorCode);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onConnectionError") != null)
                jsCallbacks.get("onConnectionError").sendPluginResult(result);
        }
        @Override public void onConnectionTimeout() {
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onConnectionTimeout") != null)
                jsCallbacks.get("onConnectionTimeout").sendPluginResult(result);
        }
        @Override public void onDeviceConnected() {
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onDeviceConnected") != null)
                jsCallbacks.get("onDeviceConnected").sendPluginResult(result);
        }
        @Override public void onDeviceDisconnected() {
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onDeviceDisconnected") != null)
                jsCallbacks.get("onDeviceDisconnected").sendPluginResult(result);
        }
        @Override public void onNotifyData(String data) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, data);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onNotifyData") != null)
                jsCallbacks.get("onNotifyData").sendPluginResult(result);
        }
        @Override public void onReadData(String data) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, data);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onReadData") != null)
                jsCallbacks.get("onReadData").sendPluginResult(result);
        }
        @Override public void onReadError(int errorCode) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, errorCode);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onReadError") != null)
                jsCallbacks.get("onReadError").sendPluginResult(result);
        }
        @Override public void onReadNotifyTimeout() {
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onReadNotifyTimeout") != null)
                jsCallbacks.get("onReadNotifyTimeout").sendPluginResult(result);
        }
        @Override public void onTxRxServiceDiscovered() {}
        @Override public void onTxRxServiceNotFound() {}
        @Override public void onWriteData(String data) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, data);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onWriteData") != null)
                jsCallbacks.get("onWriteData").sendPluginResult(result);
        }
        @Override public void onWriteError(int errorCode) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, errorCode);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onWriteError") != null)
                jsCallbacks.get("onWriteError").sendPluginResult(result);
        }
        @Override public void onWriteTimeout() {
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            if  (jsCallbacks.get("onWriteTimeout") != null)
                jsCallbacks.get("onWriteTimeout").sendPluginResult(result);
        }
    }


    /**
     * Cordova: initialize()
     */
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        // Setup properties
        activity = cordova.getActivity();
        activityManager = (ActivityManager) activity.getSystemService(Context.ACTIVITY_SERVICE);
        jsCallbacks = new HashMap<String, CallbackContext>();
        devices = new HashMap<String, String>();
        bluetoothAdapter = BleChecker.getBtAdapter(activity.getApplicationContext());

        // Check if device supports BLE
        if (!BleChecker.isBleSupported(activity.getApplicationContext())) {
            Toast.makeText(activity, "BLE not supported", Toast.LENGTH_SHORT).show();
            activity.finish();
        }

        // Check if Bluetooth is enabled
        // TODO: should not be checked just at initialization
        if (!BleChecker.isBluetoothEnabled(activity.getApplicationContext())) {
            Toast.makeText(activity, "BLE is turned off", Toast.LENGTH_SHORT).show();
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            activity.startActivityForResult(enableBtIntent, 1);
        }

        // Setup
        if (bluetoothAdapter != null) {
            scanCallbackClass = new ScanCallbackClass();
            deviceCallbackClass = new DeviceCallbackClass();
            scanner = new TxRxScanner(bluetoothAdapter, scanCallbackClass);
            TxRxTimeouts txRxTimeouts = TxRxPreferences.getTimeouts(activity.getApplicationContext());
            deviceManager = new TxRxDeviceManager(bluetoothAdapter, deviceCallbackClass, txRxTimeouts);
        }
    }

    /**
     * Cordova: execute()
     */
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if (ACTION_START_SCAN.equals(action)) {
            return startScan();
        }
        else if (ACTION_STOP_SCAN.equals(action)) {
            return stopScan();
        }
        else if (ACTION_CONNECT.equals(action)) {
            return connect(args.getString(0));
        }
        else if (ACTION_READ_DATA.equals(action)) {
            return readData();
        }
        else if (ACTION_WRITE_DATA.equals(action)) {
            return writeData(args.getString(0));
        }
        else if (ACTION_DISCONNECT.equals(action)) {
            return disconnect();
        }
        else if (ACTION_IS_DEVICE_CONNECTED.equals(action)) {
            return isDeviceConnected(args.getString(0), callbackContext);
        }
        else if (ACTION_GET_TIMEOUTS.equals(action)) {
            return getTimeouts(callbackContext);
        }
        else if (ACTION_SET_TIMEOUTS.equals(action)) {
            return setTimeouts(args, callbackContext);
        }
        else if (ACTION_SET_DEFAULT_TIMEOUTS.equals(action)) {
            return setTimeouts(callbackContext);
        }

        // register callback
        else if (ACTION_REGISTER_CALLBACK.equals(action)) {
            return registerCallback(args.getString(0), callbackContext);
        }

        return false;
    }

    /**
     * Register a callback
     * @param name Callback name
     * @param callback JavaScript callback context
     */
    private boolean registerCallback(String name, CallbackContext callback) {
        jsCallbacks.put(name, callback);
        return true;
    }


    /**
     * Start scanning for devices
     */
    private boolean startScan() {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
            try {
                devices.clear(); // clear devices list
                scanner.startScan();
            }
            catch (Exception e) {
                callJsCallback("onScanError", e.getMessage());
            }
            }
        });
        return true;
    }

    /**
     * Stop scanning for devices
     */
    private boolean stopScan() {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    scanner.stopScan();
                }
                catch (Exception e) {
                    callJsCallback("onScanError", e.getMessage());
                }
            }
        });
        return true;
    }

    /**
     * Connect to a device
     * @param address Device address
     */
    private boolean connect(final String address) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
            try {
                deviceManager.connect(address, activity.getApplicationContext());
            }
            catch (Exception e) {
                callJsCallback("onConnectionError", e.getMessage());
            }
            }
        });
        return true;
    }

    /**
     * Read data
     */
    private boolean readData() {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
            try {
                deviceManager.requestReadData();
            }
            catch (Exception e) {
                callJsCallback("onReadError", e.getMessage());
            }
            }
        });
        return true;
    }

    /**
     * Write data
     * @param data Data to write
     */
    private boolean writeData(final String data) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
            try {
                deviceManager.requestWriteData(data);
            }
            catch (Exception e) {
                callJsCallback("onWriteError", e.getMessage());
            }
            }
        });
        return true;
    }

    /**
     * Disconnect from the connected device
     */
    private boolean disconnect() {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                deviceManager.disconnect();
            }
        });
        return true;
    }

    /**
     * Check if a device is connected
     * @param address Device address
     * @param callbackContext Cordova callback context
     */
    private boolean isDeviceConnected(String address, CallbackContext callbackContext) {
        try {
            boolean boolRes = deviceManager.isConnected(address, activity.getApplicationContext());
            int intRes = (boolRes) ? 1 : 0;
            callbackContext.success(intRes);
        }
        catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
        return true;
    }

    /**
     * Set the timeouts values
     * @param args Cordova args
     * @param callbackContext Cordova callback context
     */
    private boolean setTimeouts(JSONArray args, CallbackContext callbackContext) {
        try {
            TxRxTimeouts newTimeouts = new TxRxTimeouts(
                args.getLong(0),
                args.getLong(1),
                args.getLong(2),
                args.getLong(3)
            );
            TxRxPreferences.saveTimeouts(activity.getApplicationContext(), newTimeouts);
            deviceManager.setTxRxTimeouts(newTimeouts);
            callbackContext.success();
        }
        catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
        return true;
    }

    /**
     * Set timeouts back to their default values
     * @param callbackContext Cordova callback context
     */
    private boolean setTimeouts(CallbackContext callbackContext) {
        try {
            TxRxTimeouts newTimeouts = TxRxTimeouts.getDefaultTimeouts();
            TxRxPreferences.saveTimeouts(activity.getApplicationContext(), newTimeouts);
            deviceManager.setTxRxTimeouts(newTimeouts);
            callbackContext.success();
        }
        catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
        return true;
    }

    /**
     * Get timeouts values
     * @param callbackContext Cordova callback context
     */
    private boolean getTimeouts(CallbackContext callbackContext) {
        try {
            TxRxTimeouts currentTimeouts = TxRxPreferences.getTimeouts(activity.getApplicationContext());
            JSONObject response = new JSONObject();
            response.put("connectionTimeout", currentTimeouts.getConnectTimeout());
            response.put("writeTimeout", currentTimeouts.getWriteTimeout());
            response.put("firstReadTimeout", currentTimeouts.getFirstReadTimeout());
            response.put("laterReadTimeout", currentTimeouts.getLaterReadTimeout());
            callbackContext.success(response);
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
        return true;
    }

    /**
     * Invokes a registered JavaScript callback 
     * @param callbackName Name of the JavaScript callback
     * @param message Message to send
     */
    private void callJsCallback(String callbackName, String message) {
        PluginResult result = new PluginResult(PluginResult.Status.OK, message);
        result.setKeepCallback(true);
        if (jsCallbacks.get(callbackName) != null) {
            jsCallbacks.get(callbackName).sendPluginResult(result);
        }
    }

}