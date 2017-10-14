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

#import "TxRxWatchDogTimer.h"
#import "TxRxDevice.h"

@implementation TxRxWatchDogTimer
@synthesize device, interval, phase;

// Private class attributes, NOT to be exposed to public
NSTimer *_timer;
id _target;
SEL _selector;

/**
 scheduledTimerWithParameters - Creates a NSTimer with specified parameters including TxRxDevice reference and operational phase (purpose of the watchdog timer)
 
 NOTE: this is a CLASS method, not an INSTANCE method

 @param device - The TxRxDevice handled
 @param inPhase - The purpose of the timer
 @param ti - The interval after which the timer fires
 @param aTarget - The class implementing the callback
 @param aSelector - The method of the class implenting the callback
 @param userInfo - User information passed to the class implementing the callback (NOTE: NOT USED BY TxRxManager)
 @param yesOrNo - If the timer has to repeat (NOTE: TxRxManager only uses NON repeating timers)
 @return - Returns a newly created instance of TxRxWatchDogTimer
 */
+(TxRxWatchDogTimer *_Nonnull)scheduledTimerWithParameters:(nullable TxRxDevice *) device inPhase: (NSInteger) inPhase withInterval:(NSTimeInterval)ti target:(id _Nonnull )aTarget selector:(SEL _Nonnull)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo
{
    return [[TxRxWatchDogTimer alloc] initWithParameters: device inPhase: inPhase withInterval: ti target: aTarget selector: aSelector userInfo: userInfo repeats: yesOrNo];
}

/**
 initWithParameters - Initializes an instance of TxRxWatchDogTimer class
 
 NOTE: INSTANCE method used for initializing readonly methods
 
 @param inPhase - The purpose of the timer
 @param aTarget - The class implementing the callback
 @param aSelector - The method of the class implenting the callback
 @param userInfo - User information passed to the class implementing the callback (NOTE: NOT USED BY TxRxManager)
 @param yesOrNo - If the timer has to repeat (NOTE: TxRxManager only uses NON repeating timers)
 @return - Returns a newly created instance of TxRxWatchDogTimer
 */
 -(TxRxWatchDogTimer *)initWithParameters: (nullable TxRxDevice *) inDevice inPhase: (NSInteger) inPhase withInterval:(NSTimeInterval)inInterval target:(id _Nonnull )aTarget selector:(SEL _Nonnull)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo
{
    self = [super init];
    if (self) {
        _target = aTarget;
        _selector = aSelector;
        device = inDevice;
        phase = [[NSNumber alloc] initWithInteger: inPhase];
        interval = inInterval;
        _timer = [NSTimer scheduledTimerWithTimeInterval: inInterval target: self selector: @selector(watchDogTimerTick:) userInfo: nil repeats: false];
    }
    
    return self;
}

/**
 watchDogTimerTick - Handles NSTimer's tick method and dispatches class information to supplied method of supplied class (TxRxManager watchDog callback handlers)

 @param timer - The instance of the NSTimer used
 */
-(void)watchDogTimerTick:(NSTimer *)timer
{
    NSMethodSignature* sign;
    NSInvocation* invoc;
    
    sign = [_target methodSignatureForSelector: _selector];
    invoc = [NSInvocation invocationWithMethodSignature: sign];
    [invoc setTarget: _target];
    [invoc setSelector: _selector];
    [invoc setArgument: (void *)(&self) atIndex: 2];
    [invoc setArgument: (void *)(&device) atIndex: 3];
    [invoc setArgument: (void *)(&phase) atIndex: 4];
    [invoc invoke];
}

/**
 stop - Stops and invalidates the underling NSTimer instance. 
 
 NOTE: When stop is called a TxRxDevice operation issued correctly and no timeout in bluetooth data exchange happened
 */
-(void)stop
{
    [_timer invalidate];
    _timer = nil;
}

@end
