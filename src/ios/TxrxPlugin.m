/* TxrxPlugin.m */

#import "TxrxPlugin.h"
#import <Cordova/CDV.h>
#import "CoreNotification.h"
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
    _core = [Core getCore];
    _manager = [TxRxManager getManager];
    _connectedDevice = nil;
    
    // Add ourself to notification center
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTxRxNotification:)
                                                 name:TXRX_NOTIFICATION_NAME
                                               object:nil];
    
}

-(void) dealloc
{
    // Remove from notification
    [[NSNotificationCenter defaultCenter] removeObserver: self];
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
    [_core startScan];
}

/**
 stopScan - Stop scanning for devices
 @param command - Cordova command, contains arguments
 */
- (void) stopScan:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.stopScan");
    [_core stopScan];
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
            if ([_core isScanning]) {
                [_core stopScan];
            }
            [_core connectDevice: device];
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
        if ([_core isScanning]) {
            [_core stopScan];
        }
        [_core disconnectDevice:_connectedDevice];
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
        [_core sendData:_connectedDevice withData:data];
    }
}

/**
 getTimeouts - Set the timeouts values
 @param command - Cordova command, contains arguments
 */
- (void) getTimeouts:(CDVInvokedUrlCommand*) command
{
    DLog(@"TxrxPlugin.getTimeouts");
    NSNumber* connectionTimeout = [NSNumber numberWithDouble: _manager.connectTimeout];
    NSNumber* writeTimeout = [NSNumber numberWithDouble: _manager.writePacketTimeout];
    NSNumber* firstReadTimeout = [NSNumber numberWithDouble: _manager.receiveFirstPacketTimeout];
    NSNumber* laterReadTimeout = [NSNumber numberWithDouble: _manager.receivePacketsTimeout];
    
    // Convert connectionTimeot to milliseconds
    // TODO: remove when library uses milliseconds
    float temp;
    temp = [connectionTimeout floatValue];
    temp = temp * 1000;
    connectionTimeout = [NSNumber numberWithFloat:temp];
    temp = [writeTimeout floatValue];
    temp = temp * 1000;
    writeTimeout = [NSNumber numberWithFloat:temp];
    temp = [firstReadTimeout floatValue];
    temp = temp * 1000;
    firstReadTimeout = [NSNumber numberWithFloat:temp];
    temp = [laterReadTimeout floatValue];
    temp = temp * 1000;
    laterReadTimeout = [NSNumber numberWithFloat:temp];
    
    NSMutableDictionary* timeouts = [NSMutableDictionary dictionary];
    [timeouts setObject: connectionTimeout forKey: @"connectionTimeout"];
    [timeouts setObject: writeTimeout forKey: @"writeTimeout"];
    [timeouts setObject: firstReadTimeout forKey:  @"firstReadTimeout"];
    [timeouts setObject: laterReadTimeout forKey: @"laterReadTimeout"];
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
    double timeout;
    if (connectTimeout != nil) {
        timeout = [connectTimeout doubleValue];
        timeout = timeout / 1000.00; // TODO: milliseconds
        [_manager setConnectTimeout:timeout];
    }
    if (writeTimeout != nil) {
        timeout = [writeTimeout doubleValue];
        timeout = timeout / 1000.00; // TODO: milliseconds
        [_manager setWritePacketTimeout:timeout];
    }
    if (firstReadTimeout != nil) {
        timeout = [firstReadTimeout doubleValue];
        timeout = timeout / 1000.00; // TODO: milliseconds
        [_manager setReceiveFirstPacketTimeout:timeout];
    }
    if (laterReadTimeout != nil) {
        timeout = [laterReadTimeout doubleValue];
        timeout = timeout / 1000.00; // TODO: milliseconds
        [_manager setReceivePacketsTimeout:timeout];
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
    
    // TODO: get default timeouts from library's constants
    [_manager setConnectTimeout:20];
    [_manager setWritePacketTimeout:0.5];
    [_manager setReceiveFirstPacketTimeout:2];
    [_manager setReceivePacketsTimeout:0.5];
    
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
//               TXRX CALLBACKS
///////////////////////////////////////////////////

/**
 onDeviceFound - Invoked when a new device is found
 @param device - Device that has been found
 */
- (void) onDeviceFound:(TxRxDevice*) device
{
    NSString* indexedName = [_manager getDeviceIndexedName:device];
    NSDictionary * msg =@{@"name": [device Name], @"address": indexedName};
    [self callJsCallback:@"onDeviceFound" msgAsDictionary:msg];
}

/**
 onDeviceConnected - Invoked when a device is connected
 @param device - Device that has been connected
 */
- (void) onDeviceConnected:(TxRxDevice*) device
{
    NSString* indexedName = [_manager getDeviceIndexedName:device];
    NSDictionary * msg =@{@"name": [device Name], @"address": indexedName};
    [self callJsCallback:@"onDeviceConnected" msgAsDictionary:msg];
}

/**
 onDeviceDisconnected - Invoked when a device is disconnected
 @param device - Device that has been disconnected
 */
- (void) onDeviceDisconnected:(TxRxDevice*) device
{
    _connectedDevice = nil;
    NSString* indexedName = [_manager getDeviceIndexedName:device];
    NSDictionary * msg =@{@"name": [device Name], @"address": indexedName};
    [self callJsCallback:@"onDeviceDisconnected" msgAsDictionary:msg];
}

/**
 onNotifyData - Invoked when there is new data to read
 @param device - Device that has sent the data
 @param data - New data to read
 */
- (void) onNotifyData:(TxRxDevice*) device withData:(NSData*) data
{
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self callJsCallback:@"onNotifyData" msgAsString:dataStr];
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
//            NOTIFICATIONS RECEIVER
///////////////////////////////////////////////////

/**
 receiveTxRxNotification - Receives notifications from the TxRx library
 @param notification - Received notification object
 */
- (void) receiveTxRxNotification:(NSNotification*) notification
{
    // Handles Core class reflected notifications.
    // The notifications are reflections of TxRxDeviceScanProtocol delegate callbacks
    
    if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_SCAN_BEGAN]) {
        DLog(@"TxrxPlugin.scanBegan");
    }
    
    else if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_SCAN_ERROR]) {
        NSError* error = (NSError*) notification.object;
        DLog(@"TxrxPlugin.scanError: %@", error.localizedDescription);
    }
    
    else if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_SCAN_ENDED]) {
        DLog(@"TxrxPlugin.scanEnded");
        [self callJsCallback:@"afterStopScan"];
    }
    
    else if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_DEVICE_FOUND]) {
        DLog(@"TxrxPlugin.deviceFound");
        TxRxDevice* device = (TxRxDevice*) notification.object;
        [self onDeviceFound:device];
    }
    
    else if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_DEVICE_CONNECTED]) {
        DLog(@"TxrxPlugin.deviceConnected");
        TxRxDevice* device = (TxRxDevice*) notification.object;
        [self onDeviceConnected:device];
    }
    
    else if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_DEVICE_DISCONNECTED]) {
        DLog(@"TxrxPlugin.deviceDisconnected");
        TxRxDevice* device = (TxRxDevice*) notification.object;
        [self onDeviceDisconnected:device];
    }
    
    else if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_DEVICE_READY]) {
        DLog(@"TxrxPlugin.deviceReady");
    }
    
    else if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_DEVICE_DATA_RECEIVED]) {
        DLog(@"TxrxPlugin.deviceDataReceived");
        NSData* data = (NSData *) notification.object;
        TxRxDevice* device = (TxRxDevice*) [notification userInfo][@"device"];
        [self onNotifyData:device withData:data];
    }
    
    else if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_DEVICE_DATA_RECEIVE_ERROR]) {
        NSError* error = (NSError*) notification.object;
        DLog(@"TxrxPlugin.deviceDataReceivedError: %@", error.localizedDescription);
        if (error.code == TERTIUM_ERROR_DEVICE_RECEIVING_DATA_TIMEOUT) {
            [self callJsCallback:@"onReadNotifyTimeout" msgAsString:error.localizedDescription];
        }
        else {
            [self callJsCallback:@"onReadError" msgAsString:error.localizedDescription];
        }
    }
    
    else if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_DEVICE_CONNECT_ERROR]) {
        NSError* error = (NSError*) notification.object;
        DLog(@"TxrxPlugin.deviceConnectError: %@", error.localizedDescription);
        if (error.code == TERTIUM_ERROR_DEVICE_CONNECT_TIMED_OUT) {
            [self callJsCallback:@"onConnectionTimeout" msgAsString:error.localizedDescription];
        }
        else {
            [self callJsCallback:@"onConnectionError" msgAsString:error.localizedDescription];
        }
    }
    
    else if ([[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_DEVICE_DATA_SEND_ERROR]) {
        NSError* error = (NSError*) notification.object;
        DLog(@"TxrxPlugin.deviceDataSendError: %@", error.localizedDescription);
        if (error.code == TERTIUM_ERROR_DEVICE_SENDING_DATA_TIMEOUT) {
            [self callJsCallback:@"onWriteTimeout" msgAsString:error.localizedDescription];
        }
        else {
            [self callJsCallback:@"onWriteError" msgAsString:error.localizedDescription];
        }
    }
    
    else if (
               [[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_INTERNAL_ERROR] ||
               [[notification userInfo][@"type"] isEqualToString:TXRX_NOTIFICATION_DEVICE_ERROR]) {
        NSError* error = (NSError*) notification.object;
        DLog(@"TxrxPlugin.deviceError: %@", error.localizedDescription);

    }
}



@end
