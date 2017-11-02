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

/**
 
 TxRxDeviceProfile is the class mantaining Tertium devices service UUIDs and characteristic UUIDs
 
 */
@interface TxRxDeviceProfile : NSObject

// The Service UUID of the Tertium BLE Device
@property (nonatomic, strong, nonnull, readonly) NSString *serviceUUID;

// The UUID of send and receive characteristic of Tertium BLE Device
@property (nonatomic, strong, nonnull, readonly) NSString *rxUUID;
@property (nonatomic, strong, nonnull, readonly) NSString *txUUID;

// The terminator of the Tertium BLE Device
@property (nonatomic, strong, nonnull, readonly) NSString *commandEnd;
@property (nonatomic, readonly) NSInteger maxSendPacketSize;

+(instancetype _Nonnull) newProfileWithParameters:(nonnull NSString *) inServiceID withRxUUID: (nonnull NSString *) inRxUUID withTxUUID: (nonnull NSString *) inTxUUID withCommandEnd: (nonnull NSString *) inCommandEnd withMaxPacketSize: (NSInteger) inMaxPacketSize;
@end
