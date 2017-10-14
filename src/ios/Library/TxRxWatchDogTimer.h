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

@class TxRxDevice;

/**
 
 TxRxWatchDogTimer is an instance class responsible for implementing watchdogs on timeout operations.
 
 Each instance is created or destroyed by TxRxManager to control timeouts in scan of, connect to and data exchange with TxRxDevices
 
 */
@interface TxRxWatchDogTimer : NSObject

// Mantains a reference to the TxRxDevice which is being handled
@property (nonatomic, strong, readonly, nonnull) TxRxDevice * device;

// Specifies the purpose for the timer
@property (nonatomic, strong, readonly, nonnull) NSNumber *phase;

// Defines when the timer will tick
@property (nonatomic, readonly) NSInteger interval;

+(instancetype _Nonnull)scheduledTimerWithParameters:(nullable TxRxDevice *) device inPhase: (NSInteger) inPhase withInterval:(NSTimeInterval)ti target:(id _Nonnull )aTarget selector:(SEL _Nonnull)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
-(void)stop;
@end
