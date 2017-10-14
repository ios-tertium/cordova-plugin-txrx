/*
 * The MIT License
 *
 * Copyright 2017 Tertium Technology.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// Imports the list of the notification identifiers to be dispatched to the whole application by NSNotificationCenter
#import "CoreNotification.h"

#import "Core.h"
#import "TxRxManagerErrors.h"

static Core* _core = nil;

@implementation Core

/**
 getCore - Gets the core's single istance
 
 NOTE: this is CLASS method, NOT an instance method

 @return - The core class single istance
 */
+(Core *) getCore
{
    if (_core == nil)
        _core = [Core new];
    
    return _core;
}

/**
 init - initializes the single Core class instance members

 @return The core class single istance
 */
-(id)init
{
    self = [super init];
    if (self) {
        _manager = [TxRxManager getManager];
        _manager.delegate = self;
        _notificationCenter = [NSNotificationCenter defaultCenter];
        _scannedDevices = [NSMutableArray new];
    }
    
    return self;
}

/**
 IsScanning - Returns true if scanning has been started 

 @return a boolean saying if scanning of Tertium TxRxDevices has been started
 */
-(bool) isScanning
{
    return _manager.isScanning;
}

/**
 startScan - begins the scan of BLE devices. NOTE: you CANNOT connect to any device while scanning for devices. Call stopScan first.
 */
-(void)startScan
{
    [_manager startScan];
}

/**
 getScannedDevices - Returns a list of scanned devices in previous startScan phase
 
 @return - NSArray consisting of TxRxDevice instances
 */
-(NSArray *) getScannedDevices
{
    return _scannedDevices;
}

/**
 stopScan - Ends the scan of BLE devices 
 
 NOTE: After scan is ended you can connect to devices found
 */
-(void)stopScan
{
    [_manager stopScan];
}

/**
 connectDevice - Connects to a previously found (by startScan) BLE device

 NOTE: Connect is an asyncronous operation, delegate method will be called when and if connected

 @param device - the device to connect to, MUST be non null
 */
-(void) connectDevice: (TxRxDevice *_Nonnull) device
{
    [_manager connectDevice: device];
}

/**
 disconnectDevice - Disconnect a previously connected device

 @param device - the device to disconnect, MUST be non null
 */
-(void) disconnectDevice: (TxRxDevice *_Nonnull) device
{
    [_manager disconnectDevice: device];
}

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
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: error userInfo: @{@"type": TXRX_NOTIFICATION_SCAN_ERROR}];
}

/**
 deviceScanBegan -  Receives information scanning has began and dispatches the information to the whole application
                    Clears previously scanned devices, if present
 */
-(void)deviceScanBegan
{
    [_scannedDevices removeAllObjects];
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: nil userInfo: @{@"type": TXRX_NOTIFICATION_SCAN_BEGAN}];
}

/**
 deviceFound -  Receives information scanning phase has found a device and broadcasts the information to the whole application
                Mantains a reference to the instance of the device scanned
                Sets the delegate of the device to itself

 @param device - the device found. You may now connect to the device with connectDevice
 */
-(void)deviceFound: (TxRxDevice *_Nonnull) device
{
    [_scannedDevices addObject: device];
    device.delegate = self;
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: device userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_FOUND}];
}

/**
 deviceScanEnded - Receives information device scanning successfully ended and dispatches it to the whole application
 */
-(void)deviceScanEnded
{
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: nil userInfo: @{@"type": TXRX_NOTIFICATION_SCAN_ENDED}];
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
    if ([error code] == TERTIUM_ERROR_DEVICE_DISCONNECT_TIMED_OUT) {
        [self deviceDisconnected: device];
        return;
    }
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: error userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_CONNECT_ERROR, @"device": device }];
}

/**
 deviceConnected - Receives information a device has been connected by a previous call to connectDevice and dispatches it to the whole application
 
 NOTE: TxRxManager library will connect ONLY to Tertium BLE devices

 @param device - The TxRxDevice instance of the connected device
 */
-(void)deviceConnected: (TxRxDevice *_Nonnull) device
{
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: device userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_CONNECTED }];
}

/**
 deviceReady - Receives information a device has been connected by a previous call to connectDevice and dispatches it to the whole application
 
 NOTE: TxRxManager library will connect ONLY to Tertium BLE devices
 
 @param device - The TxRxDevice instance of the connected device
 */
-(void)deviceReady: (TxRxDevice *_Nonnull) device
{
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: device userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_READY }];
}

/**
 sendData - Send an NSData byte buffer to a connected device. 
 
 NOTE: you may ONLY send data to already connected devices
 NOTE: Data to device is sent in MTU fragments (refer to TxRxDeviceProfile maxSendPacketSize class attribute)
 
 @param device - the device to send the data (must be connected first!)
 @param data - NSData class with contents of data to sernd
 */
-(void) sendData: (TxRxDevice *) device withData: (NSData *_Nonnull) data
{
    [_manager sendData: device withData: data];
}

/**
 deviceWriteError - Receives information a write operation issued by previous sendData command on a device failed and dispatches it to the whole application
 
 @param device - The TxRxDevice instance of the device which generated the error
 @param error - NSError describing the error
 */
-(void)deviceWriteError: (TxRxDevice *_Nonnull) device withError: (NSError *_Nonnull) error
{
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: error userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_DATA_SEND_ERROR, @"device": device }];
}

/**
 sentData - Receives information data sent to a device in a previous sendData call has been sent correctly and dispatches it to the whole application
 
 @param device - The TxRxDevice to which data has been correctly sent
 */
-(void)sentData: (TxRxDevice *_Nonnull) device
{
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: device userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_DATA_SENT }];
}

/**
 deviceReadError - Receives information a read operation on a device failed in response to a previous sent command and dispatches it to the whole application

 @param device - The TxRxDevice instance of the device which generated the error
 @param error - NSError describing the error
 */
-(void)deviceReadError: (TxRxDevice *_Nonnull) device withError: (NSError *_Nonnull) error
{
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: error userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_DATA_RECEIVE_ERROR, @"device": device }];
}

/**
 receivedData - Receives information a device has sent databytes and dispatches it to the whole application

 @param device - The TxRxDevice instance of the device which sent the bytes
 @param data - An instance of NSData with the data received
 */
-(void)receivedData: (TxRxDevice *_Nonnull) device withData: (NSData *_Nonnull) data
{
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: data userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_DATA_RECEIVED, @"device": device }];
}

/**
 Receives information a critical error on a device occoured and dispatches it to the whole application. NOTE: ANY operation on the device MUST be ceased immediately

 @param device - The TxRxDevice instance of the device which generated the error
 @param error  - NSError describing the error
 */
-(void)deviceError: (TxRxDevice *_Nonnull) device withError: (NSError *_Nonnull) error
{
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: error userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_ERROR, @"device": device }];
}

/**
 Receives information an intenral error on a device occoured and dispatches it to the whole application
 
 @param error  - NSError describing the error
 */
- (void)deviceInternalError:(NSError * _Nonnull)error {
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: error userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_ERROR}];
}

/**
 Receives information a device has been disconnected by a previous call to disconnectDevice and dispatches it to the whole application
 
 @param device - The TxRxDevice instance of the disconnected device
 */
-(void)deviceDisconnected: (TxRxDevice *_Nonnull) device
{
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: device userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_DISCONNECTED}];
}

/**
 Receives information a critical error on a device occoured and dispatches it to the whole application
 
 @param error  - NSError describing the error
 */
- (void)deviceInternalError:(TxRxDevice * _Nonnull)device withError:(NSError * _Nonnull)error {
    [_notificationCenter postNotificationName: TXRX_NOTIFICATION_NAME object: error userInfo: @{@"type": TXRX_NOTIFICATION_DEVICE_ERROR, @"device": device }];
}


@end
