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

#ifndef TxRxDeviceScanProtocol_h
#define TxRxDeviceScanProtocol_h

@class TxRxDevice;

/**
 TxRxManager library TxRxDeviceScanProtocol
 
 TxRxDeviceScanProtocol defines the callbacks in de

 Delegate will receive device scan information
*/
@protocol TxRxDeviceScanProtocol<NSObject>
@required
/**
 Informs delegate device scanning has began
 */
-(void)deviceScanBegan;

/**
 Informs delegate a device has been found while scanning for BLE devices
 */
-(void)deviceFound: (TxRxDevice * _Nonnull) device;

/**
 Informs delegate device scanning ended. You can NOW connect to found devices
 */
-(void)deviceScanEnded;

/**
 Informs delegate a device scan error occoured
 */
-(void)deviceScanError: (NSError * _Nonnull) error;

/**
 Informs delegate a device critical error happened. NO further interaction with this TxRxDevice class should be done
 */
-(void)deviceError: (TxRxDevice * _Nonnull) device withError: (NSError * _Nonnull) error;

/**
 Informs delegate a critical error happened
 */
-(void)deviceInternalError: (NSError * _Nonnull) error;
@end

#endif
