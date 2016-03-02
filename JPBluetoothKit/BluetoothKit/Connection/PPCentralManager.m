//
//  PPCentralManager.m
//  JPBluetoothKit
//
//  Created by Jan Posz on 17.02.2016.
//  Copyright © 2016 Jan Posz. All rights reserved.
//

#import "PPCentralManager.h"

@interface PPCentralManager () <CBCentralManagerDelegate>

@property (nonatomic, readwrite, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableArray *activeSubscribers;
@property (nonatomic, strong) NSMutableArray *subscribers;
@property (nonatomic, strong) NSMutableArray *configurations;

@end

@implementation PPCentralManager

+ (PPCentralManager *)sharedManager {
    
    static PPCentralManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.activeSubscribers = [NSMutableArray new];
        self.subscribers = [NSMutableArray new];
        self.configurations = [NSMutableArray new];
    }
    return self;
}

- (void)addSubsriber:(id<CBCentralManagerDelegate>)subscriber withConfiguration:(PPConfiguration *)configuration {
    [self.configurations addObject:configuration];
    [self reloadScan];
    [self.activeSubscribers addObject:subscriber];
    if (![self.subscribers containsObject:subscriber]) {
        [self.subscribers addObject:subscriber];
    }
}

- (void)removeSubsriber:(id<CBCentralManagerDelegate>)subscriber withConfiguration:(PPConfiguration *)configuration {
    [self.configurations removeObject:configuration];
    [self.activeSubscribers removeObject:subscriber];
    if (self.activeSubscribers.count) {
        [self reloadScan];
    }
    [self stopScan];
}

- (void)permanentlyRemoveSubsriber:(id<CBCentralManagerDelegate>)subscriber withConfiguration:(PPConfiguration *)configuration {
    [self removeSubsriber:subscriber withConfiguration:configuration];
    [self.subscribers removeObject:subscriber];
}

#pragma mark - scanning

- (void)reloadScan {
    NSMutableArray *scanParams = [NSMutableArray new];
    for (PPConfiguration *configuration in self.configurations) {
        if (configuration.advServiceUUID) {
            [scanParams addObject:configuration.advServiceUUID];
        }
    }
    if (scanParams.count) {
        [self initializeScanningWithParameters:[scanParams copy]];
    }
    [self initializeScanningWithParameters:nil];
}

- (void)initializeScanningWithParameters:(NSArray *)params {
    [self stopScan];
    [self.centralManager scanForPeripheralsWithServices:params options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
}

- (void)stopScan {
    [self.centralManager stopScan];
}

#pragma mark - central manager stack

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    @synchronized(self.activeSubscribers) {
        for (id<CBCentralManagerDelegate>subscriber in self.activeSubscribers) {
            if ([subscriber respondsToSelector:_cmd]) {
                [subscriber centralManagerDidUpdateState:central];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    @synchronized(self.activeSubscribers) {
        for (id<CBCentralManagerDelegate>subscriber in self.activeSubscribers) {
            if ([subscriber respondsToSelector:_cmd]) {
                [subscriber centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    @synchronized(self.activeSubscribers) {
        for (id<CBCentralManagerDelegate>subscriber in self.activeSubscribers) {
            if ([subscriber respondsToSelector:_cmd]) {
                [subscriber centralManager:central didConnectPeripheral:peripheral];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    @synchronized(self.subscribers) {
        for (id<CBCentralManagerDelegate>subscriber in self.subscribers) {
            if ([subscriber respondsToSelector:_cmd]) {
                [subscriber centralManager:central didDisconnectPeripheral:peripheral error:error];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    @synchronized(self.activeSubscribers) {
        for (id<CBCentralManagerDelegate>subscriber in self.activeSubscribers) {
            if ([subscriber respondsToSelector:_cmd]) {
                [subscriber centralManager:central didFailToConnectPeripheral:peripheral error:error];
            }
        }
    }
}

@end
