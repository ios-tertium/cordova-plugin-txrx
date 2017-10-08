/**
 * TxRx Cordova plugin
 */

var exec = require('cordova/exec');

var txrx = {

    /**
     * Start scanning for devices
     */
    startScan: function () {
        exec(null, null, "TxrxPlugin", "startScan", []);
    },

    /**
     * Stop scanning for devices
     */
    stopScan: function () {
        exec(null, null, "TxrxPlugin", "stopScan", []);
    },

    /**
     * Connect to a device
     * @param {string} address Address of the device
     */
    connect: function (address) {
        exec(null, null, "TxrxPlugin", "connect", [address]);
    },

    /**
     * Disconnect from the connected device
     */
    disconnect: function () {
        exec(null, null, "TxrxPlugin", "disconnect", []);
    },

    /**
     * Read data
     */
    readData: function () {
        exec(null, null, "TxrxPlugin", "readData", []);
    },

    /**
     * Write data
     * @param {string} data Data to write
     */
    writeData: function (data) {
        exec(null, null, "TxrxPlugin", "writeData", [data]);
    },

    /**
     * Check if a device is connected
     * @param {string} address Address of the device
     * @param {function} successCallback Success callback
     * @param {function} errorCallback Error callback
     */
    isDeviceConnected: function (address, successCallback, errorCallback) {
        var callback = successCallback;
        exec(
            function (intRes) {
                var boolRes = (intRes == 1) ? true : false;
                callback(boolRes);
            }, 
            errorCallback, "TxrxPlugin", "isDeviceConnected", [address]);
    },

    /**
     * Get timeouts values
     * @param {function} successCallback Success callback
     * @param {function} errorCallback Error callback
     */
    getTimeouts: function (successCallback, errorCallback) {
        exec(successCallback, errorCallback, "TxrxPlugin", "getTimeouts", []);
    },

    /**
     * Set timeouts values
     * @param {number} connectionTimeout Connection timeout new value
     * @param {number} writeTimeout Write timeout new value
     * @param {number} firstReadTimeout First read timeout new value
     * @param {number} laterReadTimeout Later read timeout new value
     * @param {function} successCallback Success callback
     * @param {function} errorCallback Error callback
     */
    setTimeouts: function (connectionTimeout, writeTimeout, firstReadTimeout, laterReadTimeout, successCallback, errorCallback) {
        exec(successCallback, errorCallback, "TxrxPlugin", "setTimeouts", [connectionTimeout, writeTimeout, firstReadTimeout, laterReadTimeout]);
    },

    /**
     * Set timeouts back to default values
     * @param {function} successCallback Success callback
     * @param {function} errorCallback Error callback
     */
    setDefaultTimeouts: function (successCallback, errorCallback) {
        exec(successCallback, errorCallback, "TxrxPlugin", "setDefaultTimeouts", []);
    },


    /**
     * Register a callback
     * @param {string} name Name of the callback
     * @param {function} callback Callback function
     */
    registerCallback: function(name, callback) {
        exec(callback, null, "TxrxPlugin", "registerCallback", [name]);
    },

    /**
     * Register callbacks
     * @param {Object} callbacks Callbacks object
     */
    registerCallbacks: function(callbacks) {
        for (var name in callbacks) {
            txrx.registerCallback(name, callbacks[name]);
        }
    }

};

module.exports = txrx;