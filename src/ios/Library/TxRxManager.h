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
#import "TxRxManagerTimeOuts.h"
#import "TxRxWatchDogTimer.h"
#import "TxRxDeviceScanProtocol.h"
#import "TxRxDeviceProfile.h"
#import "TxRxDevice.h"

/**
 TxRxManager library TxRxManager class
 
 TxRxManager class is TxRxManager library main class
 
 TxRxManager eases programmer life by dealing with CoreBluetooth internals
 
 NOTE: Implements CBCentralManagerDelegate and CBPeripheralDelegate protocols
 */
@interface TxRxManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

/**
 dispatchQueue - GCD internal queue. Queue to which TxRxManager internals dispatch asyncronous calls. Change if you want the class to work in a thread with its GCD queue
 DEFAULT: main thread queue
 */
@property (nonatomic, strong, nonnull) dispatch_queue_t dispatchQueue;

/**
 callbackQueue - Dispatch queue to which delegate callbacks will be issued.
 DEFAULT: main thread queue
 */
@property (nonatomic, strong, nonnull) dispatch_queue_t callbackQueue;

/**
 delegate - Delegate for scanning devices. Delegate will be called on TxRxDeviceScanProtocol methods (refer to TxRxDeviceScanProtocol.h)
 */
@property (nonatomic, weak, nullable) NSObject<TxRxDeviceScanProtocol> *delegate;

/**
 isScanning - Property telling if the class is currently in scanning devices phase
 */
@property (nonatomic) bool isScanning;

// Please find documentation about class methods and class description in the implementation file
+(instancetype _Nonnull) getManager;

-(void)startScan;
-(void)stopScan;
-(void)connectDevice: (TxRxDevice *_Nonnull) device;
-(void)disconnectDevice: (TxRxDevice *_Nonnull) device;
-(void)sendData: (TxRxDevice *_Nonnull) device withData: (NSData *_Nonnull) data;

// APACHE CORDOVA UTILITY METHODS
-(TxRxDevice *_Nullable) deviceWithIndexedName: (NSString *_Nonnull) name;
-(NSString *_Nonnull) getDeviceIndexedName: (TxRxDevice *_Nonnull) device;

-(void)setTimeOutDefaults;
-(uint32_t) getTimeOutValue: (NSString *_Nonnull) timeOutType;
-(void)setTimeOutValue: (uint32_t) timeoutvalue forTimeOutType: (NSString *_Nonnull) timeOutType;

@end
