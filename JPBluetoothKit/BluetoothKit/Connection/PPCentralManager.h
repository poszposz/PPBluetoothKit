//
//  PPCentralManager.h
//  JPBluetoothKit
//
//  Created by Jan Posz on 17.02.2016.
//  Copyright © 2016 Jan Posz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPConfiguration.h"
@import CoreBluetooth;

@interface PPCentralManager : NSObject

+ (PPCentralManager *)sharedManager;

@property (nonatomic, readonly, strong) CBCentralManager *centralManager;

- (void)reloadScan;
//- (void)stopScan;

- (void)addSubsriber:(id<CBCentralManagerDelegate>)subscriber withConfiguration:(PPConfiguration *)configuration;
- (void)removeSubsriber:(id<CBCentralManagerDelegate>)subscriber withConfiguration:(PPConfiguration *)configuration;
- (void)permanentlyRemoveSubsriber:(id<CBCentralManagerDelegate>)subscriber withConfiguration:(PPConfiguration *)configuration;

@end
