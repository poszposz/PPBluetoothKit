//
//  ViewController.m
//  JPBluetoothKit
//
//  Created by Jan Posz on 25.01.2016.
//  Copyright © 2016 Jan Posz. All rights reserved.
//

#import "ConnectionViewController.h"
#import "PPConnection.h"
#import "PPAdvertisement.h"
#import "Constants.h"

static NSString *kServiceUUID =                         @"00001001-202E-434E-4920-54454C4F4F57";
static NSString *kSoundCharacteristicUUID =             @"00001002-202E-434E-4920-54454C4F4F57";
static NSString *kIdentifyCharacteristicUUID =          @"00001003-202E-434E-4920-54454C4F4F57";
static NSString *kAuthorizationCharacteristicUUID =     @"00001004-202E-434E-4920-54454C4F4F57";
static NSString *kTemperatureCharacteristicUUID =       @"00001006-202E-434E-4920-54454C4F4F57";

@interface ConnectionViewController ()

@end

@implementation ConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)connectTapped:(id)sender {
    [self connect];
}

- (void)connect {
    
    PPService *s1 = [[PPService alloc] initWithUUID:[CBUUID UUIDWithString:kServiceUUID]];
    PPCharacteristic *ch1 = [[PPCharacteristic alloc] initWithContainedService:s1 uuid:[CBUUID UUIDWithString:kSoundCharacteristicUUID] shouldObserveValue:YES];
    ch1.identifier = 1;
    [self observeValueForCharacteristic:ch1];
    
    PPConfiguration *configuration = [PPConfiguration connectionConfigurationWithServices:@[s1] characteristics:@[ch1] advertisementUUID:advertisingServiceUUID];
    PPPeripheral *peripheral = [PPPeripheral peripheralWithConfiguration:configuration];

    PPConnection *connection = [[PPConnection alloc] init];
    [connection setPreconnectionValidationHandler:^BOOL(NSString *a, NSDictionary *b, PPPeripheral *c) {
        NSLog(@"%@", b);
        return YES;
    }];
    [connection connectDevice:peripheral connectionStateHandler:^(ConnectionState state) {
        
    } completionHandler:^(BOOL completed, NSError *error) {
        NSLog(@"connected");
        [self trySoundOnPeripheral:peripheral];
        [self handleDisconnectionForPeripheral:peripheral];
    }];
    
    connection.enableLogging = YES;
    connection.deviceShouldContainAllConfigurationData = NO;
}

- (void)trySoundOnPeripheral:(PPPeripheral *)peripheral {
    PPCommand *command = [PPCommandBuilder int16CommandWithValue:3 forCharacteristic:[peripheral.configuration characteristicWithIdentifier:1]];
    [peripheral writeCommand:command completionHandler:^(BOOL completed, NSError *error) {
        NSLog(@"played");
    }];
}

- (void)observeValueForCharacteristic:(PPCharacteristic *)characteristic {
    [characteristic setValueChangeHandler:^(NSData *data) {
        NSLog(@"data");
    }];
}

- (void)handleDisconnectionForPeripheral:(PPPeripheral *)peripheral {
    
    [peripheral setDisconnectionHandler:^(NSError *error) {
        NSLog(@"Disconnected");
    }];
}

@end
