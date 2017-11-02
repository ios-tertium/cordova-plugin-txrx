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

#import "TxRxDeviceProfile.h"

@implementation TxRxDeviceProfile
@synthesize serviceUUID, rxUUID, txUUID, commandEnd, maxSendPacketSize;

/**
 Creates an instance of TxRxDeviceProfile
 
 NOTE: CLASS method

 @param inServiceUUID - The device's service UUID exposing read (Tx) and transfer (Rx) characteristics
 @param inRxUUID - The RECEIVE characteristic UUID
 @param inTxUUID - The TRANSMIT characteristic UUID
 @param inCommandEnd - The TERMINATOR of device commands (the string TxRxManager class attaches to any sent command which lets Tertium devices understand a command has finished)
 @param inMaxPacketSize - The Maximum number of bytes the device can accept with a single transfer
 @return - And instance of TxRxDeviceProfile with the supplied parameters
 */
+(instancetype _Nonnull) newProfileWithParameters:(nonnull NSString *) inServiceUUID withRxUUID: (nonnull NSString *) inRxUUID withTxUUID: (nonnull NSString *) inTxUUID withCommandEnd: (nonnull NSString *) inCommandEnd withMaxPacketSize: (NSInteger) inMaxPacketSize
{
    return [[TxRxDeviceProfile alloc] initWithParameters: inServiceUUID withRxUUID: inRxUUID withTxUUID: inTxUUID withCommandEnd: inCommandEnd withMaxPacketSize: inMaxPacketSize];
}

/**
 Initializes an instance of TxRxDeviceProfile
 
 NOTE: INSTANCE method used for initializing readonly methods
 
 @param inServiceUUID - The device's service UUID exposing read (Tx) and transfer (Rx) characteristics
 @param inRxUUID - The RECEIVE characteristic UUID
 @param inTxUUID - The TRANSMIT characteristic UUID
 @param inCommandEnd - The TERMINATOR of device commands (the string TxRxManager class attaches to any sent command which lets Tertium devices understand a command has finished)
 @param inMaxPacketSize - The Maximum number of bytes the device can accept with a single transfer
 @return - And instance of TxRxDeviceProfile with the supplied parameters
 */
-(id)initWithParameters:(nonnull NSString *) inServiceUUID withRxUUID: (nonnull NSString *) inRxUUID withTxUUID: (nonnull NSString *) inTxUUID withCommandEnd: (nonnull NSString *) inCommandEnd withMaxPacketSize: (NSInteger) inMaxPacketSize
{
    self = [super init];
    if (self) {
        serviceUUID = inServiceUUID;
        rxUUID = inRxUUID;
        txUUID = inTxUUID;
        commandEnd = inCommandEnd;
        maxSendPacketSize = inMaxPacketSize;
    }
    
    return self;
}

@end
