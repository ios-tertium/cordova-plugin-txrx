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

#ifndef TxRxDeviceDataProtocol_h
#define TxRxDeviceDataProtocol_h

@class TxRxDevice;

/**
 TxRxManager library TxRxDeviceDataProtocol
 
 TxRxDeviceDataProtocol defines the callbacks in data exchange between TxRxManager class and Tertium BLE Devices
 
 Delegate will receive data exchange information
 */
@protocol TxRxDeviceDataProtocol<NSObject>
@required
/**
 Informs delegate an error while connecting device happened
 */
-(void)deviceConnectError: (TxRxDevice * _Nonnull) device withError: (NSError * _Nonnull) error;

/**
 Informs delegate a device has been connected
 */
-(void)deviceConnected: (TxRxDevice * _Nonnull) device;

/**
 Informs delegate the connected device is ready to receive commands and has been identified as Tertium BLE hardware
 */
-(void)deviceReady: (TxRxDevice * _Nonnull) device;

/**
 Informs delegate there has been an error receiving data from device
 */
-(void)deviceReadError: (TxRxDevice * _Nonnull) device withError: (NSError * _Nonnull) error;

/**
 Informs delegate there has been an error sending data to device
 */
-(void)deviceWriteError: (TxRxDevice * _Nonnull) device withError: (NSError * _Nonnull) error;

/**
 Informs delegate the last sendData operation has succeeded
 */
-(void)sentData: (TxRxDevice * _Nonnull) device;

/**
 Informs delegate Tertium device has sent data
 
 NOTE: This can even happen PASSIVELY without having issued a command
 */
-(void)receivedData: (TxRxDevice * _Nonnull) device withData: (NSData * _Nonnull) data;

/**
 Informs delegate a device has been disconnected
 */
-(void)deviceDisconnected: (TxRxDevice * _Nonnull) device;

/**
 Informs delegate a general error happened on the device
 */
-(void)deviceInternalError: (TxRxDevice * _Nonnull) device withError: (NSError * _Nonnull) error;
@end

#endif /* TxRxDeviceDataProtocol_h */
