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

#ifndef CoreNotification_h
#define CoreNotification_h

/*
 
 Defines the notifications reflected by Core class
 
 */

#define TXRX_NOTIFICATION_NAME @"TxRxNotification"
#define TXRX_NOTIFICATION_SCAN_BEGAN @"TxRxScanBegan"
#define TXRX_NOTIFICATION_SCAN_ERROR @"TxRxScanError"
#define TXRX_NOTIFICATION_SCAN_ENDED @"TxRxScanEnded"
#define TXRX_NOTIFICATION_DEVICE_ERROR @"TxRxDeviceError"
#define TXRX_NOTIFICATION_DEVICE_FOUND @"TxRxDeviceFound"
#define TXRX_NOTIFICATION_DEVICE_CONNECT_ERROR @"TxRxDeviceConnectError"
#define TXRX_NOTIFICATION_DEVICE_CONNECTED @"TxRxDeviceConnected"
#define TXRX_NOTIFICATION_DEVICE_READY @"TxRxDeviceReady"
#define TXRX_NOTIFICATION_DEVICE_DISCONNECTED @"TxRxDeviceDisconnected"
#define TXRX_NOTIFICATION_DEVICE_DATA_SENT @"TxRxDeviceDataSent"
#define TXRX_NOTIFICATION_DEVICE_DATA_SEND_ERROR @"TxRxDeviceDataSendError"
#define TXRX_NOTIFICATION_DEVICE_DATA_SEND_TIMEOUT @"TxRxDeviceDataSendTimeout"
#define TXRX_NOTIFICATION_DEVICE_DATA_RECEIVED @"TxRxDeviceDataReceived"
#define TXRX_NOTIFICATION_DEVICE_DATA_RECEIVE_ERROR @"TxRxDeviceDataReceiveError"
#define TXRX_NOTIFICATION_INTERNAL_ERROR @"TxRxDeviceInternalError"

#endif /* CoreNotification_h */
