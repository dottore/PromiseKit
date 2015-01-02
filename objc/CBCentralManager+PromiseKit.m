//
//
//  Created by Marco Sanna on 2015-01-02
//

#import <objc/runtime.h>
#import "CBCentralManager+PromiseKit.h"

@interface PMKCBCentralManagerDelegater : NSObject <CBCentralManagerDelegate> {
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
    fulfill(peripheral);
}

@end

@implementation CBCentralManager (PromiseKit)

- (PMKPromise *)scanAllPeripherals {
    PMKCBCentralManagerDelegater *d = [PMKCBCentralManagerDelegater new];
    PMKRetain(d);
    self.delegate = d;
    [self scanForPeripheralsWithServices:nil options:nil];
    return [PMKPromise new:^(id fulfiller, id rejecter) {
        d->fulfill = fulfiller;
        d->reject = rejecter;
    }];
}

@end
