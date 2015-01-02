//
//
//  Created by Marco Sanna on 2015-01-02
//

#import <PromiseKit/PromiseKit.h>
#import <CoreBluetooth/CBCentralManager.h>

@interface CBCentralManager (PromiseKit)

- (PMKPromise *)scanAllPeripherals;

@end
