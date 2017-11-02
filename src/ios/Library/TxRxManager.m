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

#import "TxRxManagerPhases.h"
#import "TxRxManagerErrors.h"
#import "TxRxWatchDogTimer.h"
#import "TxRxManager.h"
#import "TxRxDeviceManagerExchangeProtocol.h"

#define TERTIUM_COMMAND_END_CRLF @"\r\n"
#define TERTIUM_COMMAND_END_CR @"\r"
#define TERTIUM_COMMAND_END_LF @"\n"

/**
 TxRxManager is a singleton proxy class responsible for communicating with TxRxDevices thru CoreBluetooth. This is TxRxLibrary main class
 Handles multiple Tertium BLE Devices
 Calls TxRxManager and TxRxDeviceManager delegates
 
 Methods are ordered chronologically
 */
#pragma mark TxRxManager implementation

@implementation TxRxManager

// Private class attributes

/**
 Tells if CoreBluetooth is ready to operate
 */
bool _blueToothPoweredOn;

/**
 CoreBluetooth manager class reference
 */
CBCentralManager *_centralManager;

/**
 Array of supported Tertium BLE Devices (please refer to init method for details)
 */
NSArray *_txRxSupportedDevices;

/**
 connectTimeout - The MAXIMUM time the class and BLE hardware have to connect to a BLE device
 */
double _connectTimeout;

/**
 receiveFirstPacketTimeout - The MAXIMUM time a Tertium BLE device has to send the first response packet to an issued command
 */
double _receiveFirstPacketTimeout;

/**
 receivePacketsTimeout - The MAXIMUM time a Tertium BLE device has to send the after having sent the first response packet to an issued command (commands and data are sent in FRAGMENTS)
 */
double _receivePacketsTimeout;

/**
 writePacketTimeout - The MAXIMUM time a Tertium BLE device has to notify when a write operation on a device is issued by sendData method
 */
double _writePacketTimeout;

/**
 Mutable array of scannned devices found by startScan. Used for input parameter validation and internal cleanup
 */
NSMutableArray *_scannedDevices;

/**
 Mutable array of connecting devices. Used for input parameter validation
 */
NSMutableArray *_connectingDevices;

/**
 Mutable array of disconnecting devices. Used for input parameter validation
 */
NSMutableArray *_disconnectingDevices;

/**
 Mutable array of connected devices. Used for input parameter validation
 */
NSMutableArray *_connectedDevices;

/**
 Gets the single instance of the class
 
 NOTE: CLASS Method

 @return - The single instance of TxRxManager class
 */
+(instancetype) getManager
{
    static TxRxManager *_manager;
    
    if (!_manager)
        _manager = [TxRxManager new];
    
    return _manager;
}

/**
 Initializes the instance of TxRxManager class

 @return - The instance of TxRxManager class with default parameters
 */
-(id)init
{
    self = [super init];
    if (self){
        // Public properties default value. You may change if needed. Refer for TxRxMananger.h for details
        _callbackQueue = dispatch_get_main_queue();
        _dispatchQueue = _callbackQueue;
        
        // Set timeout defaults
        [self setTimeOutDefaults];
        
        // Array of supported devices. Add new devices here !
        _txRxSupportedDevices = @[
                                // TERTIUM RFID READER
                                [
                                    TxRxDeviceProfile newProfileWithParameters: @"175f8f23-a570-49bd-9627-815a6a27de2a"
                                    withRxUUID: @"1cce1ea8-bd34-4813-a00a-c76e028fadcb"
                                    withTxUUID: @"cacc07ff-ffff-4c48-8fae-a9ef71b75e26"
                                    withCommandEnd: TERTIUM_COMMAND_END_CRLF
                                    withMaxPacketSize: 20
                                ]
                                // TERTIUM SENSOR READER
                                ,[
                                    TxRxDeviceProfile newProfileWithParameters: @"3CC33CDC-CB91-4947-BD12-80D2F0535A30"
                                    withRxUUID: @"3664D14A-08CB-4465-A98A-EBF84F29E943"
                                    withTxUUID: @"F3774638-1164-49BC-8F22-0AC34292C217"
                                    withCommandEnd: TERTIUM_COMMAND_END_CRLF
                                    withMaxPacketSize: 20
                                ]
                            ];
        
        // Initialize validation arrays
        _scannedDevices = [NSMutableArray new];
        _connectingDevices = [NSMutableArray new];
        _connectedDevices = [NSMutableArray new];
        _disconnectingDevices = [NSMutableArray new];
        
        // Initialize Ble APIs
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_dispatchQueue];
    }
    
    return self;
}

#pragma mark CBCentralManagerDelegate implementation

/**
 Processes CoreBlueTooth manager state updates. Will set _poweredOn flag when CoreBluetooth and bluetooth hardware is ready to operate
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (@available(iOS 10.0, *)) {
        switch (central.state) {
            case CBManagerStateUnknown:
            case CBManagerStateResetting:
            case CBManagerStateUnsupported:
            case CBManagerStateUnauthorized:
            case CBManagerStatePoweredOff:
                [self masterCleanUp];
                _blueToothPoweredOn = false;
                break;
                
            case CBManagerStatePoweredOn:
                _blueToothPoweredOn = true;
                break;
        }
    } else {
        _blueToothPoweredOn = true;
    }
}

#pragma mark CBCentralManagerDelegate implementation

/**
 Begins the scan of BLE devices. NOTE: you CANNOT connect to any device while scanning for devices. Call stopScan first.
 */
-(void)startScan
{
    if (_isScanning) {
        [self sendScanError: TERTIUM_ERROR_DEVICE_SCAN_ALREADY_STARTED withText: S_TERTIUM_ERROR_DEVICE_SCAN_ALREADY_STARTED];
        return;
    }
    
    // Verify BlueTooth is powered on
    if (!_blueToothPoweredOn) {
        [self sendBlueToothNotReadyOrLost];
        return;
    }
    
    [_scannedDevices removeAllObjects];
    _isScanning = true;
    [_centralManager scanForPeripheralsWithServices: nil options:nil];
    
    if (_delegate)
        dispatch_async(_callbackQueue, ^{
            [_delegate deviceScanBegan];
        });
}

#pragma mark CBCentralManagerDelegate implementation

/**
 Implements CBCentralManagerDelegate callback. Creates instances of TxRxDevice and informs delegate of the discovering of peripherals
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    TxRxDevice* newDevice;
    
    // Instances a new TxRxDevice class keeping CoreBluetooth CBPeripheral class instance reference
    newDevice = [TxRxDevice new];
    newDevice.cbPeripheral = peripheral;
    
    // If peripheral name is not supplied set it to Unnamed Device
    if (peripheral.name == nil || [peripheral.name length] == 0)
        newDevice.Name = @"Unnamed device";
    else
        newDevice.Name = peripheral.name;
    
    newDevice.IndexedName = [NSString stringWithFormat: @"%@_%lu", newDevice.Name, (unsigned long)_scannedDevices.count];
    
    // Add the device to the array of scanned devices
    [_scannedDevices addObject: newDevice];
    
    // Dispatch call to delegate, we have found a BLE device
    if (_delegate)
        dispatch_async(_callbackQueue, ^{
            [_delegate deviceFound: newDevice];
        });
}

#pragma mark TxRxManager implementation

/**
 Ends the scan of BLE devices
 
 NOTE: After scan ends you can connect to devices found
 */
-(void)stopScan
{
    // If we aren't scanning, report an error to the delegate
    if (!_isScanning) {
        [self sendScanError: TERTIUM_ERROR_DEVICE_SCAN_NOT_STARTED withText: S_TERTIUM_ERROR_DEVICE_SCAN_NOT_STARTED];
        return;
    }
    
    // Verify BlueTooth is powered on
    if (!_blueToothPoweredOn) {
        [self sendBlueToothNotReadyOrLost];
        return;
    }
    
    // Stop bluetooth hardware from scanning devices
    [_centralManager stopScan];
    _isScanning = false;

    // Inform delegate device scan ended. Its NOW possible to connect to devices
    if (_delegate)
        dispatch_async(_callbackQueue, ^{
            [_delegate deviceScanEnded];
        });
}


/**
 Tries to connect to a previously found (by startScan) BLE device
 
 NOTE: Connect is an asyncronous operation, delegate will be informed when and if connected
 
 NOTE: TxRxManager library will connect ONLY to Tertium BLE devices (service UUID and characteristic UUID will be matched)
 
 @param device - the device to connect to, MUST be non null
 */
-(void)connectDevice: (TxRxDevice *) device
{
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice;
    
    // Verify BlueTooth is powered on
    if (!_blueToothPoweredOn) {
        [self sendBlueToothNotReadyOrLost];
        return;
    }
    
    // Verify we aren't scanning. Connect IS NOT supported while scanning for devices
    if (_isScanning) {
        [self sendUnableToPerformDuringScan: device];
        return;
    }
    
    // Verify we aren't ALREADY connecting to specified device
    if ([_connectingDevices containsObject: device]) {
        [self sendDeviceConnectError: device withErrorCode: TERTIUM_ERROR_DEVICE_ALREADY_CONNECTING withText: S_TERTIUM_ERROR_DEVICE_ALREADY_CONNECTING];
        return;
    }
    
    // Verify we aren't ALREADY already connected to specified device
    if ([_connectedDevices containsObject: device]) {
        [self sendDeviceConnectError: device withErrorCode: TERTIUM_ERROR_DEVICE_ALREADY_CONNECTED withText: S_TERTIUM_ERROR_DEVICE_ALREADY_CONNECTED];
        return;
    }
    
    // Cast the device pointer to the internal exchange protocol for PROTECTED device methods and fields
    hiddenDevice = (NSObject<TxRxDeviceManagerExchangeProtocol> *) device;
    
    // Create connect watchdog timer
    [hiddenDevice scheduleWatchdogWithParameters: TERTIUM_PHASE_CONNECTING withInterval: _connectTimeout target: self selector: @selector(watchDogTimerForConnectTick:ManagesDevice:inPhase:)];
    
    // Device is added to the list of connecting devices
    [_connectingDevices addObject: device];
    
    // Reset device states before connecting
    [hiddenDevice resetStates];
    
    // Inform CoreBluetooth we want to connect the specified peripheral
    [_centralManager connectPeripheral: device.cbPeripheral options: nil];
}

/**
 watchDogTimerForConnectTick is called when a connect operation timed out
 
 @param device - the device to which connect failed
 @phase - the connect phase
 */
-(void)watchDogTimerForConnectTick:(TxRxWatchDogTimer *) timer ManagesDevice: (TxRxDevice *) device inPhase: (NSNumber *) phase
{
    [_centralManager cancelPeripheralConnection: device.cbPeripheral];
    [_connectingDevices removeObject: device];
    [_connectedDevices removeObject: device];
    [self sendDeviceConnectError: device withErrorCode: TERTIUM_ERROR_DEVICE_CONNECT_TIMED_OUT withText: S_TERTIUM_ERROR_DEVICE_CONNECT_TIMED_OUT];
}

#pragma mark CBCentralManagerDelegate implementation
/**
 CBCentralManagerDelegate delegate implementation. Called by CoreBluetooth when it has connected to a device
 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    TxRxDevice *device;
    
    device = [self deviceFromConnectingPeripheral: peripheral];
    if (!device) {
        return;
    }
    
    // Call delegate
    if (device.delegate)
        dispatch_async(_callbackQueue, ^{
            [device.delegate deviceConnectError: device withError: error];
        });
    
    [_connectingDevices removeObject: device];
}

/**
 CBCentralManagerDelegate delegate implementation. Called by CoreBluetooth when it has connected to a device
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    TxRxDevice *device;
    
    // Search for the TxRxDevice class instance by the CoreBlueTooth peripheral instance
    device = [self deviceFromConnectingPeripheral: peripheral];
    if (!device) {
        [self sendInternalError: device withErrorCode: TERTIUM_INTERNAL_ERROR errorText: @"Connected to an unexpected device!"];
        return;
    }
    
    // Assign delegate of CoreBluetooth peripheral to our class
    peripheral.delegate = self;
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice = (NSObject<TxRxDeviceManagerExchangeProtocol>*) device;
    hiddenDevice.deviceConnected = true;
    
    // Stop timeout watchdog timer
    [hiddenDevice invalidateWatchDogTimer];
    
    // Device is connected, add it to the connected devices list and remove it from connecting devices list
    [_connectedDevices addObject: device];
    [_connectingDevices removeObject: device];
    
    // Call delegate
    if (device.delegate)
        dispatch_async(_callbackQueue, ^{
            [device.delegate deviceConnected: device];
        });
    
    // Ask CoreBluetooth to discover services for this peripheral
    [peripheral discoverServices: nil];
}

/**
 CBCentralManagerDelegate delegate implementation. Called by CoreBluetooth when it has discovered device's services
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    CBService* tertiumService;
    TxRxDevice* device;
    
    // Search for the TxRxDevice class instance by the CoreBlueTooth peripheral instance
    device = [self deviceFromConnectedPeripheral: peripheral];
    if (!device) {
        [self sendInternalError: TERTIUM_ERROR_DEVICE_NOT_FOUND errorText: S_TERTIUM_ERROR_DEVICE_NOT_FOUND];
        return;
    }
    
    if(error != nil) {
        // An error happened discovering services, report to delegate. For us, it's still CONNECT phase
        if (device.delegate)
            dispatch_async(_callbackQueue, ^{
                [device.delegate deviceConnectError: device withError: error];
            });
        return;
    }
    
    // Search for device service UUIDs. We use service UUID to map device to a Tertium BLE device profile. See class TxRxDeviceProfile for details
    for (CBService *service in peripheral.services) {
        for (TxRxDeviceProfile *deviceProfile in _txRxSupportedDevices) {
            if ([service.UUID isEqual: [CBUUID UUIDWithString: deviceProfile.serviceUUID]]) {
                device.deviceProfile = deviceProfile;
                tertiumService = service;
                break;
            }
        }
        
        if (tertiumService != nil)
            break;
    }
    
    if (tertiumService)
        [peripheral discoverCharacteristics: nil forService:tertiumService];
}

/**
 CBCentralManagerDelegate delegate implementation. Called by CoreBluetooth when it has discovered device service characteristics
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    TxRxDevice* device;
    
    // Look for Tertium BLE device transmit and receive characteristics
    device = [self deviceFromConnectedPeripheral: peripheral];
    for (CBCharacteristic *characteristic in service.characteristics) {
        if (device.deviceProfile) {
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:device.deviceProfile.txUUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                device.txChar = characteristic;
            } else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:device.deviceProfile.rxUUID]]) {
                device.rxChar = characteristic;
            }
        }
        
        NSLog(@"Discovered characteristic %@ of service %@ of device %@ option mask %08lx", [characteristic.UUID UUIDString], [service.UUID UUIDString], device.Name, (long)characteristic.properties);
    }
    
    if (device.rxChar != nil && device.txChar != nil && device.delegate) {
        dispatch_async(_callbackQueue, ^{
            [device.delegate deviceReady: device];
        });
    }
}

#pragma mark TxRxManager implementation


/**
 Begins sending the NSData byte buffer to a connected device.
 
 NOTE: you may ONLY send data to already connected devices
 NOTE: Data to device is sent in MTU fragments (refer to TxRxDeviceProfile maxSendPacketSize class attribute)
 
 @param device - the device to send the data (must be connected first!)
 @param data - NSData class with contents of data to sent
 */
-(void)sendData: (TxRxDevice *_Nonnull) device withData: (NSData *_Nonnull) data
{
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice;
    NSMutableData *dataToSend;
    
    hiddenDevice = (NSObject<TxRxDeviceManagerExchangeProtocol> *) device;
    
    // Verify BlueTooth is powered on
    if (!_blueToothPoweredOn) {
        [self sendBlueToothNotReadyOrLost];
        return;
    }
    
    // Verify we aren't scanning. We cannot send data when scanning for devices
    if (_isScanning) {
        [self sendUnableToPerformDuringScan: device];
        return;
    }
    
    if ([_connectedDevices containsObject: device] == false) {
        [self sendNotConnectedError: device];
        return;
    }
    
    if (device.txChar == nil || device.rxChar == nil) {
        [self sendDeviceConnectError: device withErrorCode: TERTIUM_ERROR_DEVICE_SERVICE_OR_CHARACTERISTICS_NOT_DISCOVERED_YET withText: S_TERTIUM_ERROR_DEVICE_SERVICE_OR_CHARACTERISTICS_NOT_DISCOVERED_YET];
        return;
    }
    
    // Verify if we aren't sending data to the device already (so either we are sending or we are waiting for ack or receiving data from device)
    if (hiddenDevice.sendingData) {
        [self sendDeviceWriteError: device withErrorCode: TERTIUM_ERROR_DEVICE_SENDING_DATA_ALREADY withText: S_TERTIUM_ERROR_DEVICE_SENDING_DATA_ALREADY];
        return;
    }
    
    // Assign data to be sent to the device instance by accessing hidden TxRxDevicManagerExchangeProtocol methods and properties
    // NOTE: data is sent in FRAGMENTS by multiple CoreBlueTooth calls
    dataToSend = [NSMutableData new];
    [dataToSend appendData: data];
    [dataToSend appendData: [device.deviceProfile.commandEnd dataUsingEncoding: NSASCIIStringEncoding]];
    hiddenDevice.dataToSend = dataToSend;
    hiddenDevice.sendingData = true;

    // Commence data sending to device. NOTE: Data is sent in maxSendPacketSize fragments (refer to TxRxDeviceProfile class for details)
    [self deviceSendDataPiece: device];
}

/**
 Sends a fragment of data to the device
 
 NOTE: This method is also called in response to CoreBlueTooth send data fragment acknowledge

 @param device - The device to send data to
 */
-(void)deviceSendDataPiece: (TxRxDevice *_Nonnull) device
{
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice;
    NSData *packet;
    NSInteger packetSize;
    
    if ([_connectedDevices containsObject: device]) {
        hiddenDevice = (NSObject<TxRxDeviceManagerExchangeProtocol> *) device;
        if (!hiddenDevice.sendingData)
            return;
        
        // Access protected device fields to verify if we have still to send data fragments or if we sent all data
        if (hiddenDevice.totalBytesSent < hiddenDevice.bytesToSend) {
            // We still have to send buffer pieces
            packetSize = (device.deviceProfile.maxSendPacketSize + hiddenDevice.totalBytesSent < hiddenDevice.bytesToSend ? device.deviceProfile.maxSendPacketSize: hiddenDevice.bytesToSend - hiddenDevice.totalBytesSent);
            packet = [hiddenDevice.dataToSend subdataWithRange: NSMakeRange(hiddenDevice.totalBytesSent, packetSize)];
            [device.cbPeripheral writeValue:packet forCharacteristic:device.rxChar type:CBCharacteristicWriteWithResponse];
            hiddenDevice.bytesSent = packetSize;
            
            // Enable recieve watchdog timer for send acks
            [hiddenDevice scheduleWatchdogWithParameters: TERTIUM_PHASE_WAITING_SEND_ACK withInterval: (hiddenDevice.totalBytesSent == 0 ? _receiveFirstPacketTimeout: _receivePacketsTimeout) target: self selector: @selector(watchDogTimerTickReceivingSendAck:ManagesDevice:inPhase:)];
        } else {
            // All buffer contents have been sent
            hiddenDevice.sendingData = false;
            hiddenDevice.dataToSend = nil;
            
            // Enable recieve watchdog timer. Waiting for response from Tertium BLE device
            [hiddenDevice scheduleWatchdogWithParameters: TERTIUM_PHASE_RECEIVING_DATA withInterval: _receiveFirstPacketTimeout target: self selector: @selector(watchDogTimerTickReceivingData:ManagesDevice:inPhase:)];
            return;
        }
    } else {
        [self sendDeviceWriteError: device withErrorCode: TERTIUM_ERROR_DEVICE_NOT_CONNECTED withText: S_TERTIUM_ERROR_DEVICE_NOT_CONNECTED];
    }
}

#pragma mark TxRxManager implementation

/**
 Watchdog for timeouts on BLE device write acknowledges
 */
-(void)watchDogTimerTickReceivingSendAck:(TxRxWatchDogTimer *) timer ManagesDevice: (TxRxDevice *) device inPhase: (NSNumber *) phase
{
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice;
    hiddenDevice.sendingData = false;
    [self sendDeviceWriteError: device withErrorCode: TERTIUM_ERROR_DEVICE_SENDING_DATA_TIMEOUT withText: S_TERTIUM_ERROR_DEVICE_SENDING_DATA_TIMEOUT];
}

#pragma mark CBPeripheralDelegate implementation

/**
 CoreBlueTooth acknowledging our last fragment send
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice;
    TxRxDevice* device;
    
    device = [self deviceFromConnectedPeripheral: peripheral];
    hiddenDevice = (NSObject<TxRxDeviceManagerExchangeProtocol> *) device;
    if(error != nil) {
        hiddenDevice.sendingData = false;
        if (device.delegate)
            dispatch_async(_callbackQueue, ^{
                [device.delegate deviceWriteError: device withError: error];
            });
        return;
    }
    
    // Send data acknowledgement arrived in time, stop the watchdog timer
    [hiddenDevice invalidateWatchDogTimer];
    
    // Update device's total bytes sent and try to send more data
    hiddenDevice.totalBytesSent += hiddenDevice.bytesSent;
    dispatch_async(_dispatchQueue, ^{
        [self deviceSendDataPiece: device];
    });
}

#pragma mark TxRxManager implementation

/**
 Watchdog for timeouts on BLE device answer to previously issued command
 */
-(void)watchDogTimerTickReceivingData:(TxRxWatchDogTimer *) timer ManagesDevice: (TxRxDevice *) device inPhase: (NSNumber *) phase
{
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice;
    hiddenDevice = (NSObject<TxRxDeviceManagerExchangeProtocol> *) device;
    
    // Verify what we have received
    NSString *text;
    
    // Verify terminator is ok, otherwise we may haven't received a whole response command
    text = [[NSString alloc] initWithData: hiddenDevice.receivedData encoding: NSASCIIStringEncoding];
    if ([self isTerminatorOK: device forText: text]) {
        if (device.delegate) {
            NSData* dispatchData;
            
            dispatchData = [NSData dataWithData: hiddenDevice.receivedData];
            [hiddenDevice resetReceivedData];
            dispatch_async(_callbackQueue, ^{
                [device.delegate receivedData: device withData: dispatchData];
            });
        } else {
            [hiddenDevice resetReceivedData];
        }
    } else {
        [hiddenDevice resetReceivedData];
        [self sendDeviceReadError: device withErrorCode: TERTIUM_ERROR_DEVICE_RECEIVING_DATA_TIMEOUT withText: S_TERTIUM_ERROR_DEVICE_RECEIVING_DATA_TIMEOUT];
    }
}

#pragma mark CBPeripheralDelegate implementation

/**
 Core bluetooth informs us we received data from the device
 */
- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice;
    TxRxDevice* device;
    NSData *data;
    
    device = [self deviceFromConnectedPeripheral: aPeripheral];
    hiddenDevice = (NSObject<TxRxDeviceManagerExchangeProtocol> *) device;
    if(error != nil) {
        // There has been an error receiving data
        if (device.delegate)
            dispatch_async(_callbackQueue, ^{
                [device.delegate deviceReadError: device withError: error];
            });
        
        // Device read error, stop WatchDogTimer
        [hiddenDevice invalidateWatchDogTimer];
        return;
    }
    
    if (characteristic == device.txChar) {
        // We received data from peripheral
        data = [[NSMutableData alloc] initWithBytes:[characteristic.value bytes] length:characteristic.value.length];
        [hiddenDevice.receivedData appendData: data];
        
        if (hiddenDevice.watchDogTimer == nil) {
            // Passive receive
            if (device.delegate)
                dispatch_async(_callbackQueue, ^{
                    [device.delegate receivedData: device withData: data];
                });
        } else {
            // Schedule a new watchdog timer for receiving data packets
            [hiddenDevice scheduleWatchdogWithParameters: TERTIUM_PHASE_RECEIVING_DATA withInterval: _receivePacketsTimeout target: self selector: @selector(watchDogTimerTickReceivingData:ManagesDevice:inPhase:)];
        }
    }
}

/**
 Disconnect a previously connected device
 
 @param device The device to disconnect, MUST be non null
 */
-(void)disconnectDevice:(TxRxDevice *_Nonnull)device
{
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice;

    // Verify BlueTooth is powered on
    if (!_blueToothPoweredOn) {
        [self sendBlueToothNotReadyOrLost];
        return;
    }
    
    // We can't disconnect while scanning for devices
    if (_isScanning) {
        [self sendUnableToPerformDuringScan: device];
        return;
    }
    
    // Verify device is truly connected
    if (![_connectedDevices containsObject: device]) {
        [self sendNotConnectedError: device];
        return;
    }
    
    // Verify we aren't disconnecting already from the device (we may be waiting for disconnect ack)
    if ([_disconnectingDevices containsObject: device]) {
        [self sendDeviceConnectError: device withErrorCode: TERTIUM_ERROR_ALREADY_DISCONNECTING withText: S_TERTIUM_ERROR_ALREADY_DISCONNECTING];
        return;
    }
    
    // Add the device to the array of disconnecting devices
    [_disconnectingDevices addObject: device];
    
    // Create a disconnect watchdog timer
    hiddenDevice = (NSObject<TxRxDeviceManagerExchangeProtocol> *) device;
    [hiddenDevice scheduleWatchdogWithParameters: TERTIUM_PHASE_DISCONNECTING withInterval: _connectTimeout target: self selector: @selector(watchDogTimerForDisconnectTick:ManagesDevice:inPhase:)];
    
    // Ask CoreBlueTooth to disconnect the device
    [_centralManager cancelPeripheralConnection: device.cbPeripheral];
}

/**
 Verifies disconnect happens is a timely fashion
 */
-(void)watchDogTimerForDisconnectTick:(TxRxWatchDogTimer *) timer ManagesDevice: (TxRxDevice *) device inPhase: (NSNumber *) phase
{
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice;
    
    // Disconnecting device timed out, we received no feedback. We consider the device disconnected anyway.
    hiddenDevice = (NSObject<TxRxDeviceManagerExchangeProtocol> *) device;
    [_disconnectingDevices removeObject: device];
    [_connectedDevices removeObject: device];
    [_connectingDevices removeObject: device];
    
    //
    [hiddenDevice resetStates];

    // Inform delegate device disconnet timed out
    [self sendDeviceConnectError: device withErrorCode: TERTIUM_ERROR_DEVICE_DISCONNECT_TIMED_OUT withText: S_TERTIUM_ERROR_DEVICE_DISCONNECT_TIMED_OUT];
}

#pragma mark CBCentralManagerDelegate implementation

/**
 Corebluetooth informs us we have disconnected from a peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSObject<TxRxDeviceManagerExchangeProtocol> *hiddenDevice;
    TxRxDevice* device;
    
    device = [self deviceFromDisconnectingPeripheral: peripheral];
    if (device) {
        hiddenDevice = (NSObject<TxRxDeviceManagerExchangeProtocol> *) device;
        if(error != nil) {
            // There has been an error disconnecting the device
            if (device.delegate)
                dispatch_async(_callbackQueue, ^{
                    [device.delegate deviceConnectError: device withError: error];
                });
            
            // Consider the device disconnected anyway
        }
        
        // Remove device from internal validation arrays and inform delegate of the disconnection
        [hiddenDevice invalidateWatchDogTimer];
        [hiddenDevice resetStates];
        
        [_connectedDevices removeObject: device];
        [_connectingDevices removeObject: device];
        [_disconnectingDevices removeObject: device];
        
        if (device.delegate)
            dispatch_async(_callbackQueue, ^{
                [device.delegate deviceDisconnected: device];
            });
    }
}

#pragma mark TxRxManager implementation

-(bool)isTerminatorOK: (TxRxDevice *_Nonnull) device forText: (NSString *_Nonnull) text
{
    if (text == nil || [text length] == 0)
        return false;
    
    return [text hasSuffix: device.deviceProfile.commandEnd];
}

/*
 Methods for finding a TxRxDevice from a CoreBlueTooth CBPeripheral instance
 */
-(TxRxDevice *) deviceFromConnectingPeripheral: (CBPeripheral*_Nonnull) peripheral
{
    for (TxRxDevice* device in _connectingDevices) {
        if (device.cbPeripheral == peripheral) {
            return device;
        }
    }
    
    [self sendInternalError: TERTIUM_ERROR_DEVICE_NOT_FOUND errorText: S_TERTIUM_ERROR_DEVICE_NOT_FOUND];
    return nil;
}

-(TxRxDevice *) deviceFromConnectedPeripheral: (CBPeripheral*_Nonnull) peripheral
{
    for (TxRxDevice* device in _connectedDevices) {
        if (device.cbPeripheral == peripheral) {
            return device;
        }
    }
    
    [self sendInternalError: TERTIUM_ERROR_DEVICE_NOT_FOUND errorText: S_TERTIUM_ERROR_DEVICE_NOT_FOUND];
    return nil;
}

-(TxRxDevice *) deviceFromDisconnectingPeripheral: (CBPeripheral*_Nonnull) peripheral
{
    for (TxRxDevice* device in _disconnectingDevices) {
        if (device.cbPeripheral == peripheral) {
            return device;
        }
    }
    
    [self sendInternalError: TERTIUM_ERROR_DEVICE_NOT_FOUND errorText: S_TERTIUM_ERROR_DEVICE_NOT_FOUND];
    return nil;
}


/**
 Clears every internal array. May be called on Bluetooth hardware reset
 */
-(void)masterCleanUp
{
    for (NSObject<TxRxDeviceManagerExchangeProtocol> *device in _scannedDevices) {
        [device invalidateWatchDogTimer];
        [device resetStates];
    }
    [_scannedDevices removeAllObjects];
    
    for (NSObject<TxRxDeviceManagerExchangeProtocol> *device in _connectingDevices) {
        [device invalidateWatchDogTimer];
        [device resetStates];
    }
    [_connectingDevices removeAllObjects];
    
    for (NSObject<TxRxDeviceManagerExchangeProtocol> *device in _connectedDevices) {
        [device invalidateWatchDogTimer];
        [device resetStates];
    }
    [_connectedDevices removeAllObjects];
    
    for (NSObject<TxRxDeviceManagerExchangeProtocol> *device in _disconnectingDevices) {
        [device invalidateWatchDogTimer];
        [device resetStates];
    }
    [_disconnectingDevices removeAllObjects];
    
    _isScanning = false;
    if (_blueToothPoweredOn == true)
        [self sendBlueToothNotReadyOrLost];
}

/*
 Various utility methods to inform delegate of occuores erros
 */
-(void)sendScanError: (NSInteger) errorCode withText: (NSString *_Nonnull) errorText
{
    NSError *error = [NSError errorWithDomain:TERTIUM_TXRX_ERROR_DOMAIN code: errorCode userInfo:[NSDictionary dictionaryWithObject:errorText forKey:NSLocalizedDescriptionKey]];
    
    if (_delegate)
        dispatch_async(_callbackQueue, ^{
            [_delegate deviceScanError: error];
        });
}

-(void)sendDeviceConnectError: (TxRxDevice *_Nonnull) device withErrorCode: (NSInteger) errorCode withText: (NSString *_Nonnull) errorText
{
    NSError *error = [NSError errorWithDomain:TERTIUM_TXRX_ERROR_DOMAIN code: errorCode userInfo:[NSDictionary dictionaryWithObject:errorText forKey:NSLocalizedDescriptionKey]];
    
    if (device.delegate)
        dispatch_async(_callbackQueue, ^{
            [device.delegate deviceConnectError: device withError: error];
        });
}

-(void)sendDeviceWriteError: (TxRxDevice *_Nonnull) device withErrorCode: (NSInteger) errorCode withText: (NSString *_Nonnull) errorText
{
    NSError *error = [NSError errorWithDomain:TERTIUM_TXRX_ERROR_DOMAIN code: errorCode userInfo:[NSDictionary dictionaryWithObject:errorText forKey:NSLocalizedDescriptionKey]];
    
    if (device.delegate)
        dispatch_async(_callbackQueue, ^{
            [device.delegate deviceWriteError: device withError: error];
        });
}

-(void)sendDeviceReadError: (TxRxDevice *_Nonnull) device withErrorCode: (NSInteger) errorCode withText: (NSString *_Nonnull) errorText
{
    NSError *error = [NSError errorWithDomain:TERTIUM_TXRX_ERROR_DOMAIN code: errorCode userInfo:[NSDictionary dictionaryWithObject:errorText forKey:NSLocalizedDescriptionKey]];
    
    if (device.delegate)
        dispatch_async(_callbackQueue, ^{
            [device.delegate deviceReadError: device withError: error];
        });
}

-(void)sendInternalError: (NSInteger) errorCode errorText: (NSString *_Nonnull) errorText
{
    NSError *error = [NSError errorWithDomain:TERTIUM_TXRX_ERROR_DOMAIN code: errorCode userInfo:[NSDictionary dictionaryWithObject:errorText forKey:NSLocalizedDescriptionKey]];
    
    if (_delegate)
        dispatch_async(_callbackQueue, ^{
            [_delegate deviceInternalError: error];
        });
}

-(void)sendInternalError: (TxRxDevice *_Nonnull) device withErrorCode: (NSInteger) errorCode errorText: (NSString *_Nonnull) errorText
{
    NSError *error = [NSError errorWithDomain:TERTIUM_TXRX_ERROR_DOMAIN code: errorCode userInfo:[NSDictionary dictionaryWithObject:errorText forKey:NSLocalizedDescriptionKey]];
    
    if (device.delegate)
        dispatch_async(_callbackQueue, ^{
            [device.delegate deviceInternalError: device withError: error];
        });
}

-(void)sendNotConnectedError: (TxRxDevice *_Nonnull) device
{
    NSError *error = [NSError errorWithDomain:TERTIUM_TXRX_ERROR_DOMAIN code: TERTIUM_ERROR_DEVICE_NOT_CONNECTED userInfo:[NSDictionary dictionaryWithObject:S_TERTIUM_ERROR_DEVICE_NOT_CONNECTED forKey:NSLocalizedDescriptionKey]];
    
    if (device.delegate)
        dispatch_async(_callbackQueue, ^{
            [device.delegate deviceConnectError: device withError: error];
        });
}

-(void)sendUnableToPerformDuringScan: (TxRxDevice *_Nonnull) device
{
    NSError *error = [NSError errorWithDomain:TERTIUM_TXRX_ERROR_DOMAIN code: TERTIUM_ERROR_DEVICE_UNABLE_TO_PERFORM_DURING_SCAN userInfo:[NSDictionary dictionaryWithObject:S_TERTIUM_ERROR_DEVICE_UNABLE_TO_PERFORM_DURING_SCAN forKey:NSLocalizedDescriptionKey]];
    
    if (device.delegate)
        dispatch_async(_callbackQueue, ^{
            [device.delegate deviceConnectError: device withError: error];
        });
}

-(void)sendBlueToothNotReadyOrLost {
    [self sendScanError: TERTIUM_ERROR_BLUETOOTH_NOT_READY_OR_LOST withText: S_TERTIUM_ERROR_BLUETOOTH_NOT_READY_OR_LOST];
}

// APACHE CORDOVA UTILITY METHODS

/**
 Returns the instance of TxRxDevice which corresponds to the supplied device name
 
 @param name - The device's name
 @return the TxRxDevice instance, or null if not found
 */
-(TxRxDevice *_Nullable) deviceWithIndexedName: (NSString *_Nonnull) name
{
    for (TxRxDevice* device in _scannedDevices) {
        if ([device.IndexedName caseInsensitiveCompare: name] == NSOrderedSame)
            return device;
    }
    
    return nil;
}

/**
 Returns the name of the supplied TxRxDevice instance
 @param device - the device to connect to, MUST be non null
 */
-(NSString *_Nonnull) getDeviceIndexedName: (TxRxDevice *_Nonnull) device
{
    return device.IndexedName;
}

/**
 Resets current timeout values to default values
 */
-(void)setTimeOutDefaults
{
    _connectTimeout = 20.0;
    _receiveFirstPacketTimeout = 2.0;
    _receivePacketsTimeout = 0.5;
    _writePacketTimeout = 0.5;
}

/**
 Returns the current timeout value for a specified bluetooth event type
 @param timeOutType - The timeout to retrieve
 */
-(uint32_t) getTimeOutValue: (NSString *_Nonnull) timeOutType
{
    if ([timeOutType caseInsensitiveCompare: S_TERTIUM_TIMEOUT_CONNECT] == NSOrderedSame) {
        return _connectTimeout * 1000.0;
    } else if ([timeOutType caseInsensitiveCompare: S_TERITUM_TIMEOUT_RECEIVE_FIRST_PACKET] == NSOrderedSame) {
        return _receiveFirstPacketTimeout * 1000.0;
    } else if ([timeOutType caseInsensitiveCompare: S_TERTIUM_TIMEOUT_RECEIVE_PACKETS] == NSOrderedSame) {
        return _receivePacketsTimeout * 1000.0;
    } else if ([timeOutType caseInsensitiveCompare: S_TERTIUM_TIMEOUT_SEND_PACKET] == NSOrderedSame) {
        return _writePacketTimeout * 1000.0;
    } else {
        return 0;
    }
}

/**
 Set the current timeout value for a specified bluetooth event type
 @param timeOutValue - The timeout value, in MILLISECONDS
 @param timeOutType - The timeout to retrieve
 */
-(void)setTimeOutValue: (uint32_t) timeOutValue forTimeOutType: (NSString *_Nonnull) timeOutType
{
    if ([timeOutType caseInsensitiveCompare: S_TERTIUM_TIMEOUT_CONNECT] == NSOrderedSame) {
        _connectTimeout = timeOutValue / 1000.0;
    } else if ([timeOutType caseInsensitiveCompare: S_TERITUM_TIMEOUT_RECEIVE_FIRST_PACKET] == NSOrderedSame) {
        _receiveFirstPacketTimeout = timeOutValue / 1000.0;
    } else if ([timeOutType caseInsensitiveCompare: S_TERTIUM_TIMEOUT_RECEIVE_PACKETS] == NSOrderedSame) {
        _receivePacketsTimeout = timeOutValue / 1000.0;
    } else if ([timeOutType caseInsensitiveCompare: S_TERTIUM_TIMEOUT_SEND_PACKET] == NSOrderedSame) {
        _writePacketTimeout = timeOutValue / 1000.0;
    }
}

@end
