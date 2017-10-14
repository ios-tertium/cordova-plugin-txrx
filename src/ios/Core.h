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
#import "TxRxDeviceScanProtocol.h"
#import "TxRxDeviceDataProtocol.h"
#import "TxRxDevice.h"
#import "TxRxManager.h"

/**
 
 Core is a singleton proxy class responsible for dispatching notifications received from Tertium TxRx Devices to the whole application
 
 NOTE:  This class is just a commodity created for persistence in handling TxRxManager and TxRxDevice callbacks. You are free to use a different architecture when building applications with TxRxMananger library
 
 Implementing TxRxManager library protocols in viewcontrollers is NOT a good architecture choice and may have persistence issues
 (ViewController being destroyed while still being delegate to either TxRxManager or TxRxManagerDevice callbacks crashing the application)
 
 Methods are ordered chronologically
 
 */
@interface Core : NSObject<TxRxDeviceScanProtocol, TxRxDeviceDataProtocol>
{
    // Mantains a reference to an instance of NSNotificationCenter default center class
    NSNotificationCenter* _notificationCenter;
    
    // Mantains a reference to instances of scanned devices found by calling startScan method
    NSMutableArray* _scannedDevices;
    
    // Mantains a reference to the instance of TxRxManager library singleton class
    TxRxManager* _manager;
}

/**
 Please find documentation about core class methods in the implementation file
 */
+(Core *_Nonnull) getCore;
-(bool) isScanning;
-(void) startScan;
-(void) stopScan;
-(NSArray *_Nonnull) getScannedDevices;
-(void) connectDevice: (TxRxDevice *_Nonnull) device;
-(void) sendData: (TxRxDevice *_Nonnull) device withData: (NSData *_Nonnull) data;
-(void) disconnectDevice: (TxRxDevice *_Nonnull) device;

@end
