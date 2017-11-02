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
#import "TxRxWatchDogTimer.h"

#ifndef TxRxDeviceManagerExchangeProtocol_h
#define TxRxDeviceManagerExchangeProtocol_h

/**
 TxRxManager library TxRxDeviceManagerExchangeProtocol
 
 TxRxDeviceManagerExchangeProtocol is a protocol which defines TxRxLibrary ONLY methods implemented in TxRxDevice. SHOULD NOT BE USED in application code
 */
@protocol TxRxDeviceManagerExchangeProtocol<NSObject>
@required
/**
 The instace of TxRxWatchDogTimer class handling the timeouts of this TxRxDevice
 */
@property (nonatomic, strong, nullable) TxRxWatchDogTimer *watchDogTimer;

/**
 The data and data description and states TxRxManager's sendData:device:data: method attaches to the TxRxDevice when sending data to a Tertium Device
 */
@property (nonatomic) NSInteger bytesToSend;
@property (nonatomic) NSInteger bytesSent;
@property (nonatomic) NSInteger totalBytesSent;
@property (nonatomic) bool sendingData;
@property (nonatomic, strong, nullable) NSData *dataToSend;

/**
 The internal device connected bool. YES or true when connected, NO or false when disconnected.
 
 NOTE: This field aliases the PUBLIC IsConnected property in TxRxDevice implementation which is READONLY. Only TxRxManager class may change TxRxDevice connected property
*/
@property (nonatomic) bool deviceConnected;

/**
 A NSMutableData hodling the bytes received from the Tertium BLE device.
 
 NOTE: Whole answers are NOT received in a single transfer. Data is accumulated by TxRxManager on CoreBluetooth callbacks. This is why field is NSMutableData instead of NSData
*/
@property (nonatomic, strong, nonnull) NSMutableData *receivedData;

// Please refer to TxRxDevice implementation for method details
-(void)scheduleWatchdogWithParameters:(NSInteger) inPhase withInterval:(NSTimeInterval)ti target:(id _Nonnull )aTarget selector:(SEL _Nonnull)aSelector;
-(void)invalidateWatchDogTimer;
-(void)resetReceivedData;
-(void)resetStates;
@end

#endif /* TxRxDeviceExchangeProtocol_h */
