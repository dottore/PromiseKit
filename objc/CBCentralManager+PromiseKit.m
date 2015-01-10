//
//
//  Created by Marco Sanna on 2015-01-02
//

#import <objc/runtime.h>
#import <CoreBluetooth/CBPeripheral.h>
#import "CBCentralManager+PromiseKit.h"

@interface PMKCBCentralManagerDelegater : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    @public
        void (^fulfill)(id);
        void (^reject)(id);
}
@end

@implementation PMKCBCentralManagerDelegater

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    NSLog(@"did discover");
    fulfill(peripheral);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    fulfill(nil);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error != nil) {
        reject(error);
    } else {
        fulfill(nil);
    }
    peripheral.delegate = nil;
    PMKRelease(self);
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"state: %li", central.state);
}

@end

@implementation CBCentralManager (PromiseKit)

- (id)init {
    // Start up the CBCentralManager
    dispatch_queue_t centralQueue = dispatch_queue_create("com.simpleshare.mycentral", DISPATCH_QUEUE_SERIAL);
    PMKCBCentralManagerDelegater *d = [PMKCBCentralManagerDelegater new];
    PMKRetain(d);
    self = [self initWithDelegate:d queue:centralQueue];
    return self;
}

- (PMKPromise *)promiseForPeripheralsWithServices:(NSArray *)services options:(NSDictionary *)options timeout:(NSTimeInterval)timer {
    [self scanForPeripheralsWithServices:services options:options];
    NSLog(@"scanning");
    return [PMKPromise new:^(id fulfiller, id rejecter) {
        PMKCBCentralManagerDelegater *d = (PMKCBCentralManagerDelegater *)self.delegate;
        d->fulfill = fulfiller;
        d->reject = rejecter;
    }];
}



@end
