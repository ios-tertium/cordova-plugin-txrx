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

#import "TxRxManager.h"
#import "TxRxWatchDogTimer.h"
#import "TxRxDevice.h"
#import "TxRxDeviceManagerExchangeProtocol.h"

@interface TxRxDevice()<TxRxDeviceManagerExchangeProtocol>
@end

@implementation TxRxDevice
@synthesize Name;

// Hidden class attributes
NSData* _dataToSend;

/**
 Init - initializes and instance of TxRxDevice

 @return - a new TxRxDevice instance
 */
-(id)init
{
    self = [super init];
    if (self){
        receivedData = [NSMutableData new];
    }
    
    return self;
}

/**
 isConnected - Implements isConnected readonly property 
 
 NOTE: accesses protected deviceConnected field (refer to TxRxDeviceManagerExchangeProtocol for details)

 @return - a boolean specifing if device is connected to this iPhone or iPad
 */
-(bool)isConnected
{
    return deviceConnected;
}

// Implements hidden TxRxDeviceManagerExchangeProtocol (Below methods are only to be used by TxRxMananger class)
#pragma mark TxRxDeviceManagerExchangeProtocol hidden protocol implementation
@synthesize watchDogTimer, sendingData, bytesToSend, bytesSent, totalBytesSent, deviceConnected, dataToSend = _dataToSend, receivedData, deviceProfile;

/**
 dataToSend - Implements dataToSend property getter
 
 NOTE: PROTECTED method (refer to TxRxDeviceManagerExchangeProtocol for details)
 
 @return - The current data byte array to be sent to the TxRxDevice
 */
-(NSData *)dataToSend
{
    return _dataToSend;
}

/**
 setDataToSend - Implements dataToSend property setter
 
 NOTE: PROTECTED method (refer to TxRxDeviceManagerExchangeProtocol for details)
 
 @dataToSend - NSData with bytes to send to the device
 */
-(void)setDataToSend:(NSData *)dataToSend
{
    _dataToSend = dataToSend;
    bytesToSend = [dataToSend length];
    totalBytesSent = 0;
    bytesSent = 0;
}

/**
 scheduleWatchdogWithParameters - Utility method to create an instance of TxRxWatchDog and assign it to this TxRxDevice's instance

 NOTE: invalidates previous existing watchdog
 NOTE: PROTECTED method (refer to TxRxDeviceManagerExchangeProtocol for details)
 */
-(void)scheduleWatchdogWithParameters:(NSInteger) inPhase withInterval:(NSTimeInterval)ti target:(id _Nonnull )aTarget selector:(SEL _Nonnull)aSelector
{
    [self invalidateWatchDogTimer];
    watchDogTimer = [TxRxWatchDogTimer scheduledTimerWithParameters: self inPhase: inPhase withInterval: ti target: aTarget selector: aSelector userInfo: nil repeats: false];
}

/**
 resetReceivedData - Utility method to clear receivedData (NSMutable data) class contents
 
 NOTE: PROTECTED method (refer to TxRxDeviceManagerExchangeProtocol for details)
 */
-(void)resetReceivedData
{
    [receivedData setLength: 0];
}

/**
resetStates - Utility method to clear device states

NOTE: PROTECTED method (refer to TxRxDeviceManagerExchangeProtocol for details)
*/
-(void)resetStates
{
    deviceConnected = false;
    _txChar = nil;
    _rxChar = nil;
    sendingData = false;
    deviceProfile = nil;
    [self resetReceivedData];
}

/**
 invalidateTimer - Utility method to invalidate current TxRxDevice watchdog timer
 
 NOTE: PROTECTED method (refer to TxRxDeviceManagerExchangeProtocol for details)
 */
-(void)invalidateWatchDogTimer
{
    if (watchDogTimer != nil)
        [watchDogTimer stop];
}

@end
