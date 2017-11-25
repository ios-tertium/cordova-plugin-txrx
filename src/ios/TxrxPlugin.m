/* TxrxPlugin.m */

#import "TxrxPlugin.h"
#import <Cordova/CDV.h>
#import "TxRxManagerErrors.h"

// Defines Macro to only log lines when in DEBUG mode
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

@implementation TxrxPlugin

/**
 pluginInitialize - Cordova plugin init method
 */
- (void) pluginInitialize
{
    DLog(@"Initializing TxrxPlugin");
    
    // Setup instance variables
    _jsCallbacks = [NSMutableDictionary dictionary];
    _manager = [TxRxManager getManager];
    _manager.delegate = self;
    _connectedDevice = nil;
}

-(void) dealloc
{
    //
}




///////////////////////////////////////////////////
//                 COMMANDS
///////////////////////////////////////////////////

/**
 startScan - Start scanning for devices
 @param command - Cordova command, contains arguments
 */
- (void) startScan:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.startScan");
    [_manager startScan];
}

/**
 stopScan - Stop scanning for devices
 @param command - Cordova command, contains arguments
 */
- (void) stopScan:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.stopScan");
    [_manager stopScan];
}

/**
 connect - Connect to a device
 @param command - Cordova command, contains arguments
 */
- (void) connect:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.connect");
    NSString* address = [command.arguments objectAtIndex:0];
    if (address != nil && [address length] != 0) {
        TxRxDevice* device = [_manager deviceWithIndexedName:address];
        if (device && device.isConnected == false) {
            if ([_manager isScanning]) {
                [_manager stopScan];
            }
            [_manager connectDevice: device];
            _connectedDevice = device;
            
        }
    }
}

/**
 disconnect - Disconnect from the connected device
 @param command - Cordova command, contains arguments
 */
- (void) disconnect:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.disconnect");
    if (_connectedDevice != nil) {
        if ([_manager isScanning]) {
            [_manager stopScan];
        }
        [_manager disconnectDevice:_connectedDevice];
    }
}

/**
 writeData - Write data
 @param command - Cordova command, contains arguments
 */
- (void) writeData:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.writeData");
    NSString* input = [command.arguments objectAtIndex:0];
    NSData* data = [input dataUsingEncoding:NSUTF8StringEncoding];
    if (_connectedDevice != nil) {
        [self callJsCallback:@"onWriteData" msgAsString:input];
        [_manager sendData:_connectedDevice withData:data];
    }
}

/**
 getTimeouts - Set the timeouts values
 @param command - Cordova command, contains arguments
 */
- (void) getTimeouts:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.getTimeouts");
    uint32_t connectionTimeout = [_manager getTimeOutValue: S_TERTIUM_TIMEOUT_CONNECT];
    uint32_t writeTimeout = [_manager getTimeOutValue: S_TERTIUM_TIMEOUT_SEND_PACKET];
    uint32_t firstReadTimeout = [_manager getTimeOutValue: S_TERITUM_TIMEOUT_RECEIVE_FIRST_PACKET];
    uint32_t laterReadTimeout = [_manager getTimeOutValue: S_TERTIUM_TIMEOUT_RECEIVE_PACKETS];
    
    NSMutableDictionary* timeouts = [NSMutableDictionary dictionary];
    [timeouts setObject: [NSNumber numberWithInt:connectionTimeout] forKey: @"connectionTimeout"];
    [timeouts setObject: [NSNumber numberWithInt:writeTimeout] forKey: @"writeTimeout"];
    [timeouts setObject: [NSNumber numberWithInt:firstReadTimeout] forKey:  @"firstReadTimeout"];
    [timeouts setObject: [NSNumber numberWithInt:laterReadTimeout] forKey: @"laterReadTimeout"];
    
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: timeouts];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    // TODO: invoke error callback in case of errors
}

/**
 setTimeouts - Get the timeouts values
 @param command - Cordova command, contains arguments
 */
- (void) setTimeouts:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.setTimeouts");
    CDVPluginResult* pluginResult = nil;
    NSNumber* connectTimeout = [command.arguments objectAtIndex:0];
    NSNumber* writeTimeout = [command.arguments objectAtIndex:1];
    NSNumber* firstReadTimeout = [command.arguments objectAtIndex:2];
    NSNumber* laterReadTimeout = [command.arguments objectAtIndex:3];

    if (connectTimeout != nil) {
        [_manager setTimeOutValue: [connectTimeout intValue] forTimeOutType: S_TERTIUM_TIMEOUT_CONNECT];
    }
    if (writeTimeout != nil) {
        [_manager setTimeOutValue: [writeTimeout intValue] forTimeOutType: S_TERTIUM_TIMEOUT_SEND_PACKET];
    }
    if (firstReadTimeout != nil) {
        [_manager setTimeOutValue: [firstReadTimeout intValue] forTimeOutType: S_TERITUM_TIMEOUT_RECEIVE_FIRST_PACKET];
    }
    if (laterReadTimeout != nil) {
        [_manager setTimeOutValue: [laterReadTimeout intValue] forTimeOutType: S_TERTIUM_TIMEOUT_RECEIVE_PACKETS];
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    // TODO: invoke error callback in case of errors
}

/**
 setDefaultTimeouts - Set the timeouts back to their default value
 @param command - Cordova command, contains arguments
 */
- (void) setDefaultTimeouts:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.setDefaultTimeouts");
    CDVPluginResult* pluginResult = nil;
    
    [_manager setTimeOutDefaults];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    // TODO: invoke error callback in case of errors
}

/**
 isDeviceConnected - Check if a deobjvice is connected
 @param command - Cordova command, contains arguments
 */
- (void) isDeviceConnected:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.isDeviceConnected");
    CDVPluginResult* pluginResult = nil;
    NSString* address = [command.arguments objectAtIndex:0];
    if (address != nil && [address length] != 0) {
        TxRxDevice* device = [_manager deviceWithIndexedName:address];
        if (device) {
            BOOL isConnected = device.isConnected;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isConnected];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"device does not exist"];
        }
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"device address empty"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 registerCallback - Register a JavaScript callback
 @param command - Cordova command, contains arguments
 */
- (void) registerCallback:(CDVInvokedUrlCommand*) command
{
    NSString* callbackName = [command.arguments objectAtIndex:0];
    [_jsCallbacks setObject: command.callbackId forKey: callbackName];
}




///////////////////////////////////////////////////
//                  UTILITIES
///////////////////////////////////////////////////

/**
 callJsCallback - Invokes a registered JavaScript callback
 @param callbackName - Name of the js callback to call
 */
- (void) callJsCallback:(NSString*) callbackName
{
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:[_jsCallbacks objectForKey: callbackName]];
}

/**
 callJsCallback - Invokes a registered JavaScript callback
 @param callbackName - Name of the js callback to call
 @param msg - Message to pass to the callback
 */
- (void) callJsCallback:(NSString*) callbackName msgAsString:(NSString *) msg
{
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:[_jsCallbacks objectForKey: callbackName]];
}

/**
 callJsCallback - Invokes a registered JavaScript callback
 @param callbackName - Name of the js callback to call
 @param dic - Dictionary object to pass to the callback
 */
- (void) callJsCallback:(NSString*) callbackName msgAsDictionary:(NSDictionary *) dic
{
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:[_jsCallbacks objectForKey: callbackName]];
}




///////////////////////////////////////////////////
//            DEVICE MANAGER AND DEVICE
//            CALLBACKS IMPLEMENTATION
///////////////////////////////////////////////////


/**
 TxRxDeviceScanProtocol implementation.
 
 Implements the TxRxManager callbacks for the SCANNING devices phase
 */
#pragma mark TxRxDeviceScanProtocol

/**
 deviceScanError - Receives information an error occoured while scanning devices and dispatches it to the whole application
 
 Errors may be: bluetooth is disabled, the application doesn't have bluetooth permissions, bluetooth is resetting or shutting down, or any other error CoreBluetooth reports
 
 @param error - NSError describing the error
 */
-(void)deviceScanError: (NSError *_Nonnull) error
{
    DLog(@"TxrxPlugin.scanError: %@", error.localizedDescription);
}

/**
 deviceScanBegan -  Receives information scanning has began and dispatches the information to the whole application
 Clears previously scanned devices, if present
 */
-(void)deviceScanBegan
{
    DLog(@"TxrxPlugin.scanBegan");
}

/**
 deviceFound -  Receives information scanning phase has found a device and broadcasts the information to the whole application
 Mantains a reference to the instance of the device scanned
 Sets the delegate of the device to itself
 
 @param device - the device found. You may now connect to the device with connectDevice
 */
-(void)deviceFound: (TxRxDevice *_Nonnull) device
{
    DLog(@"TxrxPlugin.deviceFound");
    device.delegate = self;
    NSString* indexedName = [_manager getDeviceIndexedName:device];
    NSDictionary * msg =@{@"name": [device Name], @"address": indexedName};
    [self callJsCallback:@"onDeviceFound" msgAsDictionary:msg];
}

/**
 deviceScanEnded - Receives information device scanning successfully ended and dispatches it to the whole application
 */
-(void)deviceScanEnded
{
    DLog(@"TxrxPlugin.scanEnded");
    [self callJsCallback:@"afterStopScan"];
}

/**
 TxRxDeviceScanProtocol implementation.
 
 Implements the TxRxManager callbacks for operation on devices phase
 
 */
#pragma mark TxRxDeviceDataProtocol

/**
 deviceConnectError - Receives error information connecting to a device requested by a previous call to connectDevice and dispatches it to the whole application
 
 @param device - The TxRxDevice instance of the device unable to be connected
 @param error - NSError describing the error
 */
-(void)deviceConnectError: (TxRxDevice *_Nonnull) device withError: (NSError *_Nonnull) error
{
    DLog(@"TxrxPlugin.deviceConnectError: %@", error.localizedDescription);
    if ([error code] == TERTIUM_ERROR_DEVICE_DISCONNECT_TIMED_OUT) {
        [self callJsCallback:@"onConnectionTimeout" msgAsString:error.localizedDescription];
    }
    else {
        [self callJsCallback:@"onConnectionError" msgAsString:error.localizedDescription];
    }
}

/**
 deviceConnected - Receives information a device has been connected by a previous call to connectDevice and dispatches it to the whole application
 
 NOTE: TxRxManager library will connect ONLY to Tertium BLE devices
 
 @param device - The TxRxDevice instance of the connected device
 */
-(void)deviceConnected: (TxRxDevice *_Nonnull) device
{
    DLog(@"TxrxPlugin.deviceConnected");
    NSString* indexedName = [_manager getDeviceIndexedName:device];
    NSDictionary * msg =@{@"name": [device Name], @"address": indexedName};
    [self callJsCallback:@"onDeviceConnected" msgAsDictionary:msg];
}

/**
 deviceReady - Receives information a device has been connected by a previous call to connectDevice and dispatches it to the whole application
 
 NOTE: TxRxManager library will connect ONLY to Tertium BLE devices
 
 @param device - The TxRxDevice instance of the connected device
 */
-(void)deviceReady: (TxRxDevice *_Nonnull) device
{
    DLog(@"TxrxPlugin.deviceReady");
}

/**
 deviceWriteError - Receives information a write operation issued by previous sendData command on a device failed and dispatches it to the whole application
 
 @param device - The TxRxDevice instance of the device which generated the error
 @param error - NSError describing the error
 */
-(void)deviceWriteError: (TxRxDevice *_Nonnull) device withError: (NSError *_Nonnull) error
{
    if ([error code] == TERTIUM_ERROR_DEVICE_SENDING_DATA_TIMEOUT) {
        [self callJsCallback:@"onWriteTimeout" msgAsString:error.localizedDescription];
    }
    else {
        [self callJsCallback:@"onWriteError" msgAsString:error.localizedDescription];
    }
}

/**
 sentData - Receives information data sent to a device in a previous sendData call has been sent correctly and dispatches it to the whole application
 
 @param device - The TxRxDevice to which data has been correctly sent
 */
-(void)sentData: (TxRxDevice *_Nonnull) device
{
    DLog(@"TxrxPlugin.sentData: ");
}

/**
 deviceReadError - Receives information a read operation on a device failed in response to a previous sent command and dispatches it to the whole application
 
 @param device - The TxRxDevice instance of the device which generated the error
 @param error - NSError describing the error
 */
-(void)deviceReadError: (TxRxDevice *_Nonnull) device withError: (NSError *_Nonnull) error
{
    DLog(@"TxrxPlugin.deviceDataReceivedError: %@", error.localizedDescription);
    if ([error code] == TERTIUM_ERROR_DEVICE_RECEIVING_DATA_TIMEOUT) {
        [self callJsCallback:@"onReadNotifyTimeout" msgAsString:error.localizedDescription];
    }
    else {
        [self callJsCallback:@"onReadError" msgAsString:error.localizedDescription];
    }
}

/**
 receivedData - Receives information a device has sent databytes and dispatches it to the whole application
 
 @param device - The TxRxDevice instance of the device which sent the bytes
 @param data - An instance of NSData with the data received
 */
-(void)receivedData: (TxRxDevice *_Nonnull) device withData: (NSData *_Nonnull) data
{
    DLog(@"TxrxPlugin.deviceDataReceived");
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self callJsCallback:@"onNotifyData" msgAsString:dataStr];
}

/**
 Receives information a critical error on a device occoured and dispatches it to the whole application. NOTE: ANY operation on the device MUST be ceased immediately
 
 @param device - The TxRxDevice instance of the device which generated the error
 @param error  - NSError describing the error
 */
-(void)deviceError: (TxRxDevice *_Nonnull) device withError: (NSError *_Nonnull) error
{
    DLog(@"TxrxPlugin.deviceError: %@", error.localizedDescription);
}

/**
 Receives information an intenral error on a device occoured and dispatches it to the whole application
 
 @param error  - NSError describing the error
 */
- (void)deviceInternalError:(NSError * _Nonnull)error {
    DLog(@"TxrxPlugin.deviceInternalError: %@", error.localizedDescription);
}

/**
 Receives information a device has been disconnected by a previous call to disconnectDevice and dispatches it to the whole application
 
 @param device - The TxRxDevice instance of the disconnected device
 */
-(void)deviceDisconnected: (TxRxDevice *_Nonnull) device
{
    DLog(@"TxrxPlugin.deviceDisconnected");
    _connectedDevice = nil;
    NSString* indexedName = [_manager getDeviceIndexedName:device];
    NSDictionary * msg =@{@"name": [device Name], @"address": indexedName};
    [self callJsCallback:@"onDeviceDisconnected" msgAsDictionary:msg];
}

/**
 Receives information a critical error on a device occoured and dispatches it to the whole application
 
 @param error  - NSError describing the error
 */
- (void)deviceInternalError:(TxRxDevice * _Nonnull)device withError:(NSError * _Nonnull)error {
    DLog(@"TxrxPlugin.deviceInternalError: %@", error.localizedDescription);
}



@end
