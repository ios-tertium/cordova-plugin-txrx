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

#ifndef TxRxManagerErrors_h
#define TxRxManagerErrors_h

/**
 TxRxManager library TxRxManagerErrors
 
 TxMRxManagerErrors enum contains possible error codes reported by TxRxManager class
 
 Both an NSUInteger error code and a string error code will be reported in NSError classes (refer to TxRxDeviceScanProtocol and TxRxDeviceDataProtocol for delegating details)
 
 */
typedef NS_ENUM(NSUInteger, TxMRxManagerErrors)
{
    TERTIUM_ERROR_BLUETOOTH_NOT_READY_OR_LOST
    ,TERTIUM_ERROR_UNABLE_TO_SCAN_BLUETOOTH_DISABLED
    ,TERTIUM_ERROR_DEVICE_SCAN_ALREADY_STARTED
    ,TERTIUM_ERROR_DEVICE_SCAN_NOT_STARTED
    ,TERTIUM_ERROR_DEVICE_UNABLE_TO_PERFORM_DURING_SCAN
    ,TERTIUM_ERROR_DEVICE_CONNECT_TIMED_OUT
    ,TERTIUM_ERROR_DEVICE_ALREADY_CONNECTING
    ,TERTIUM_ERROR_DEVICE_SERVICE_OR_CHARACTERISTICS_NOT_DISCOVERED_YET
    ,TERTIUM_ERROR_DEVICE_ALREADY_CONNECTED
    ,TERTIUM_ERROR_ALREADY_DISCONNECTING
    ,TERTIUM_ERROR_DEVICE_DISCONNECT_TIMED_OUT
    ,TERTIUM_ERROR_DEVICE_NOT_CONNECTED
    ,TERTIUM_ERROR_DEVICE_SENDING_DATA_ALREADY
    ,TERTIUM_ERROR_DEVICE_SENDING_DATA_PARAMETER_ERROR
    ,TERTIUM_ERROR_DEVICE_SENDING_DATA_TIMEOUT
    ,TERTIUM_ERROR_DEVICE_RECEIVING_DATA_TIMEOUT
    ,TERTIUM_ERROR_DEVICE_NOT_FOUND
    ,TERTIUM_INTERNAL_ERROR
};

#define TERTIUM_TXRX_ERROR_DOMAIN @"Tertium TxRx BLE device library"

#define S_TERTIUM_ERROR_BLUETOOTH_NOT_READY_OR_LOST @"Bluetooth is not online yet!"
#define S_TERTIUM_ERROR_UNABLE_TO_SCAN_BLUETOOTH_DISABLED @"Unable to scan, bluetooth is disabled!"
#define S_TERTIUM_ERROR_DEVICE_SCAN_ALREADY_STARTED @"Device scan already started!"
#define S_TERTIUM_ERROR_DEVICE_SCAN_NOT_STARTED @"Device scan not started!"
#define S_TERTIUM_ERROR_DEVICE_UNABLE_TO_PERFORM_DURING_SCAN @"Operation is not permitted during device scan!"
#define S_TERTIUM_ERROR_DEVICE_CONNECT_TIMED_OUT @"Timeout while connecting to device!"
#define S_TERTIUM_ERROR_DEVICE_ALREADY_CONNECTING @"Error, already connecting to device!"
#define S_TERTIUM_ERROR_DEVICE_SERVICE_OR_CHARACTERISTICS_NOT_DISCOVERED_YET @"Tertium service UUIDs not present or not discovered yet!"
#define S_TERTIUM_ERROR_DEVICE_ALREADY_CONNECTED @"Error, already connected to device!"
#define S_TERTIUM_ERROR_DEVICE_DISCONNECT_TIMED_OUT @"Error, device disconnection timed out!"
#define S_TERTIUM_ERROR_ALREADY_DISCONNECTING @"Already trying to disconnect device!"
#define S_TERTIUM_ERROR_DEVICE_NOT_CONNECTED @"Error, device not connected!"
#define S_TERTIUM_ERROR_DEVICE_SENDING_DATA_ALREADY @"Error, already trying to send data to device!"
#define S_TERTIUM_ERROR_DEVICE_SENDING_DATA_PARAMETER_ERROR @"One or more parameters are wrong!"
#define S_TERTIUM_ERROR_DEVICE_SENDING_DATA_TIMEOUT @"Timeout while sending data to device!"
#define S_TERTIUM_ERROR_DEVICE_RECEIVING_DATA_TIMEOUT @"Error, timeout while receiving data!"
#define S_TERTIUM_ERROR_DEVICE_NOT_FOUND @"Device not found in internal data structures!"
#define S_TERTIUM_ERROR_INTERNAL_ERROR @"Unspecified internal error!"
#endif /* TxRxManagerErrors_h */
