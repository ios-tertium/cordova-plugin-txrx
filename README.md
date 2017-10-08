# Cordova TxRx plugin
Cordova plugin wrapping the native Android and iOS TxRx libraries.

## License
The plugin is released under the MIT license. Please see the `LICENSE.txt` file.

## Requirements
This plugin requires Android SDK 18 or newer, you are then required to specify the minimum Android SDK version in your `config.xml` file. Do __not__ place place the following code inside the `<platform name="android">` tag.

```xml
<preference name="android-minSdkVersion" value="18" />
```

## Installation
To install the plugin run the following command inside your cordova project's folder:

```sh
cordova plugin add https://github.com/tertiumtechnology/cordova-plugin-txrx.git
```

## Demo app
We have the developed a demo cordova app to showcase the plugin, you can find it [here](https://github.com/tertiumtechnology/txrx-demo-cordova.git).

## Usage
The first thing you need to do is register the callback functions that the plugin is going to call whenever a certain event occurs (eg. a message has been received, a device just disconnected and so on...). You will then implement your own login inside your callbacks functions.

You can register the following callbacks, most of them should hopefully be self-explanatory:
- `onDeviceFound`: Called every time the scan function finds a new device.
- `afterStopScan`: Called when the scanning process is stopped or halted after timeout.
- `onConnectionError`
- `onConnectionTimeout`
- `onDeviceConnected`: Called after a succesful connection to a device.
- `onDeviceDisconnected`
- `onNotifyData`
- `onReadData`: Called when there is new data to read.
- `onReadError`
- `onReadNotifyTimeout`
- `onWriteData`
- `onWriteError`
- `onWriteTimeout`

*All the error callbacks are invoked passing a single string argument containing the error message.*

### Register the callback functions
To register more than one callback at the same time you can use the `registerCallbacks` method of the plugin assing an object containing the callbacks:

```Javascript
// register many txrx callbacks
var callbacks = {
    "onDeviceFound": app.onDeviceFound,
    "afterStopScan": app.afterStopScan,
    "onConnectionError": app.onConnectionError,
    "onConnectionTimeout": app.onConnectionTimeout,
    "onDeviceConnected": app.onDeviceConnected,
    "onDeviceDisconnected": app.onDeviceDisconnected,
    "onNotifyData": app.onNotifyData,
    "onReadData": app.onReadData,
    "onReadError": app.onReadError,
    "onReadNotifyTimeout": app.onReadNotifyTimeout,
    "onWriteData": app.onWriteData,
    "onWriteError": app.onWriteError,
    "onWriteTimeout": app.onWriteTimeout
};
cordova.plugins.txrx.registerCallbacks(callbacks);
```

### Register a single callback
To register (or overwrite) a single callback you can use the `registerCallback` method and pass the callback's name and reference:

```Javascript
// register a single txrx callback
cordova.plugins.txrx.registerCallbacks("callBackName", callbackFunction);
```

### Scan for devices
To scan for devices you can use the `startScan` method:

```Javascript
// scan for devices
cordova.plugins.txrx.startScan();
```

When a new device is found, your `onDeviceFound` callback will be called together with an object containing the device's label and address:

```Javascript
// your registered callback
onDeviceFoundCallback(device) {
    console.log("New device found: " + device.name + " @ " + device.address); 
}
```

### Stop scanning
You can stop the scanning by calling the `stopScan plugin method`. Otherwise the scan will just stop after the timeout.

```Javascript
// stop scanning
cordova.plugins.txrx.stopScan();
```

### Connect to a device
To connect to a device you need to call the `connect` plugin's method and pass the device's address:

```Javascript
// connect to a device
cordova.plugins.txrx.connect(deviceAddress);
```

If the connection is succesful, your `onDeviceConnected` will be called:

```Javascript
// your registered callback
onDeviceConnectedCallback() {
    console.log("Succesfully ocnnected to desidered device"); 
}
```

### Write data
To write data use the `writeData` method of the plugin:

```Javascript
// write data
cordova.plugins.txrx.writeData(message);
```

### Read data
To get notified when there is new data to read you have to register yur implementation of the `onNotifyData` callback:

```Javascript
// your registered callback
onNotifyDataCallback(data) {
    console.log("Received data: " + data); 
}
```

### Disconnect from device
To disconnect from the connected device you can usue the `disconnect` plugin method:

```Javascript
// disconnect from device
cordova.plugins.txrx.disconnect();
```

When the device has been succesfully disconnected, your `onDeviceDisconnected` callback will be called.

### Check is a device is connected
If you need to check wether a certain device is currrently connected or not, use the `isDeviceConnected` method, passing the device's address as a parameter:

```Javascript
// check if device is connected
cordova.plugins.txrx.isDeviceConnected(
    deviceAddress, 
    function(isConnected) {
        console.log("Is the device connected? " + isConnected);
    },
    function(error) { console.log(error); }
);
```


## API documentation
Please check the function comments in the `txrx.js` file for API level detailed documentation.


