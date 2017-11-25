/* TxrxPlugin.h */

#import <Cordova/CDV.h>
#import "TxRxManager.h"
#import "TxRxDeviceScanProtocol.h"


@interface TxrxPlugin : CDVPlugin<TxRxDeviceScanProtocol, TxRxDeviceDataProtocol> {
    NSMutableDictionary *_jsCallbacks;
    TxRxManager* _manager;
    TxRxDevice* _connectedDevice;
}

/* COMMANDS */
- (void) startScan:(CDVInvokedUrlCommand*) command;
- (void) stopScan:(CDVInvokedUrlCommand*) command;
- (void) connect:(CDVInvokedUrlCommand*) command;
- (void) writeData:(CDVInvokedUrlCommand*) command;
- (void) getTimeouts:(CDVInvokedUrlCommand*) command;
- (void) setTimeouts:(CDVInvokedUrlCommand*) command;
- (void) setDefaultTimeouts:(CDVInvokedUrlCommand*) command;
- (void) isDeviceConnected:(CDVInvokedUrlCommand*) command;
- (void) registerCallback:(CDVInvokedUrlCommand*) command;

@end
