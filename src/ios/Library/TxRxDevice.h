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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TxRxDeviceDataProtocol.h"

@class TxRxDeviceProfile;
@class TxRxManager;
@class TxRxWatchDogTimer;

/**
 
 TxRxManager library TxRxDevice class
 
 Holds CoreBluetooth internal class references and Tertium BLE device information
 
 */
@interface TxRxDevice : NSObject

/**
 This device's delegate. Delegate will receive data exchange information specified in TxRxDeviceDataProtocol
 */
@property (nonatomic, weak, nullable) NSObject<TxRxDeviceDataProtocol> *delegate;

/**
 This device's name. When a device doesn't supply a name "Unnamed device" will be used
 */
@property (nonatomic, copy, nonnull) NSString *Name;

/**
 This device's indexed name. When a device doesn't supply a name "Unnamed device" will be used
 */
@property (nonatomic, copy, nonnull) NSString *IndexedName;

/**
 Reference to CoreBluetooth Peripheral class instance. Holds device bluetooth information
 */
@property (nonatomic, strong, nonnull) CBPeripheral *cbPeripheral;

/**
 Reference to CoreBluetooth CBCharacteristic class instance. Holds RECEIVE device information
 */
@property (nonatomic, strong, nullable) CBCharacteristic *rxChar;

/**
 Reference to CoreBluetooth CBCharacteristic class instance. Holds TRANSMIT device information
 */
@property (nonatomic, strong, nullable) CBCharacteristic *txChar;

/**
 This device's profile. Please refer to TxRxDeviceProfile class for details
 */
@property (nonatomic, strong, nonnull) TxRxDeviceProfile *deviceProfile;

/**
 If device is connected
 */
@property (nonatomic, readonly) bool isConnected;
@end
